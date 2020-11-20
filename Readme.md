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
 - Problem 7: < not started | started | completed >
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
vet ikke.


c) Why is the wait for 0 ns statement included in VHDL code below?

reg_addr_use <= reg_addr_device_id;
wait for 0 ns;
read_i2c(i2c_addr_adxl345, reg_addr_use, data_array_rd, 1);

 buffer the device address, maybe?
 
d) What is the main purpose or advantage of adding the overloaded functions write_i2c and read_i2c in the i2c_master_adv_tb.vhd file?
vet ikke;


e) What is the VHDL conditional statement that can be used to detect a rising edge on the busy signal from the I2C master module?

risingedge(clk);






