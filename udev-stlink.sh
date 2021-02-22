#!/bin/bash

export ST_LOG=/tmp/stutil.log
export SER2NET_CONFIG=/etc/stlink_ser2net.conf

printf "\n.\n" >> $ST_LOG
date >> $ST_LOG
logger -s "remote-stm32 udev rule triggered for USB action: $1." >> $ST_LOG 2>&1

sleep 1

# We start by ensuring that only one instance of both ser2net and stlink exist at a time

# Is there currently an instance of st-util?
ps auxw | grep st-util | grep -v grep > /dev/null

# If there is, kill it (unless we're starting the ser2net instance)!
if [ $? == 0 ] && [ $1 != "uart" ]; then
    printf "Current st-util instance detected, killing it. \n" >> $ST_LOG
    killall st-util > /dev/null
fi

# Is there currently an instance of ser2net?
ps auxw | grep ser2net | grep -v grep > /dev/null

# If there is, kill it (unless we're starting stlink)!
if [ $? == 0 ] && [ $1 != "add" ]; then
    printf "Current ser2net instance detected, killing it. \n" >> $ST_LOG
    killall ser2net > /dev/null 
fi

# We now restart the appropriate services, if requested

if [ $1 == "remove" ]; then
    # Device removed, server killed, we're done here!
    logger -s "STLink server killed, exiting." >> $ST_LOG 2>&1

elif [ $1 == "add" ]; then
    # Start STLink GDB Server without this script as its parent
    logger -s "Starting st-util server" >> $ST_LOG 2>&1
    echo "st-util -m >> $ST_LOG 2>&1" | at now

elif [ $1 == "uart" ]; then
    # STLink UART device created, so begin ser2net
    logger -s "Starting ser2net server" >> $ST_LOG 2>&1
    echo "ser2net -c $SER2NET_CONFIG >> $ST_LOG 2>&1" | at now

else
    # Something very bad happened to get here
    logger -s "Invalid or no input to remote-stm32, exiting." >> $ST_LOG 2>&1
    exit 1
fi

# Clean up and exit
printf "\n" >> $ST_LOG
exit 0;
