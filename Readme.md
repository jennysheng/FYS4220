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
 and so on
