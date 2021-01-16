# remote-stm32 #

A remote programming configuration for flashing/debugging an STM32 MCU from anywhere in the world!

This consists of two parts: a Raspberry Pi running a GDB server that is physically connected to the target STM32, and a client connected to that server via a VPN.

![Block diagram](./block-diagram.png)

**NOTE: This is super untested!** 
I'm working on it, but for now nothing is guaranteed to work.

## Installation ##

[Server Configuration](server.md)

[Client Configuration](client.md)
