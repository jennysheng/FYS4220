# FYS4220-Jenny-ShengAdded another line to README.md
hello world
a) What is the meaning of the warning messages in the compilation report and why can we choose to ignore them at this stage?
a) Either the clock frequency is not defined or multiprocessor is not defined, yes
b) What is the purpose of the entity and architecture description? the entity defines the port which includes the led name and switch name
The arhchitecture specify the running sequence or priority of the task 
c) What is the purpose of the Tcl file used in this problem? To specify the pin mapping with the hardware.
d) Can you briefly explain what the following Tcl statement is doing:
set_location_assignment PIN_C10 -to sw[0], assign the pin c10 to switch 0
e) Which VHDL statement is needed to connect the input ports to the output ports of your design? led <= sw;
