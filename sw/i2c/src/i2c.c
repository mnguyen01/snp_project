#include <bcm2835.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define SLAVE_ADDR 0x55
#define MEMA 0xF8
#define BAUDERATE 100000 //100kHz


int main(void){
	
	if(!bcm2835_init()){
		printf("bcm2835_init failed. Are you running as root??\n");
     	return 1;
	}
	
	bcm2835_i2c_begin();
	bcm2835_i2c_setSlaveAddress(SLAVE_ADDR);
	bcm2835_i2c_set_baudrate(BAUDERATE)

	while(1){
		
	}
}