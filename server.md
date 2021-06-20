# remote-stm32 Server Configuration #

## Prerequisites ##

* Raspberry Pi with current version of [Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/)
* ST-LINK debugger (ideally v2 or higher)
* Remotely accessible network (eg. a VPN)

## Installation ##

The installation steps are handily condensed into a bash install script for convenience. 
To install:

1. Make sure everything is up to date: `sudo apt-get update && sudo apt-get upgrade -y`
It is also recommended to run `sudo raspi-config` to set time zone localization, change the default login/password, and to set an appropriate hostname.

2. Install the dependencies: `sudo apt-get install -y at git ser2net stlink-tools`. 
Note: stlink-tools MUST >= v1.7.0 for H7-series MCUs. Some package managers still don't have this updated version, so you may need to install [from source](https://github.com/stlink-org/stlink/blob/develop/doc/compiling.md#Linux)

3. Clone this repo: `git clone https://github.com/eosti/remote-stm32.git` 

4. Enter the remote-stm32 directory with `cd remote-stm32` and run the install script with sudo: `sudo bash install.sh`
**The ST-LINK debugger should be unplugged for this step.**
This script will copy the necessary files into the correct locations and then restart udev.

4. Test: Plug the ST-LINK debugger into any USB port on the Pi. Run `ps aux | grep 'st-util' | grep -v grep` and verify that the `st-util` process exists.  

At this point, the Pi now has a GDB server running on it! 
The server will start any time a ST-LINK device is plugged into it, and will automatically exit after the ST-LINK device is removed.
It may be useful to double check everything is working as planned by using the [client install guide](client.md) to test the debugging capabilities.

This installation also includes a UART forwarder. 
On ST-LINK devices that support UART passthough, that serial device will be exposed to the network.
By default, the program expects the UART at 115200 baud -- if this is not what you want, change the appropriate variable in `install.sh`.

## How It Works ##

This is based on [stlink](https://github.com/stlink-org/stlink), an open source version of the ST debugging tools. 
It comes with a GDB server though `st-util`; however, the device must be connected for it to run.

Ordinarily, this means that any time a device is connected or removed, someone would need to connect to the Pi and start or stop the server manually.
To keep the server as low-maintenance as possible, this process is automated using udev rules. 

When an ST-LINK debugger is plugged in or removed (identified by the vendor/device ID), udev will execute a script that will either start or stop the `st-util` server.

If the device also includes a serial modem, it will be symlinked to `/dev/ttySTLink` and [ser2net](https://github.com/cminyard/ser2net) will attach to it.
ser2net will expose that serial modem to port 8686, which can be accessed through `telnet`.

The GDB server is then available in the local network for clients to connect to on port 4242.
If there is a serial modem detected, it will be made available for `telnet` connections on port 8686.

## Troubleshooting ##

Something not right? Start by reading the device logs at `/tmp/stutil.log` to see what happened. 

**st-util doesn't start!**

This could be due to a number of things. 

First, verify that the device that you are plugging in is a genuine ST-LINK device. 
When the ST-LINK is plugged in, run `lsusb` and make note of the VendorID:DeviceID. 
The Vendor ID should be 0483, and the Device ID should be one of the ST-LINK devices listed [here](https://usb-ids.gowdy.us/read/UD/0483). 

If it is not, change the `40-stlink.rules` to add a ruleset for your particular VendorID/DeviceID. 
By default, udev looks for devices with Vendor ID 0483 (STMicroelectronics) with a Device ID corresponding to a ST-LINK v1, v2/2.1, or a v3. 
The server will only automatically start when the udev rules are activated. 

Additionally, check that the script to start the server is working properly: `sudo bash /usr/local/bin/udev-stlink.sh add` should result in the GDB server starting if the ST-Link is connected.

**st-util starts, but then exits immediately!**

For some reason, st-util cannot attach to the ST-LINK. 
Try running `st-util` manually with increased verbosity to determine what is happening. 

**ser2net never starts!**

If st-util is working fine, then this is likely due to the absence of an appropriate serial device to connect to.
Ensure that the ST-LINK that you have has a serial modem, and that it is accessible via USB.
When plugged into the RPi, it should also be mapped to `/dev/ttyACMx`, so check that using `screen` or your serial program of choice.

**I can connect to ser2net, but it's all gibberish!**

Ensure that your head did not come into contact with the keyboard during the typing of any UART debugging messages.
After all, garbage in, garbage out. 

The issue is likely a mis-matched baud rate: ser2net defaults to 115200 baud.
If you deem this baud rate unworthy for your device, change the `SER2NET_BAUD` variable in `install.sh` and reinstall. 

**[Insert complaint here]!**

Submit an [issue](https://github.com/eosti/remote-stm32/issues)!
