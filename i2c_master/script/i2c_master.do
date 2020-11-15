# Name of file: i2c_master.do
# create and map the work library
vlib work
vmap work work

# Compile the design and tb files
vcom -2008 -check_synthesis C:/Users/JennySheng/Documents/FYS4220-Jenny-Sheng/i2c-master/src/i2c_master.vhd
vcom C:/Users/JennySheng/Documents/FYS4220-Jenny-Sheng/i2c-master/tb/i2c_master_tb.vhd

# start the simulation
vsim i2c_master_tb

# open the wave window
view wave

# add signals and variables of interest
# It is important that the names of the signals
# and instances are identical to those used
# in the design files.
add wave -noupdate -divider testbench
add wave i2c_master_tb/clk_ena
add wave i2c_master_tb/clk
add wave -noupdate -divider i2c_master
add wave i2c_master_tb/UUT/arst_n
add wave i2c_master_tb/UUT/scl_clk
add wave i2c_master_tb/UUT/scl_high_ena
add wave i2c_master_tb/UUT/state_ena
add wave i2c_master_tb/UUT/p_sclk/cnt

# configure window
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -timelineunits ns
update

#run simulation
run -all

wave zoom full