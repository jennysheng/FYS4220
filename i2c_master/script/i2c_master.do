# Name of file: i2c_master.do
# create and map the work library
vlib work
vmap work work

# Compile the design and tb files
vcom -2008 -check_synthesis ../../src/i2c_master.vhd
vcom ../../tb/i2c_master_tb.vhd

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
add wave i2c_master_tb/GC_SYSTEM_CLK
add wave i2c_master_tb/GC_I2C_CLK
add wave -noupdate -divider i2c_master
add wave i2c_master_tb/UUT/arst_n
add wave i2c_master_tb/UUT/valid
add wave i2c_master_tb/UUT/addr
add wave i2c_master_tb/UUT/rnw
add wave i2c_master_tb/UUT/data_wr
add wave i2c_master_tb/UUT/data_rd
add wave i2c_master_tb/UUT/busy
add wave i2c_master_tb/UUT/ack_error
add wave i2c_master_tb/UUT/sda
add wave i2c_master_tb/UUT/scl
add wave -noupdate -divider internal_signals
add wave i2c_master_tb/UUT/state
add wave i2c_master_tb/UUT/state_ena
add wave i2c_master_tb/UUT/scl_high_ena
add wave i2c_master_tb/UUT/scl_clk
add wave i2c_master_tb/UUT/addr_rnw_i
add wave i2c_master_tb/UUT/scl_oe
add wave i2c_master_tb/UUT/data_tx
add wave i2c_master_tb/UUT/data_rx
add wave i2c_master_tb/UUT/sda_i
add wave i2c_master_tb/UUT/bit_cnt
add wave i2c_master_tb/UUT/ack_error_i
add wave /i2c_master_tb/UUT/p_sclk/cnt

# configure window
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -timelineunits ns
update

#run simulation
run -all

wave zoom full