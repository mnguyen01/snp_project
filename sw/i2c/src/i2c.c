#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <wiringPiI2C.h>

#define SLAVE_ADDR 0x55

int main(void){
	int ack = wiringPiI2CSetup (SLAVE_ADDR);

	printf("device name is : %d\n", ack);
}