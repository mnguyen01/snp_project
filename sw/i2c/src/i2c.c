#include <bcm2835.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define SLAVE_ADDR 0x55 //Slave Addres + '0' --> 1010101 + '0'
#define MEMA 0xF8
#define BAUDERATE 100000 //100kHz
#define RAM_REG 

char *bt_addr(char *buf[]);

int main(void){
	char buf[1];
	char buf1[1];
	char buf2[16];
	int i;
	
	if(!bcm2835_init()){
		printf("bcm2835_init failed. Are you running as root??\n");
     	return 1;
	}
	bcm2835_i2c_set_baudrate(BAUDERATE);
	
	bcm2835_i2c_begin();
	bcm2835_i2c_setSlaveAddress(SLAVE_ADDR);
	buf[0] = 0x04;
	int ack = bcm2835_i2c_write(buf,1);
	printf("ACK : %d\n", ack);
	bcm2835_i2c_end();

	bcm2835_delayMicroseconds(60);

	bcm2835_i2c_begin();
	bcm2835_i2c_setSlaveAddress(SLAVE_ADDR);
	int ack2 = bcm2835_i2c_read(buf2,16);
	printf("ACK2 : %d\n", ack2);
	for(i=0;i<16;i++)
	{
		printf("Read Buf[%d] = %x\n", i, buf2[i]);
	}
	bcm2835_i2c_end();

	char *addr = bt_addr(buf2);

	printf("%s\n", );


}	


char *bt_addr(char *buf[])
{
	int i = 0;
	char *bt_addr[128];

	for(i = sizeof(buf); i<= 0 ; i--)
	{
		printf("Read Buf2[%d] = %x\n", i, buf[i]);

	}
	return bt_addr;
}
