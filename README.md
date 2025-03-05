## Motivation:

I wanted to be able to add magnet links to my remote qbittorrent instance on click and browser plugins just didn't work in my case.
This is my take on this issue.

**FEEL FREE TO MAKE IT BETTER, I WILL BE GLAD IF THIS WILL BE OF ANY USE TO SOMEONE OTHER THAN ME.**

## Info:

Simple bash script wrapped as a "application" for Linux and Macos, capable of adding magnet links and torrent files to remote torrent client instance.

## Requirements:

### MacOS

- brew installed beforehand

## Caveats:

### OS

**MacOS**

- installs duti if not present

**Linux**

- installs curl if not present

### Torrent client

**Deluge**

- expects deluge-web to be connected to deluged service, script doesn't handle this part when adding torrents

## Torrent client compatibility:

- qbittorrent
  - tested on v.4.1.9.1, v5.0.2
- transmission
  - tested on v.3.0.0, v4.0.6
- deluge ( Without auth bypass, as it is not officialy supported)
  - tested on v1.3.5, v2.1.1

## Tested on:

- MacOS Catalina
- MacOS BigSur
- MacOs Ventura
- Arch with KDE
- Debian 10 with XFCE ( should work on other distros and DEs)

## How to:

clone repository, run:
`chmod +x ./installer.sh && ./installer.sh`
and follow the steps.

## TODO (which I might or might not do):

- make it work with more torrent clients
- Maybe add icon to installer

## Credits

Transmissions CURL was inspired by https://gist.github.com/sbisbee/8215353
