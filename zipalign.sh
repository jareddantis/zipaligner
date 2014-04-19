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

# Phase 1
echo -e "${bldcya}Enter the name of the apk you want to sign."
echo -e "${bldcya}Example: ${cya}SystemUI"
echo -e ""
echo -e "${bldred}NOTES:"
echo -e "${cya}What you enter here will also be the filename of your final APK."
echo -e "${cya}APK must be in the same folder as this script."
echo -n "Filename: "
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
echo -e "${bldgrn}Signing APK..."
java -jar signapk.jar testkey.x509.pem testkey.pk8 $appname.apk temp.apk

# Check existence
if [ -f temp.apk ]
	then
		mv $appname.apk $appname-original.apk
		clear
		echo -e "${bldgrn}Zipaligning..."
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
		echo -e ""
		read -p "Press any key to exit."
		exit 0
	else
		echo -e "${bldred}FATAL: Final APK does not exist. Exiting..."
		exit 1
fi