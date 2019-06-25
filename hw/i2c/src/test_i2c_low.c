#include "xparameters.h"
#include "xiic.h"
#include "xil_io.h"
#include "xil_printf.h"

#define IIC_BASE_ADDRESS	XPAR_IIC_0_BASEADDR
#define EEPROM_TEST_START_ADDRESS	4
#define EEPROM_ADDRESS		0x55
#define PAGE_SIZE	16
#define IIC_SLAVE_ADDRESS	1

int main(void)
{
	int Status;
	u8 ReadBuffer[PAGE_SIZE] = {0};
	u8 WriteBuffer[1] = {EEPROM_TEST_START_ADDRESS};


	/*
	 * Initialize the IIC Core.
	 */
	Status = XIic_DynInit(IIC_BASE_ADDRESS);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

		/*
	 * Make sure all the Fifo's are cleared and Bus is Not busy.
	 */
	while (((StatusReg = XIic_ReadReg(IIC_BASE_ADDRESS,
				XIIC_SR_REG_OFFSET)) &
				(XIIC_SR_RX_FIFO_EMPTY_MASK |
				XIIC_SR_TX_FIFO_EMPTY_MASK |
				XIIC_SR_BUS_BUSY_MASK)) !=
				(XIIC_SR_RX_FIFO_EMPTY_MASK |
				XIIC_SR_TX_FIFO_EMPTY_MASK)) {

	}

	
	XIic_Send7BitAddress(IIC_BASE_ADDRESS, EEPROM_ADDRESS, XIIC_WRITE_OPERATION);
	XIic_Send(IIC_BASE_ADDRESS, EEPROM_ADDRESS, WriteBuffer, 1, XIIC_STOP)
	XIic_DynSendStop(IIC_BASE_ADDRESS, 1);

	usleep(60);

	XIic_DynSend7BitAddress(IIC_BASE_ADDRESS,EEPROM_ADDRESS XIIC_READ_OPERATION);
	XIic_Recv(IIC_BASE_ADDRESS, EEPROM_ADDRESS, ReadBuffer, PAGE_SIZE, XIIC_STOP);

	xil_printf("DATA IS : %d", ReadBuffer[0]);

} 