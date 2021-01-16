#!/bin/bash

UDEV_RULES_LOCATION="/etc/udev/rules.d"
UDEV_RULE="40-stlink.rules"
SCRIPT_LOCATION="/usr/local/bin"
SCRIPT="udev-stlink.sh"

# Check if running as root
if [ "$EUID" -ne 0 ]
  then printf "Please run as root.\n"
  exit 1; 
fi

# Make sure prerequisites are installed, if not, install them
if [ ! dpkg -l stlink &> /dev/null ]; then
    printf "Package stlink does not exist, please install to continue!\n"
    exit 1;
fi

if [ ! dpkg -l at &> /dev/null ]; then
    printf "Package at does not exist, please install to continue!\n"
    exit 1;
fi

# Make sure that the file locations exist
if [ ! -d $SCRIPT_LOCATION ]; then
    printf "$SCRIPT_LOCATION does not exists, creating directory...\n"
    mkdir -p -m 755 $SCRIPT_LOCATION > /dev/null
fi

if [ ! -d $UDEV_LOCATION ]; then
    printf "$UDEV_LOCATION does not exist, creating directory...\n"
    mkdir -p -m 755 $UDEV_RULES_LOCATION > /dev/null
fi

# Verify that this directory has the correct files to copy
if [ ! \( -f $UDEV_RULE -a -f $SCRIPT \) ]; then
    printf "Incorrect run location: files to copy not found.\n"
    exit 1;
fi

# Copy files to the correct place
printf "Copying $SCRIPT to $SCRIPT_LOCATION/$SCRIPT...\n"
\cp -f $SCRIPT $SCRIPT_LOCATION/$SCRIPT > /dev/null
chmod +x $SCRIPT_LOCATION/$SCRIPT

printf "Copying $UDEV_RULE to $UDEV_RULES_LOCATION/$UDEV_RULE...\n"
\cp -f $UDEV_RULE $UDEV_RULES_LOCATION/$UDEV_RULE > /dev/null

# Finish up
printf "Restarting udev...\n"
udevadm control --reload-rules && udevadm trigger

printf "All done!\n"
exit 0;
