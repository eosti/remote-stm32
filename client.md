# remote-stm32 Client Configuration #

## Prerequisites ##

* Computer with STM32CubeIDE (or any Eclipse-based IDE)
* [arm-none-eabi-gdb](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) 
*Note that the version in package managers is quite outdated because [they stopped updating it](https://launchpad.net/gcc-arm-embedded). You should instead use the version hosted on their website.* 
* Network access to the GDB server

## Configuration ##

1. Open STM32CubeIDE and go to Run > Debug Configurations
2. Create a new GDB Hardware Debugging configuration by right-clicking the entry "GDB Hardware Debugging" and selecting "New Configuration"
3. Under the Debugger tab, change the following fields:
    * GDB Command should be `arm-none-eabi-gdb`
    * Check the Remote Target box
    * Change the JTAG Device to ST-LINK (ST-LINK GDB Server)
    * Fill in the Host Name or IP Address and Port fields -- the default port is 4242, consult the server host to determine the IP address
4. Save this configuration
5. To debug, click the down-arrow to the right of the debug button and select the new debug configuration

## Troubleshooting ##

**I get the error "I'm sorry Dave, I can't do that. Symbol format 'elf32-littlearm' unknown"**

Make sure you specified that the debugger should use `arm-none-eabi-gdb`, not just plain old `gdb`

**I get the error "Non-stop mode requested, but remote does not support non-stop"**

Yeah, this is a weird one. The answer is that you're using the STM32 Application debug, not the GDB Hardware Debugging. 
Switch to the vanilla GDB Hardware Debugging and you should be all set.

Incidentally, the setting for GDB non-stop mode in Preferences doesn't seem to do a thing. 
I'm still working on this, but for now, you probably won't be able to use SWO. Sorry. 

**I get the error "Operation timed out"**

This could be caused by a number of things. 
Make sure that the server details are entered correctly, if this is the first time to connect.

Make sure that you are the only one attempting to debug: only one connection to the GDB server can be active at a time!

Finally, try bugging the person hosting the server to check if it's actually up. 

**[Insert complaint here]!**

Submit an [issue](https://github.com/eosti/remote-stm32/issues)!
