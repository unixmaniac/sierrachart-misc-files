# sierrachart-misc-files

Miscelaneous files related to Sierra Chart trading platform

## sc_install_ubuntu.sh

Simple Sierra Chart install script for Ubuntu Linux.
Currently supports only Ubuntu 18.04 LTS.

Download and run it as user like a normal shell script.

It installs and configures WINE (staging, development or stable),
creates a WINE bottle and "pours" latest Sierra Chart into it.

Video demonstrating its usage https://youtu.be/K-mOrKnXjTg

## sc_build_dll.bash

Simple script that compiles a single ACSIL C++ source file into a DLL
and (re)loads it into Sierra Chart.

Make sure to edit and change the following variables before running.

```
SC_UDP_PORT="XXXX"
SC_DIR_NAME="SierraChart"
SC_BASE_DIR="/home/foo/.wine/drive_c/${SC_DIR_NAME}"
```

Also tune the compilation options to fit your needs.

Watch how to use this script along with setting up your Linux development environment for Sierra Chart https://youtu.be/UC69ex3kqcc
