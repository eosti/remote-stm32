# remote-stm32 #

A remote programming configuration for flashing/debugging an STM32 MCU from anywhere in the world!

This consists of two parts: a Raspberry Pi that is physically connected to the target STM32, and a client connected to that server via a VPN.
The Pi runs a GDB server for uploading and debugging code, as well as a serial port forwarder, so that the client can view and interact with the output of a UART interface on the STM32. 

![Block diagram](./block-diagram.png)

Tested and working on MacOS and Windows 10 clients, with STM32H7 and STM32F3 targets. All boards that are supported by [stlink-tools](https://github.com/stlink-org/stlink/blob/develop/doc/devices_boards.md) should be supported here as well.

## Installation ##

[Server Configuration](server.md)

[Client Configuration](client.md)
