# Git repository for < jenny > < sheng>

# Assignment progess

## Introductory assignment
 - Problem 1: <  completed >
 - Problem 2: <  completed >
 - Problem 3: <  completed >
 - Problem 4: <  completed >

## Embedded system project
 - Problem 1: <started | >
 - Problem 2: < not started | started | completed >
 - Problem 3: < not started | started | completed >
 - Problem 4: < not started | started | completed >


 # Answers to assignment questions

 ## Introductory assignment

 ### Exercise 1: Your first FPGA project

a) What is the meaning of the warning messages in the compilation report and why can we choose to ignore them at this stage?

b) What is the purpose of the entity and architecture description?
c) What is the purpose of the Tcl file used in this problem?

d) Can you briefly explain what the following Tcl statement is doing:

set_location_assignment PIN_C10 -to sw[0]
e) Which VHDL statement is needed to connect the input ports to the output ports of your design?


 ### Excercise 2: Seven segment display.
 a) How many values can a 4-bit binary number represent, and can all of these numbers be shown on the seven segment display?

 2^4=16 No only digits from 0 to 9

Hexadecimal represention.

b) The input port sw is a bundle / vector of 10 input while only 4 are needed to control the seven segment display. How can you address only parts of a std_logic_vector?
sw(3 downto 0)


 ### Excercise 3: Synchronization and edge detection.
 a) Which package is available in VHDL to arithmetic operations?
   IEEE.numeric_std.all;

b) What is the purpose of the process sensitivity list?
sensitivity list includes  synchrnous signal that may  trigger a process or resume a process.


c) Why should an asynchronous reset signal be listed in the sentivitiy list and why should a synchronous rest signal not be listed?
the reset button key0 is a asychronous reset, it doesn't detect the rising edge when we press it.

d) What is the standard method to check the behaviour of an HDL description?
test bench

e) Why is the entity description of a test bench empty?
This is because the test bench itself does not have any inputs or outputs. Test vectors are generated and applied to the unit under test within the test bench.

f) How can you model a 10 MHz clock signal in a VHDL test bench?
time analyser, create new sdc file and define the period to be 100ns.

g) Why does the stimuli process of a basic test bench not have a sensitivity list?
because it is syschronous, the clk will controll the process.


h) Why do you need to disable a the clock at the end of the stimuli process in the test bench?
to stop running the process.

i) Why can the wait for and wait statements not be synthesized?
because it replace the sensitivity list, it stops a synchronous process.

j) Can you think of a reason why for the first part of the simulation the value of the counter signal in figure 76 is 'U'? Was this the case for your simulation results?
yes, the counter is not initialized until a reset signal come.

k) What does this 'U' mean and how could you avoid it?
because the counter value is undefined. we need to signal counter: std_logic_vector(3 downto 0:='0000';

l) What happens when you press the push button KEY1 to start the counter, and can you explain why this happens?

without edge detection the key1 kan push a lot of clock cycles which cause the number just very fast, after the edge detection , the number will increment one by one.
a) What is the purpose of synchronization registers and when do you need to use them?
to store a tempera value, in my case to store a detected falling edge value.
