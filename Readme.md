# Git repository for < jenny > < sheng>

# Assignment progess

## Introductory assignment
 - Problem 1: <  completed >
 - Problem 2: <  completed >
 - Problem 3: <  completed >
 - Problem 4: <  completed >

## Embedded system project
 - Problem 5:  <  completed >
 - Problem 6: < started >
 - Problem 7: < started>
 - Problem 8: < not started | started | completed >


 # Answers to assignment questions

 ## Introductory assignment

 ### Exercise 1: Your first FPGA project

a) What is the meaning of the warning messages in the compilation report and why can we choose to ignore them at this stage?
 when we have  a process, there will be a system clock signal to control the process, the clock signal is not defined in our case.

b) What is the purpose of the entity and architecture description?
  entity is the pin mapping input and output with  the physical board, architecture is to declare funtionality of the program.
c) What is the purpose of the Tcl file used in this problem?
   physical pin mapping to the chip.

d) Can you briefly explain what the following Tcl statement is doing:
set_location_assignment PIN_C10 -to sw[0]
connect pin_c10 to an input switch in position 0;

e) Which VHDL statement is needed to connect the input ports to the output ports of your design?
    sw<=led;


 ### Excercise 2: Seven segment display.
 a) How many values can a 4-bit binary number represent, and can all of these numbers be shown on the seven segment display?

 2^4=16 Yes besides the  digits from 0 to 9, there should be A, B, C, D, E, F.

Hexadecimal represention.

b) The input port sw is a bundle / vector of 10 input while only 4 are needed to control the seven segment display. How can you address only parts of a std_logic_vector?
sw(3 downto 0)

 ### Excercise  3: Synchronous logic and test benches
 a) Which package is available in VHDL to arithmetic operations?
   IEEE.numeric_std.all;

b) What is the purpose of the process sensitivity list?
sensitivity list includes  synchrnous signal that may  trigger a process or resume a process => synchronous process
or asynchrous varibale that can control the process=> combinational process.


c) Why should an asynchronous reset signal be listed in the sentivitiy list and why should a synchronous rest signal not be listed?
a synchronous signal only refers to clock signal in our case, the asychrounous reset is an external control signal f.tx:
the reset button key0 is a asychronous reset, it doesn't detect the rising edge when we press it.

d) What is the standard method to check the behaviour of an HDL description?
   Test bench

e) Why is the entity description of a test bench empty?
This is because the test bench itself does not have any inputs or outputs. Test vectors are generated and applied to the unit under test within the test bench.

f) How can you model a 10 MHz clock signal in a VHDL test bench?
time analyser, create new sdc file and define the period to be 100ns.

g) Why does the stimuli process of a basic test bench not have a sensitivity list?
because it is syschronous, the clk will controll the process. it does not need external control signal


h) Why do you need to disable a the clock at the end of the stimuli process in the test bench?
to stop running the process. since the process is running as a loop, we only need to see one loop.

i) Why can the wait for and wait statements not be synthesized?
because it replace the sensitivity list, wait  it stops a synchronous process. wait for defines time scale for the process to be waited.

j) Can you think of a reason why for the first part of the simulation the value of the counter signal in figure 76 is 'U'? Was this the case for your simulation results?
yes, the counter is not initialized until a reset signal come.

k) What does this 'U' mean and how could you avoid it?
because the counter value is undefined. we need to signal counter: std_logic_vector(3 downto 0):='0000';

l) What happens when you press the push button KEY1 to start the counter, and can you explain why this happens?

without edge detection the key1 kan push a lot of clock cycles which cause the number increase very fast, after the edge detection , the number will increment one by one.

### Excercise 4: Synchronization and Edge detection.
a) What is the purpose of synchronization registers and when do you need to use them?
When sampling a signal from an asynchronous domain (e.g. a button push) or a signal crossing a clock domain, it is required to synchronize the signal to avoid a metastable condition.

### Excercise 5: I2C state machine.


a) Can you identify any limitations with the simulation approach used in this problem? That is, is there any functionality you are not able to fully verify, and do you have any suggestions for how these limitations can be overcome?
slave address is predefined, in phycial board, they should be responded by the slave. test with a physical board.

b) What is the purpose of the busy signal?

to make the line busy, not interrupt by other signal.

### Excercise 6:  Advanced test benches
a) Which function is available in the UVVM utility library to write log messages to a file?
log(...).

b) Which function is available in the UVVM utility library to generate a clock signal to be used in the test bench?
-- Bitvis clock generator
  clock_generator(clk, clk_ena, clk_period, "TB clock");


c) Why is the wait for 0 ns statement included in VHDL code below?

reg_addr_use <= reg_addr_device_id;
wait for 0 ns;
read_i2c(i2c_addr_adxl345, reg_addr_use, data_array_rd, 1);

 wait for the process to be updated.
 
d) What is the main purpose or advantage of adding the overloaded functions write_i2c and read_i2c in the i2c_master_adv_tb.vhd file?
To specify which signal in the i2c master are going to writen/read to/from.


e) What is the VHDL conditional statement that can be used to detect a rising edge on the busy signal from the I2C master module?

rising_edge(clk);

### Excercise 7: A Nios-II embedded system 
a) Why do the CPU have both a data master and data instruction interface?
a data master is  implemented on on-chip memory while data instruction interface in on submodels like switches, interrup_pio .... 

b) In what ways are the Nios II PIO module utilized in this problem?
write_I2c_... read_I2c_....

c) What is the purpose of the JTAG UART module?
to use UART communicate to the NIOS II module core

d) Why is it recommended to minimize the application code inside an interrupt service routine (ISR)?
 An ISR must perform very quickly to avoid slowing down the operation of the device and the operation of all lower-priority ISRs.(ref:https://www.sciencedirect.com/topics/engineering/interrupt-service-routine)

e) What is the I2C address of the ADXL345 when the ALT ADDRESS pin is grounded?
An alternate I2C address of 0x53 (followed by the R/W bit)
can be chosen by grounding the ALT ADDRESS pin (Pin 12).(reference adxl datasheet page 18)

f) How do you setup the ADXL345 to run in a I2C mode?
With CS tied high to VDD I/O, the ADXL345 is in I2C mode(reference adxl datasheet page 18)

g) What is the device ID of the ADXL345 and in which register of the ADXL345 is this value stored?
With the ALT ADDRESS pin
high, the 7-bit I2C address for the device is 0x1D, followed by
the R/W bit. This translates to 0x3A for a write and 0x3B for a
read. An alternate I2C address of 0x53 (followed by the R/W bit)
can be chosen by grounding the ALT ADDRESS pin (Pin 12).
This translates to 0xA6 for a write and 0xA7 for a read.(reference adxl datasheet page 18)

h) What is the purpose of writing the driver functions read_from_i2c_device and write_to_i2c_device?
is HAL library to communicate with the nio2 memory mapping io interface.

i) Can you explain what operation the following statement results in?

IOWR(I2C_AVALON_MM_IF_0_BASE,ADDR_REG, i2c_reg_addr << 8 | i2c_device_addr);
write to avalon memory module at memory location atI2C_AVALON_MM_IF_0_BASE, at addr_reg concatnate the i2c register address with i2c_device address.

### Excercise  8: RTOS
a) What is the purpose of using the putchar command in the first part of this problem?
increase the process running time 

b) Using the putchar command for the first part of this problem should result in a result similar to what is shown below. Can you explain this behaviour?

Hello from Task1
Hello from Task2
Hello fromHello from Task1
 Task2
Hello from Task2
Hello from Task1
the process is being terminated and rerunned because the processed is not synchronized by either semaphore or wait notify (something similar in java).
c) What is the purpose of the semaphore used in the first part of this problem?
Using semaphores to protect shared resources.

d) What is the purpose of the semaphore used the interrupt routine of the second part of this problem, and how is it different from the use in the first part of the problem?
controls the access to this resource.

e) What is the purpose of the message box used in the second part of this problem?
The message box is a special memory location that one or more tasks can use to transfer data or more generally for synchronization.


