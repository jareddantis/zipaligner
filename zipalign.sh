#!/bin/bash

# Zipalign/sign script for Linux
# by aureljared@XDA.

# Remove scroll buffer
echo -e '\0033\0143'

# Colourful terminal output (from AOSPA building script)
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

# Phase 1
echo -e "${bldcya}Enter the name of the apk you want to sign."
echo -e "${bldcya}Example: ${cya}SystemUI"
echo -e ""
echo -e "${bldred}NOTES:"
echo -e "${cya}What you enter here will also be the filename of your final APK."
echo -e "${cya}APK must be in the same folder as this script."
echo -n "${txtrst}Filename: "
read appname

# Check existence
if [ -f $appname.apk ]
then
	echo -e ""
	echo -e "${bldgrn}APK exists."
else
	echo -e "${bldred}$appname.apk does not exist. Exiting..."
	exit 1
fi

# Phase 2
echo -e "${bldgrn}Signing APK...${txtrst}"
java -jar signapk.jar testkey.x509.pem testkey.pk8 $appname.apk temp.apk

# Check existence
if [ -f temp.apk ]
then
	mv $appname.apk $appname-original.apk
	clear
	echo -e "${bldgrn}Zipaligning...${txtrst}"
else
	echo -e "${bldred}FATAL: Temporary APK not found. Exiting..."
	exit 1
fi

# Phase 3
chmod a+x ./zipalign
./zipalign -f -v 4 temp.apk $appname.apk

# Check existence
if [ -f $appname.apk ]
then
	rm temp.apk
	echo -e "${bldcya}Would you like to push to your device now?${txtrst}"
else
	echo -e "${bldred}FATAL: Final APK does not exist. Exiting...${txtrst}"
    mv $appname-original.apk $appname.apk
	exit 1
fi

# Push to device
read -p "y/n: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo -e '\0033\0143'
	chmod a+x ./adb
	echo -e "${cya}Firing up ADB 1.0.31...${txtrst}"
	./adb start-server
	echo -e "${cya}Waiting for device - make sure device is connected in ${bldcya}debugging mode${txtrst}"
	./adb wait-for-device
	echo -e "${cya}Installing apk to device...${txtrst}"
	./adb install $appname.apk
	echo -e "${bldgrn}Done. Exiting...${txtrst}"
	./adb kill-server
	exit 0
else
	echo -e ""
	read -p "Press any key to exit."
	exit 0
fi
