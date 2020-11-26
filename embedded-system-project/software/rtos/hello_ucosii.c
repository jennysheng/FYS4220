/*************************************************************************
 * Copyright (c) 2004 Altera Corporation, San Jose, California, USA.      *
 * All rights reserved. All use of this software and documentation is     *
 * subject to the License Agreement located at the end of this file below.*
 **************************************************************************
 * Description:                                                           *
 * The following is a simple hello world program running MicroC/OS-II.The *
 * purpose of the design is to be a very simple application that just     *
 * demonstrates MicroC/OS-II running on NIOS II.The design doesn't account*
 * for issues such as checking system call return codes. etc.             *
 *                                                                        *
 * Requirements:                                                          *
 *   -Supported Example Hardware Platforms                                *
 *     Standard                                                           *
 *     Full Featured                                                      *
 *     Low Cost                                                           *
 *   -Supported Development Boards                                        *
 *     Nios II Development Board, Stratix II Edition                      *
 *     Nios Development Board, Stratix Professional Edition               *
 *     Nios Development Board, Stratix Edition                            *
 *     Nios Development Board, Cyclone Edition                            *
 *   -System Library Settings                                             *
 *     RTOS Type - MicroC/OS-II                                           *
 *     Periodic System Timer                                              *
 *   -Know Issues                                                         *
 *     If this design is run on the ISS, terminal output will take several*
 *     minutes per iteration.                                             *
 **************************************************************************/

#include <stdio.h>
#include "includes.h"
#include <string.h>
#include "acc.h"
#include <system.h>
#include <i2c_avalon_mm_if.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
#include "unistd.h"
#include <io.h>



/* Definition of Task Stacks */
#define   TASK_STACKSIZE       2048
OS_STK task1_stk[TASK_STACKSIZE];
OS_STK task2_stk[TASK_STACKSIZE];
OS_EVENT *key1pressed;
OS_EVENT *swTime;

/* Definition of Task Priorities */

#define TASK1_PRIORITY      	 1// check ISR key1
#define TASK2_PRIORITY           2

/*The position or value of the slide swithces will be loaded when KEY1 is pressed
 * (ext_ena_n in the VHDL design). When pressed, this key will trigger the interrupt routine.
 *  To decrease the time spent in the interrupt routine, you will use a semaphore to synchronize
 *  ?? the interrupt event with another task that checks the interrupt condition and performs
 *   the required operation. This task will use the value of the slides swithces to calculate
 *   the new time interval for the readout of the accelerometer. The result will then be sent to
 *   another task through a message mailbox. The task receiving the message is the tasks that reads
 *   out the accelerometer. The value received will be used to set a new timeout value for the
 *   OSMBoxPend function that is used to receive the message. The intertask communication is
 *   illustrated in figure 97

 */
void task1(void* pdata) {

	int t_start;
	int t_end;
	int t_prev = 0;
	INT8U error_code = OS_NO_ERR;

	INT8U sw;
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(INTERRUPT_PIO_BASE, 0x7); //enable 3 interrupts input key1 and sw and led
	while (1) {
		t_start = OSTimeGet();

		if (OSSemAccept(key1pressed))
			OSSemPend(key1pressed, 0, &error_code);
		sw = 50 * IORD(SW_PIO_BASE, 0) & 0x0F;

		t_end = OSTimeGet();
		printf("T1:(Start, END, Ex.T.,P): (%d, %d, %d,%d)\n", t_start, t_end,
				t_end - t_start, t_start - t_prev);
		OSSemPost(key1pressed);
		OSMboxPost(swTime, (void*) &sw);
		t_prev = t_start;

		//	OSTimeDly(sw); // delay switch time.
	}
}

void task2(void* pdata) {
	int t_start;
	int t_end;
	int t_prev = 0;
	INT8U timeout=0;
	INT8U err;
	INT8U error_code = OS_NO_ERR;
init();

	//Declare a pointer of type OS_EVENT.

	while (1) {
		t_start = OSTimeGet();
		OSSemPend(key1pressed, 0, &error_code);

		t_end = OSTimeGet();
		printf("T2:(Start, END, Ex.T.,P): (%d, %d, %d,%d)\n", t_start, t_end,
				t_end - t_start, t_start - t_prev);
	     checkID();
	     readXYZ();
		if (OSMboxPend(swTime, timeout, &err)) {
			readXYZ();
			OSSemPost(key1pressed);
			t_prev = t_start;
			OSTimeDly(swTime);
		}
	}
}
/* The main function creates two task and starts multi-tasking */
int main(void) {

	//create semaphores in the main() function before starting the multitasking system,
	//and initialize to 1. That is, the semaphore is available from start.
	//If initialize to 0, the semaphore is not available from start.
	key1pressed = OSSemCreate(1);
	altera_nios2_gen2_irq_init();	//enable internal interrupt
	//init_interrupt_pio();

	OSTaskCreateExt(task1,
	NULL, (void *) &task1_stk[TASK_STACKSIZE - 1],
	TASK1_PRIORITY,
	TASK1_PRIORITY, task1_stk,
	TASK_STACKSIZE,
	NULL, 0);

	OSTaskCreateExt(task2,
	NULL, (void *) &task2_stk[TASK_STACKSIZE - 1],
	TASK2_PRIORITY,
	TASK2_PRIORITY, task2_stk,
	TASK_STACKSIZE,
	NULL, 0);
	//Prototype functions for OSSemPend and OSSemPost
	//void OSSemPend(OS_EVENT *pevent, INT16U timeout, INT8U *err);

	//INT8U OSSemPost(OS_EVENT *pevent);

	OSStart();
	return 0;
}

/******************************************************************************
 *                                                                             *
 * License Agreement                                                           *
 *                                                                             *
 * Copyright (c) 2004 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved.                                                        *
 *                                                                             *
 * Permission is hereby granted, free of charge, to any person obtaining a     *
 * copy of this software and associated documentation files (the "Software"),  *
 * to deal in the Software without restriction, including without limitation   *
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
 * and/or sell copies of the Software, and to permit persons to whom the       *
 * Software is furnished to do so, subject to the following conditions:        *
 *                                                                             *
 * The above copyright notice and this permission notice shall be included in  *
 * all copies or substantial portions of the Software.                         *
 *                                                                             *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
 * DEALINGS IN THE SOFTWARE.                                                   *
 *                                                                             *
 * This agreement shall be governed in all respects by the laws of the State   *
 * of California and by the laws of the United States of America.              *
 * Altera does not recommend, suggest or require that this reference design    *
 * file be used in conjunction or combination with any other product.          *
 ******************************************************************************/
