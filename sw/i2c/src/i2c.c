#include <bcm2835.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define SLAVE_ADDR 0x55 //Slave Addres
#define BAUDERATE 100000 //100kHz
#define RAM_REG 0x04 //EEPROM address register. Each address has 16 bytes of data. 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// To test without the NFC Shield, enter manually a MAC address : 94:B1:0A:CD:1C:81 into char tab[].
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int main(void){
	char buf[] = {RAM_REG};
	char buf2[16];

	char* bt_adr;

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

	char integer_string[16];
	strcpy(integer_string,"");
    char tmp[32];
    int lol;
    int i = 0;
	printf("%s\n",integer_string );
    for (i = sizeof(buf2)-6; i>=5; i--)
    {	
    	lol = 0;
    	strcpy(tmp,"");
        lol = buf2[i];
        sprintf(tmp, "%x", lol);
        strcat(integer_string ,tmp);
        if (i!=5)
        {
        	strcat(integer_string ,":");
        }

    }
	printf("Read Buf2 is : %s\n",integer_string);

}	
