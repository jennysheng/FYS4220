/*
 * "Hello World" example.
 *
 * code reference : https://controllerstech.com/adxl345-accelerometer-using-stm32/
 *
 */

#include <stdio.h>
#include <io.h>
#include <system.h>
#include <i2c_avalon_mm_if.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
#include "unistd.h"
#include <io.h>



#define ADXL345_DEVICE_ID_reg 0x00
#define ADXL345_DEVICE_addr 		0x53
#define ADXL345_POWER_CTL_Reg 0x2D
#define ADXL345_dataformat_reg 0x31 //4g-select
#define ADXL345_dataformat 0x31
#define ADXL345_x_axis_DATAX0  0x32
#define ADXL345_x_axis_DATAX1  0x33
#define ADXL345_y_axis_DATAY0  0x34
#define ADXL345_y_axis_DATAY1  0x35
#define ADXL345_z_axis_DATAZ0  0x36
#define ADXL345_z_axis_DATAZ1  0x37
#define ADXL345_INT_ENABLE     0x2E




int main()
{
	//Reads back the device ID of the ADXL345
	//Configures the ADXL345 sensor to use 4 g resolution
	//And then continuously reads back the accelerometer data registers and prints the result to stdout.

	printf("Hello from Nios II!\n");

	init();
	checkID();
	readXYZ();

	return 0;
}
//INITIALIZATION
//Before writing the code, just make sure that everything is alright by checking the DEVID of the device. The DEVID register (0x00)
//holds a fixed device ID code of 0xE5 . If the code matches 0xE5, we can proceed further.

void checkID(){
	alt_u8 data;
	read_from_i2c_device(ADXL345_DEVICE_addr,ADXL345_DEVICE_ID_reg, 0x01,&data);
	printf("0x%x.\n" , data);

}








//In order to initialize ADXL345, we need to modify POWER_CTL Register (0x2D)
//and DATA_FORMAT Register (0x31).
void init(){

	write_to_i2c_device(ADXL345_DEVICE_addr, ADXL345_POWER_CTL_Reg, 0x01, 0x00);// reset all bits.
	//adxl_write (0x2d, 0x08);  // measure and wake up 8hz
	write_to_i2c_device(ADXL345_DEVICE_addr, ADXL345_POWER_CTL_Reg, 0x01, 0x08);//  // measure and wake up 8hz
	//adxl_write (0x31, 0x01);  // data_format range= +- 4g
	write_to_i2c_device(ADXL345_DEVICE_addr, ADXL345_dataformat_reg, 0x01, 0x01);//



}
void readXYZ(){
	alt_u8 dataX0_raw;
	alt_u8 dataX1_raw;
	alt_u8 dataY0_raw;
	alt_u8 dataY1_raw;
	alt_u8 dataZ0_raw;
	alt_u8 dataZ1_raw;


	while(1){
		// HAL_I2C_Mem_Read (&hi2c1, adxl_address, reg, 1, (uint8_t *)data_rec, 6, 100);

		read_from_i2c_device(ADXL345_DEVICE_addr, ADXL345_x_axis_DATAX0, 6, &dataX0_raw);
		printf("%u \n" , dataX0_raw);
		read_from_i2c_device(ADXL345_DEVICE_addr, ADXL345_x_axis_DATAX1, 6, &dataX1_raw);
		printf("%u \n" , dataX1_raw);
		read_from_i2c_device(ADXL345_DEVICE_addr, ADXL345_y_axis_DATAY0, 6, &dataY0_raw);
		printf("%u \n" , dataY0_raw);
		read_from_i2c_device(ADXL345_DEVICE_addr, ADXL345_y_axis_DATAY1, 6, &dataY1_raw);
		printf("%u \n" , dataY1_raw);
		read_from_i2c_device(ADXL345_DEVICE_addr, ADXL345_z_axis_DATAZ0, 6, &dataZ0_raw);
		printf("%u \n" , dataZ0_raw);
		read_from_i2c_device(ADXL345_DEVICE_addr, ADXL345_z_axis_DATAZ1, 6, &dataZ1_raw);
		printf("%u \n" , dataZ1_raw);

	}
	//Keep in mind that the values read from the data registers har formatted as
	//16-bit two's complement. For Nios II, signed types are represented in two's complement??

}









