#!/bin/bash

export ST_LOG=/tmp/stutil.log
export SER2NET_CONFIG=/etc/stlink_ser2net.conf

printf "\n.\n" >> $ST_LOG
date >> $ST_LOG
logger -s "remote-stm32 udev rule triggered for USB action: $1." >> $ST_LOG

sleep 1

# Is there currently an instance of st-util?
ps auxw | grep st-util | grep -v grep > /dev/null

# If there is, kill it!
if [ $? == 0 ]; then	
	printf "Current st-util instance detected, killing it. \n" >> $ST_LOG
	killall st-util
    killall ser2net
fi

if [ $1 == "remove" ]; then
    # Device removed, server killed, we're done here!
	logger -s "STLink server killed, exiting." >> $ST_LOG

elif [ $1 == "add" ]; then
	# Start STLink GDB Server without this script as its parent
	logger -s "Starting st-util server" >> $ST_LOG
	echo "st-util -m >> $ST_LOG 2>&1" | at now
    
    # Check for existance of the STLink UART device
    if [ -e "/dev/ttySTLink" ]; then
        # Start ser2net server without this script as its parent
        logger -s "Starting ser2net server" >> $ST_LOG
        echo "ser2net -c $SER2NET_CONFIG >> $ST_LOG 2>&1" | at now
    fi

	sleep 1
else
	# Something very bad happened to get here
	logger -s "Invalid or no input to remote-stm32, exiting." >> $ST_LOG
	exit 1
fi

# Clean up and exit
printf "\n" >> $ST_LOG
exit 0;
