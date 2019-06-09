#!/usr/bin/python
import smbus

#SLAVE READ ADDRESS IS: 0X55h 

bus = smbus.SMBus(1)

DEVICE_ADDRESS = 0x55



