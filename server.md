# Remote Programming Server Configuration #

## Prerequisites ##

* Raspberry Pi with current version of [Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/)
* STLink debugger (ideally v2 or higher)
* Remotely accessible network (eg. a VPN)

## Installation ##

The installation steps are handily condensed into a bash install script for convenience. 
To install:

1. It is recommended to run an update: `sudo apt-get update && sudo apt-get update -y`
Also, it is recommended to use `sudo raspi-config` to change the username/password to something not default and to change the hostname to something relevant. 
The hostname is what clients will use to connect to the server. 

2. Clone this repo: `git clone THIS STUPID LINK` and install the dependencies: `sudo apt-get install at stlink`

3. Run the install script with sudo: `sudo bash install.sh`
**The STLink debugger should be unplugged for this step.**
This script will copy the necessary files into the correct locations and then restart udev.

4. Test: Plug the STLink debugger into any USB port on the Pi. Run `ps aux | grep 'st-util' | grep -v grep` and verify that the `st-util` process exists.  

At this point, the Pi now has a GDB server running on it. Make sure that other devices can connect to it by following the [client install guide](client.md)

## How It Works ##

This is based on [stlink](https://github.com/stlink-org/stlink), an open source version of the ST debugging tools. 
It comes with a GDB server though `st-util`; however, the device must be connected for it to run.

Ordinarily, this means that any time a device is connected or removed, someone would need to connect to the Pi and start or stop the server manually.
To keep the server as low-maintenance as possible, this process is automated using udev rules. 

When an STLink debugger is plugged in or removed (identified by the vendor/device ID), udev will execute a script that will either start or stop the `st-util` server.

## Troubleshooting ##

Something not right? Start by reading the device logs at LOCATION to see what happened. 

**st-util doesn't start!**

This could be due to a number of things. 

First, verify that the device that you are plugging in is a genuine STLink device. 
When the STLink is plugged in, run `lsusb` and make note of the VendorID:DeviceID. 
The Vendor ID should be 0483, and the Device ID should be one of the STLink devices listed [here](https://usb-ids.gowdy.us/read/UD/0483). 

If it is not, change the `40-stlink.rules` to add an add and remove rule for your particular VendorID/DeviceID. 
By default, udev looks for devices with Vendor ID 0483 (STMicroelectronics) with a Device ID corresponding to a STLink v1, v2/2.1, or a v3. 
The server will only automatically start when the udev rules are activated. 

Additionally, check that the script to start the server is working properly: `sudo bash /usr/local/bin/udev-stlink.sh add` should result in the GDB server starting if the ST-Link is connected.

**st-util starts, but then exits immediately!**

For some reason, st-util cannot attach to the STLink. 
Try running `st-util` manually with increased verbosity to determine what is happening. 

**[Insert complaint here]!**

Submit an issue!
