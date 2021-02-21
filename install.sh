#!/bin/bash

UDEV_RULES_LOCATION="/etc/udev/rules.d"
UDEV_RULE="40-stlink.rules"
SCRIPT_LOCATION="/usr/local/bin"
SCRIPT="udev-stlink.sh"
SER2NET_LOCATION="/etc/stlink_ser2net.conf"
SER2NET_BAUD="115200"

# Check if running as root
if [ "$EUID" -ne 0 ]
  then printf "Please run as root.\n"
  exit 1; 
fi

# Make sure prerequisites are installed, if not, install them
if ! [ -x "$(command -v st-util)" ]; then
    printf "Package stlink-tools does not exist, please install to continue!\n"
    exit 1;
fi

if ! [ -x "$(command -v at)" ]; then
    printf "Package at does not exist, please install to continue!\n"
    exit 1;
fi

if ! [ -x "$(command -v ser2net)" ]; then
    printf "Package ser2net does not exist, please install to continue!\n"
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

# Autogenerate ser2net conf
touch $SER2NET_LOCATION
echo -e "# This file is automatically generated by remote-stm32 installation. \n" > $SER2NET_LOCATION
echo "BANNER:banner:\r\nConnected to $(hostname) on port \p, device \d [\s]\r\n\r\n" >> $SER2NET_LOCATION
echo "8686:telnet:600:/dev/ttySTLink:$SER2NET_BAUD 8DATABITS NONE 1STOPBIT banner" >> $SER2NET_LOCATION

# Finish up
printf "Restarting udev...\n"
udevadm control --reload-rules && udevadm trigger

printf "All done!\n"
exit 0;
