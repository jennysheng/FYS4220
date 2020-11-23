# make sure that the new output ports will be connected 
# to the correct pins by adding the required pin assignments in the DE10-lite-pinning Tcl-script
set_location_assignment PIN_C14 -to hex0[0]
set_location_assignment PIN_E15 -to hex0[1]
set_location_assignment PIN_C15 -to hex0[2]
set_location_assignment PIN_C16 -to hex0[3]
set_location_assignment PIN_E16 -to hex0[4]
set_location_assignment PIN_D17 -to hex0[5]
set_location_assignment PIN_C17 -to hex0[6]
set_location_assignment PIN_D15 -to hex0[7]

set_location_assignment PIN_C18 -to hex1[0]
set_location_assignment PIN_D18 -to hex1[1]
set_location_assignment PIN_E18 -to hex1[2]
set_location_assignment PIN_B16 -to hex1[3]

set_location_assignment PIN_A17 -to hex1[4]
set_location_assignment PIN_A18 -to hex1[5]

set_location_assignment PIN_B17 -to hex1[6]
set_location_assignment PIN_A16 -to hex1[7]

set_location_assignment PIN_B20 -to hex2[0]
set_location_assignment PIN_A20 -to hex2[1]

set_location_assignment PIN_B19 -to hex2[2]
set_location_assignment PIN_A21 -to hex2[3]

set_location_assignment PIN_B21 -to hex2[4]
set_location_assignment PIN_C22 -to hex2[5]

set_location_assignment PIN_B22 -to hex2[6]
set_location_assignment PIN_A19 -to hex2[7]

set_location_assignment PIN_F21 -to hex3[0]
set_location_assignment PIN_E22 -to hex3[1]
set_location_assignment PIN_E21 -to hex3[2]
set_location_assignment PIN_C19 -to hex3[3]

set_location_assignment PIN_C20 -to hex3[4]
set_location_assignment PIN_D19 -to hex3[5]

set_location_assignment PIN_E17 -to hex3[6]
set_location_assignment PIN_D22 -to hex3[7]

set_location_assignment PIN_F18 -to hex4[0]
set_location_assignment PIN_E20 -to hex4[1]

set_location_assignment PIN_E19 -to hex4[2]
set_location_assignment PIN_J18 -to hex4[3]

set_location_assignment PIN_H19 -to hex4[4]
set_location_assignment PIN_F19 -to hex4[5]

set_location_assignment PIN_F20 -to hex4[6]
set_location_assignment PIN_F17 -to hex4[7]

set_location_assignment PIN_J20 -to hex5[0]
set_location_assignment PIN_K20 -to hex5[1]
set_location_assignment PIN_L18 -to hex5[2]
set_location_assignment PIN_N18 -to hex5[3]

set_location_assignment PIN_M20 -to hex5[4]
set_location_assignment PIN_N19 -to hex5[5]

set_location_assignment PIN_N20 -to hex5[6]
set_location_assignment PIN_L19 -to hex5[7]

#Led outputs

set_location_assignment PIN_A8 -to led[0]
set_location_assignment PIN_A9 -to led[1]
set_location_assignment PIN_A10 -to led[2]
set_location_assignment PIN_B10 -to led[3]

set_location_assignment PIN_D13 -to led[4]
set_location_assignment PIN_C13 -to led[5]

set_location_assignment PIN_E14 -to led[6]
set_location_assignment PIN_D14 -to led[7]
set_location_assignment PIN_A11 -to led[8]
set_location_assignment PIN_B11 -to led[9]





#Toggle switches sw0
set_location_assignment PIN_C10 -to sw[0]
set_location_assignment PIN_C11 -to sw[1]
set_location_assignment PIN_D12 -to sw[2]
set_location_assignment PIN_C12 -to sw[3]
set_location_assignment PIN_A12 -to sw[4]
set_location_assignment PIN_B12 -to sw[5]
set_location_assignment PIN_A13 -to sw[6]
set_location_assignment PIN_A14 -to sw[7]
set_location_assignment PIN_B14 -to sw[8]
set_location_assignment PIN_F15 -to sw[9]

#Toggle push button key0 is reset and key1 is enable
set_location_assignment PIN_B8 -to arst_n
set_location_assignment PIN_A7 -to ext_ena_n
#50MHz clock MAX10_CLK1_50
set_location_assignment PIN_P11 -to clk

#i2c_master 
set_location_assignment PIN_V11 -to  sda
set_location_assignment PIN_V12 -to  adxl345_alt_addr
set_location_assignment PIN_AB16 -to adxl345_cs_n  
set_location_assignment PIN_AB15 -to scl
set_location_assignment PIN_Y14 -to  adxl345_irq_n[0]
set_location_assignment PIN_Y13 -to  adxl345_irq_n[1]





#To avoid that the FPGA is driving an unintended value on pins that are not in use:
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"


















