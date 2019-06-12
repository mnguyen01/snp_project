#include <bcm2835.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

//Define constant
#define SLAVE_ADDR 0x55 //Slave Addres
#define BAUDERATE 100000 //100kHz
#define RAM_REG 0x04 //EEPROM address register. Each address has 16 bytes of data. 

//Define function prototype
void get_mac_addr(const char * mac, char * mac_string);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// To test without the NFC Shield, enter manually a MAC address : 94:B1:0A:CD:1C:81 into char tab[].
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int main(void){
	char buf[1] = {RAM_REG};
	unsigned char buf2[16] = {'\0'};

	char mac_string[12 + 5 + 1] = { '\0' }; // 6 char + 5 `:` + NULL

	if(!bcm2835_init()){
		printf("bcm2835_init failed. Are you running as root??\n");
     	return 1;
	}
	bcm2835_i2c_set_baudrate(BAUDERATE);
	
	bcm2835_i2c_begin();
	bcm2835_i2c_setSlaveAddress(SLAVE_ADDR);
	bcm2835_i2c_write(buf,1);
	bcm2835_i2c_end();

	bcm2835_delayMicroseconds(60); //c.f Datasheet : need at least 50us before starting a new write/read operation.

	bcm2835_i2c_begin();
	bcm2835_i2c_setSlaveAddress(SLAVE_ADDR);
	bcm2835_i2c_read(buf2,16);
	bcm2835_i2c_end();

	get_mac_addr(buf2, mac_string);

	return 0;

}	

void get_mac_addr(const char * mac, char * mac_string)
{
    snprintf(mac_string, sizeof(mac_string),
             "%02x:%02x:%02x:%02x:%02x:%02x",
             mac[10], mac[9], mac[8], mac[7], mac[6], mac[5]);
}