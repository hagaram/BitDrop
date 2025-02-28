#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m' # Bold
PLATFORM=$(uname)
DEFAULT_APP_NAME="Remote_magnet_handler"
COMPATIBLE_CLIENTS="qbittorrent transmission deluge"


####FC START


macos_check_reqs () {
  command -v brew &>/dev/null
  if [ $? -eq 1 ]; then
      printf "Please, install brew command and re-run the script, exiting...\n"
      exit 1
  fi
  command -v duti &>/dev/null
  if [ $? -eq 1 ]; then
    printf "\n%bInstalling duti%b\n" "${BOLD}" "${NC}"
    brew install duti
  fi
}

linux_check_reqs() {
  command -v curl &>/dev/null
  if [ $? -eq 1 ]; then
    distro=$(sed -nr  "s/^ID=\"?([a-zA-Z]+)\"?/\1/p" /etc/os-release)
    printf "\n%bInstalling curl%b\n" "${BOLD}" "${NC}"
    case $distro in
      arch)
        sudo pacman -Sy curl
        ;;
      centos | rhel | fedora)
        sudo dnf -y install curl
        ;;
      debian | ubuntu)
        sudo apt-get update
        sudo apt-get -y install curl
        ;;
      *)
        printf "Unknown distro, install curl manually and re-run the script, exiting...\n"
        exit 0;
        ;;
    esac
  fi
}


create_linux_middleware_app () {
  printf "%bCreating %s.desktop entry%b\n" "${BOLD}" "${app_name}" "${NC}"
  mkdir -p "${HOME}/.local/share/applications/"
  cat <<EOF > ${HOME}/.local/share/applications/${app_name}.desktop
[Desktop Entry]
Name=${app_name}
Type=Application
Exec=${install_path}/adder.sh %u
NoDisplay=true
MimeType=x-scheme-handler/magnet;application/x-bittorrent;x-scheme-handler/x-bittorrent;
Terminal=false
EOF
}


configure_linux_magnet_association () {
  printf "%bAssigning association with magnet links%b\n" "${BOLD}" "${NC}"
  xdg-mime default "${app_name}".desktop x-scheme-handler/magnet
  xdg-mime default "${app_name}".desktop x-scheme-handler/x-bittorrent
  xdg-mime default "${app_name}".desktop application/x-bittorrent
}


create_macos_middleware_app () {
  printf "%bCreating %s.app%b" "${BOLD}" "${app_name}" "${NC}"
  cat <<EOF > ${install_path}/${app_name}.scpt
on open location this_URL
	do shell script "${install_path}/adder.sh '" & this_URL & "'"
end open location
EOF

  osacompile -o /Applications/"${app_name}".app "${install_path}/${app_name}".scpt
  perl -i -pe 's/(^\s+<key>LSMinimumSystemVersionByArchitecture<\/key>)/\t<key>CFBundleIdentifier<\/key>\n\t<string>com.apple.ScriptEditor.id.Remote-magnet-handler<\/string>\n$1/'  /Applications/${app_name}.app/Contents/Info.plist
}


configure_macos_magnet_association () {
  printf "\n%bAssigning association with magnet links%b" "${BOLD}" "${NC}"
  duti -s com.apple.ScriptEditor.id.Remote-magnet-handler magnet
}

configure_torrent_client () {

  export PS3="Choose number: "
  printf "%bPick torrent client you want to use%b:\n" "${BOLD}" "${NC}"
  select client in ${COMPATIBLE_CLIENTS}
  do
    break
  done


  printf "\n\n%bSpecify application name you wish to use, leave empty to use default %b(defaults to %s)%b:\n" "${BOLD}" "${GREEN}" "${DEFAULT_APP_NAME}" "${NC}"
  read app_name
  app_name=${app_name:-"${DEFAULT_APP_NAME}"}

  printf "\n\n%bSpecify installation path where you want scripts to be created, leave empty to use default %b(defaults to %s/software/%s)%b:\n"  "${BOLD}" "${GREEN}" "${HOME}" "${app_name}" "${NC}"
  read install_path
  install_path=${install_path:-"${HOME}/software/${app_name}"}

  printf "\n%bSpecify URL of your remote qBittorrent instance %b(example: http(s)://192.168.1.200:8080)%b:\n" "${BOLD}" "${GREEN}" "${NC}"
  read url

  printf "\n%bSpecify username  (if applicable) and password, leave both empty when using '%bBypass from whitelisted IPs/Auth disabled%b' %boptions%b:\n" "${BOLD}" "${GREEN}" "${NC}" "${BOLD}" "${NC}"
  printf "%bInput username:%b\n" "${BOLD}" "${NC}"
  read username
  printf "%bInput password:%b\n" "${BOLD}" "${NC}"
  read -s password


  export PS3="Choose number: "
  printf "%bDo you want to use Basic Auth in front of the torrent client?%b:\n" "${BOLD}" "${NC}"
  select basic_auth in yes no
  do
    break
  done

  if [ "$basic_auth" == "yes" ]; then
    export PS3="Choose number: "
    printf "%bDo you want to use the same credentials for Basic Auth as you do for torrent client?%b:\n" "${BOLD}" "${NC}"
    select basic_auth_copy_credentials in yes no
    do
      break
    done
  fi
  
  if [ "$basic_auth" == "yes" ] && [ "$basic_auth_copy_credentials" == "no" ]; then
    printf "\n%bSpecify username for Basic Auth%b:\n" "${BOLD}" "${NC}"
    read basicauth_username
    printf "\n%bSpecify password for Basic Auth%b:\n" "${BOLD}" "${NC}"
    read -s basicauth_password
  else
    basicauth_username=$username
    basicauth_password=$password
  fi

  printf "\n%bCreating adder script in %s/adder.sh%b\n" "${BOLD}" "${install_path}" "${NC}"

  mkdir -p "${install_path}"
  cat <<EOF  > ${install_path}/adder.sh
#!$(which bash)

TORRENT=\$1
URL=$url
USER=$username
PASSWORD=$password
EOF
  
  if [ $basic_auth == "yes" ];then
    source templates/basic_auth
  fi

  source templates/"${client}"
  chmod +x "${install_path}"/adder.sh


}
####FC END


main () {
  case $PLATFORM in
    Darwin)
      macos_check_reqs
      ;;
    Linux)
      linux_check_reqs
    ;;
  esac
  
  configure_torrent_client
  
  case $PLATFORM in
    Darwin)
      create_macos_middleware_app
      configure_macos_magnet_association
      ;;
    Linux)
      create_linux_middleware_app
      configure_linux_magnet_association
      ;;
  esac
  
  printf "\n%bDONE%b\n" "${GREEN}" "${NC}"
}

main
