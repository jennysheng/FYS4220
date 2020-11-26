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

/* Definition of Task Stacks */
#define   TASK_STACKSIZE       2048
OS_STK task1_stk[TASK_STACKSIZE];
OS_STK task2_stk[TASK_STACKSIZE];
OS_EVENT *shared_jtag_sem;

/* Definition of Task Priorities */

#define TASK1_PRIORITY      1
#define TASK2_PRIORITY      2

/* Prints "Hello World" and sleeps for three seconds */
void task1(void* pdata) {

	int t_start;
	int t_end;
	int t_prev = 0;
	INT8U error_code = OS_NO_ERR;
	//Declare a pointer of type OS_EVENT.

	while (1) {
		t_start = OSTimeGet();
		char text1[] = "Hello from Task1\n";
		int i;
		OSSemPend(shared_jtag_sem, 0, &error_code);
		for (i = 0; i < strlen(text1); i++) {
			putchar(text1[i]);
		}
		t_end = OSTimeGet();
		printf("T1:(Start, END, Ex.T.,P): (%d, %d, %d,%d)\n", t_start, t_end,
				t_end - t_start, t_start - t_prev);
		OSSemPost(shared_jtag_sem);
		t_prev = t_start;
		OSTimeDlyHMSM(0, 0, 0, 20);
	}
}

/* Prints "Hello World" and sleeps for three seconds */
void task2(void* pdata) {
	int t_start;
	int t_end;
	int t_prev = 0;
	INT8U error_code = OS_NO_ERR;
	//Declare a pointer of type OS_EVENT.


	while (1) {
		t_start = OSTimeGet();
		char text2[] = "Hello from Task2\n";
		int i;
		OSSemPend(shared_jtag_sem, 0, &error_code);
		for (i = 0; i < strlen(text2); i++) {
			putchar(text2[i]);
		}
		t_end = OSTimeGet();
		printf("T2:(Start, END, Ex.T.,P): (%d, %d, %d,%d)\n", t_start, t_end,
				t_end - t_start, t_start - t_prev);
		OSSemPost(shared_jtag_sem);
		t_prev = t_start;
		OSTimeDlyHMSM(0, 0, 0, 4);
	}
}
/* The main function creates two task and starts multi-tasking */
int main(void) {

	printf("MicroC/OS-II Licensing Terms\n");
	printf("============================\n");
	printf(
			"Micrium\'s uC/OS-II is a real-time operating system (RTOS) available in source code.\n");
	printf("This is not open-source software.\n");
	printf(
			"This RTOS can be used free of charge only for non-commercial purposes and academic projects,\n");
	printf(
			"any other use of the code is subject to the terms of an end-user license agreement\n");
	printf(
			"for more information please see the license files included in the BSP project or contact Micrium.\n");
	printf(
			"Anyone planning to use a Micrium RTOS in a commercial product must purchase a commercial license\n");
	printf("from the owner of the software, Silicon Laboratories Inc.\n");
	printf("Licensing information is available at:\n");
	printf("Phone: +1 954-217-2036\n");
	printf("Email: sales@micrium.com\n");
	printf("URL: www.micrium.com\n\n\n");

	//create semaphores in the main() function before starting the multitasking system,
	//and initialize to 1. That is, the semaphore is available from start.
	//If initialize to 0, the semaphore is not available from start.
	shared_jtag_sem = OSSemCreate(1);

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
