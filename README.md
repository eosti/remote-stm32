# remote-stm32 #

A remote programming configuration for flashing/debugging an STM32 MCU from anywhere in the world.

This consists of two parts: a Raspberry Pi physically connected to the target STM32, running a GDB server, and a client connected to that server via a VPN.

*NOTE: This is super untested!* 
I'm working on it, but for now nothing is guarenteed to work

## Installation ##

[Server Configuration](server.md)

[Client Configuration](client.md)
