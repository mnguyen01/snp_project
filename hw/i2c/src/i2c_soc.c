#include "xparameters.h"
#include "xiic.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include <unistd.h>



#define IIC_DEVICE_ID		XPAR_IIC_0_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_INTC_0_DEVICE_ID
#define IIC_INTR_ID			XPAR_INTC_0_IIC_0_VEC_ID

#define SLAVE_ADDRESS		0x55
#define MEM_REG_ADDRESS 	0x04

volatile u8 TransmitComplete;

int main()
{
	int Status;
	XIic_Config *ConfigPtr;
	XIic IicInstance;
	unsigned char buf2[16] = {'\0'};
	unsigned char buf[1] = {MEM_REG_ADDRESS};
	TransmitComplete = 1;


    ConfigPtr = XIic_LookupConfig(IIC_DEVICE_ID);
    	if (ConfigPtr == NULL) {
    		return XST_FAILURE;
    	}

    Status = XIic_CfgInitialize(&IicInstance, ConfigPtr, ConfigPtr->BaseAddress);
    	if (Status != XST_SUCCESS) {
    		return XST_FAILURE;
    	}


	Status = XIic_SetAddress(&IicInstance, XII_ADDR_TO_SEND_TYPE,
				 SLAVE_ADDRESS);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	printf("ACK0 : %d\n", Status);

	Status = XIic_MasterSend(&IicInstance, buf, 1);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	printf("ACK1 : %d\n", Status);

	Status = XIic_Stop();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	printf("ACK2 : %d\n", Status); 


	usleep(60);

	printf("ACK3 : %d\n", Status);

	Status = XIic_MasterRecv(&IicInstance, buf2, 16);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	printf("ACK4 : %d\n", Status);

	printf("DATA IS : %x\n", buf2[5]);
