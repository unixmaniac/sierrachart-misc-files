#!/bin/sh
#
#---------------------------------
#   Sierra Chart Install Script  
#---------------------------------
# version 0.1
#  Supporting only Ubuntu 18.04 LTS (bionic) atm.
#

RC="\033[0;31m"
GC="\033[0;32m"
YC="\033[0;33m"
NC="\033[0m"

WGET_X="/usr/bin/wget"
CURL_X="/usr/bin/curl"
GDEBI_X="/usr/bin/gdebi"
WINE_X="/usr/bin/wine"
WINETRICKS_X="/usr/bin/winetricks"
WINECFG_X="/usr/bin/winecfg"
DPKG_X="/usr/bin/dpkg"
APT_X="/usr/bin/apt"
APTKEY_X="/usr/bin/apt-key"
UNZIP_X="/usr/bin/unzip"
SUDO_X="/usr/bin/sudo"

URNAME=`lsb_release -c|awk -F" " '{print $2}'`

FADEB64="https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/amd64/libfaudio0_19.07-0~bionic_amd64.deb"
FADEB32="https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/i386/libfaudio0_19.07-0~bionic_i386.deb"

SCZIPURL="https://www.sierrachart.com/downloads/ZipFiles/SierraChartVERSION.zip"

LOGFILE="/var/tmp/sc_install.log"

### functions
fail_exit() {

        echo "\nTerminating.\n"
	exit 1

}

check_status() {

	if [ $? != 0 ]; then

		echo "\t${RC}FAIL${NC}\nTerminating.\n"
		exit 2

	else

		echo "\t${GC}OK${NC}"

	fi

}

### main()
echo "\n$0 :: Sierra Chart Linux Installer ::\n"

# check for supported ubuntu versions or exit
if [ "$URNAME" = "bionic" ]; then

	echo " ${GC}*${NC} Detected Ubuntu 18.04 LTS"

else 

	echo " ${RC}*${NC} Cannot identify Linux version."
	fail_exit

fi

# grants sudo
echo -n " ${YC}*${NC} Checking sudo status"
${SUDO_X} -v
check_status


# touch logfile
echo -n " ${YC}*${NC} Start logging to ${LOGFILE}"
/usr/bin/touch ${LOGFILE}
check_status

echo `date` > ${LOGFILE}

# check/install first dependencies
if [ -x "$WGET_X" ] && [ -x "$CURL_X" ] && [ -x "$GDEBI_X" ] && [ -x "$UNZIP_X" ]; then

	echo " ${GC}*${NC} Dependencies found."

else

	echo -n " ${YC}*${NC} Installing dependencies..."
	${SUDO_X} apt install wget curl gdebi unzip -y >>${LOGFILE} 2>&1

	check_status

fi

# check/install WINE
if [ -e "$WINE_X" ] && [ -e "$WINETRICKS_X" ] && [ -e "$WINECFG_X" ]; then

	echo " ${GC}*${NC} WINE found. Not re-installing."

else 


	echo " ${YC}*${NC} Preparing WINE install\n"
	echo -n "\t${YC}-${NC} enabling i386 arch"
	${SUDO_X} ${DPKG_X} --add-architecture i386
	check_status

	echo -n "\t${YC}-${NC} Installing WINE repo GPG key"
	{ ${CURL_X} https://dl.winehq.org/wine-builds/winehq.key | ${SUDO_X} ${APTKEY_X} add -; } >>${LOGFILE} 2>&1
	check_status

	if [ "$URNAME" = "bionic" ]; then

		echo -n "\t${YC}-${NC} Downloading libfaudio packages"
		${WGET_X} $FADEB32 -O /var/tmp/libfa32.deb >>${LOGFILE} 2>&1
		${WGET_X} $FADEB64 -O /var/tmp/libfa64.deb >>${LOGFILE} 2>&1

		if [ ! -f "/var/tmp/libfa32.deb" ] || [ ! -f "/var/tmp/libfa32.deb" ]; then

			echo " ${RC}*${NC} Download failed."
			fail_exit

		else 

			echo "\t${GC}OK${NC}\n"
			echo -n "\t${YC}-${NC} Installing 32bit libfaudio"
			${SUDO_X} ${GDEBI_X} -n /var/tmp/libfa32.deb >>${LOGFILE} 2>&1
			check_status
			echo -n "\t${YC}-${NC} Installing 64bit libfaudio"
			${SUDO_X} ${GDEBI_X} -n /var/tmp/libfa64.deb >>${LOGFILE} 2>&1
			check_status

		fi

	fi

	echo -n "\t${YC}-${NC} Enabling WINE repository"
	${SUDO_X} /usr/bin/apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' >>${LOGFILE} 2>&1
	check_status

	echo -n "\n\n\t===================================\n"
	echo -n "\t  *** WINE branches available ***  \n"
	echo -n "\t===================================\n"
	echo -n "\t  1. Stable\n"
	echo -n "\t  2. Development\n"
	echo -n "\t  3. Staging\n"
	echo -n "\t===================================\n\n"
	echo -n "\t Enter your selection [1-3 or press enter for Staging]: "
	read WV2I

	case $WV2I in

		1)	echo "\n\t${GC}*${NC} Stable WINE branch selected."
			WINEBRANCH="stable"	
			;;

		2)	echo "\n\t${GC}*${NC} Development WINE branch selected."
			WINEBRANCH="devel"
			;;

		3*)	echo "\n\t${GC}*${NC} Staging WINE branch selected."
			WINEBRANCH="staging"
			;;

		*)	echo "\n\t${GC}*${NC} Staging WINE branch selected."
			WINEBRANCH="staging"
			;;

	esac


		
		
	echo -n "\t${YC}-${NC} Installing WINE (${WINEBRANCH} branch)..."
	${SUDO_X} ${APT_X} install --install-recommends winehq-${WINEBRANCH} -y >>${LOGFILE} 2>&1
	check_status

	echo -n "\t${YC}-${NC} Installing WINEtricks"
	${SUDO_X} ${APT_X} install winetricks -y >>${LOGFILE} 2>&1
	check_status

	if [ $? = 0 ]; then

		echo "\n ${GC} = WINE installed successfully!${NC}"

	else
		
		echo "\n ${RC} = WINE installation failed.${NC}"
		fail_exit

	fi

fi

# get WINEPREFIX
echo "\n\n ${YC}*${NC} Preparing Sierra Chart Installation\n\n"

echo -n " Enter full path for WINE bottle [${HOME}/Bottles/SierraChart]:\n "
read PREWINEFIX

if [ "$PREWINEFIX" = "" ]; then

	PREWINEFIX="${HOME}/Bottles/SierraChart"	

fi

if [ -d "$PREWINEFIX" ] ; then

	echo -n "\n ${RC}-${NC} Directory already exists. Is this ok? [y|N]: "
	read R
	case $R in

		[yY]*) 

			;;
	
		[nN]*) 	fail_exit
			;;

		*)	fail_exit
			;;

	esac

else

	echo -n "\n ${YC}*${NC} Creating directory (${PREWINEFIX})"
	mkdir -p $PREWINEFIX
	check_status

fi

		
# validate username
echo -n " ${YC}-${NC} Detected username ${GC}${USER}${NC}. Is this correct? [Y|n]: "
read R1

case R1 in

	[yY]*)

		;;

	[nN]*)	echo " ${GC}-${NC} Please enter your username: "
		read USERNAME

		;;

	*)

		;;

esac
	

# confirmation
echo "\n\n\t${GC}WINEPREFIX=${NC}$PREWINEFIX\n\t${GC}USERNAME=${NC}$USER\n\n"
echo " [Press enter to continue or CTRL-C to exit]"

read R2

# export WINEPREFIX
export WINEPREFIX=$PREWINEFIX

echo -n "\t${YC}-${NC} Installing Visual C++ 2010 libraries"
${WINETRICKS_X} -q vcrun2010 >>${LOGFILE} 2>&1
check_status

# get latest Sierra Chart version number
SCVER=`${CURL_X} -s "https://www.sierrachart.com/index.php?page=doc/setup.php"| grep -Po 'Download Sierra Chart <b>\K[\d]+'`
echo "\t${GC}-${NC} Latest Sierra Chart Version: ${YC}${SCVER}${NC}"

# download Sierra Chart ZIP file
echo -n "\t${YC}-${NC} Downloading"
UTD=`echo ${SCZIPURL} | sed "s/VERSION/${SCVER}/"`
${WGET_X} -q ${UTD} -O /var/tmp/sc${SCVER}.zip >>${LOGFILE} 2>&1
check_status

# extract on WINEPREFIX
echo -n "\t${YC}-${NC} Extracting"
${UNZIP_X} -d ${PREWINEFIX}/drive_c/SierraChart/ /var/tmp/sc${SCVER}.zip >>${LOGFILE} 2>&1
check_status

# create desktop icons
echo "[Desktop Entry]\nVersion=1.0\nType=Application\nTerminal=false\nExec=env WINEPREFIX=\"${PREWINEFIX}\" ${WINE_X} start C://SierraChart//SierraChart_64.exe\nName=Sierra Chart\nComment=Sierra Chart\nIcon=/usr/share/icons/Adwaita/256x256/devices/computer.png" > ${HOME}/Desktop/SierraChart_64.desktop
/bin/chmod +x ${HOME}/Desktop/SierraChart_64.desktop

echo "\n\t${GC} = Sierra Chart installed successfully!${NC}\n"

echo " Make note of your WINEPREFIX which is ${GC}${PREWINEFIX}${NC}."
echo " For now this script created an icon on your desktop for starting"
echo " Sierra Chart 64bit version."
echo " \n\n You can also use the following command to start Sierra Chart"
echo " from command line anytime you wish.\n\n"
echo " ${GC}WINEPREFIX=\"${PREWINEFIX}\" ${WINE_X} start C://SierraChart//SierraChart_64.exe${NC}\n\n"
echo " Happy Trading!\n"
