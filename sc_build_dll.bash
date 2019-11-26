#!/bin/bash
#
###############################################################################
# Filename	: sc_build_dll.bash
# Description	: Use it to compile and (re)load Sierra Chart ASCIL files
# Usage		: sc_build_dll.bash (build|build_debug) <file>
# Author	: Stefanos Spanoudakis
# Email		: unixmaniac@gmail.com
###############################################################################
#

V="0.1"

echo "Sierra Chart DLL Build Script v$V"

CMPLR="/usr/bin/x86_64-w64-mingw32-g++"

# Sierra Chart UDP Port
# refer to https://www.sierrachart.com/index.php?page=doc/UDPAPI.html#GeneralInformation for more info.
SC_UDP_PORT="XXXX"

# Directory name where Sierra Chart is installed.
SC_DIR_NAME="SierraChart"

# Full path of WINE bottle.
SC_BASE_DIR="/home/foo/.wine/drive_c/${SC_DIR_NAME}"

CMD=$1
CPP_SRC=$2
CPP_OUT=${CPP_SRC%%.*}
CPP_FN=${CPP_OUT##*/}

# Compile parameters
PROD_BUILD_PARAMS="-I ${SC_BASE_DIR}/ACS_Source -w -s -O2 -m64 -march=native -static -shared ${CPP_SRC} -o ${CPP_OUT}_64.dll"
DEBUG_BUILD_PARAMS="-I ${SC_BASE_DIR}/ACS_Source -g -O2 -m64 -march=native -static -shared ${CPP_SRC} -o ${CPP_OUT}_64.dll"

WIN_FP='C:\'${SC_DIR_NAME}'\Data\'${CPP_FN}'_64.dll'
RLEASE_DLL_CMD="RELEASE_DLL--${WIN_FP}"
RLOAD_DLL_CMD="ALLOW_LOAD_DLL--${WIN_FP}"

usage() {

        echo "Usage: $0 (build|build_debug) <file>"
        exit 1

}

compile_and_load() {

	P=$(eval echo \$$1_BUILD_PARAMS)
	echo " Compiling."

	$CMPLR $P

	if [ $? = 0 ]; then

		echo " Releasing DLL."
		echo -n $RLEASE_DLL_CMD > /dev/udp/127.0.0.1/$SC_UDP_PORT
		sleep 2

		cp ${CPP_OUT}_64.dll ${SC_BASE_DIR}/Data/
		if [ $? != 0 ]; then
			
			echo "Failed to copy DLL."
			exit 1;

		fi

        	echo " DLL Copied."

        	echo " Reloading DLL."
		echo -n $RLOAD_DLL_CMD > /dev/udp/127.0.0.1/$SC_UDP_PORT

        else

		echo "Build failed."
		exit 1

	fi

}

if [ ! -f $CPP_SRC ] || [ ! $CPP_SRC ]; then 

	echo "Source file not found."
	usage

fi

if [ ! -e $CMPLR ]; then

	echo "Cannot find compiler. Make sure you have MinGW installed."
	exit 1

fi

if [ ! -d $SC_BASE_DIR ]; then

	echo "SierraChart directory does not exist"
	exit 1

fi


case $CMD in

	build)

		compile_and_load PROD
		;;

	build_debug)

		compile_and_load DEBUG
		;;

	*)

		usage
		;;

esac

