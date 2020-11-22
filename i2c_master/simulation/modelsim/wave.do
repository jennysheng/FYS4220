onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate /i2c_master_tb/clk_ena
add wave -noupdate /i2c_master_tb/clk
add wave -noupdate /i2c_master_tb/GC_SYSTEM_CLK
add wave -noupdate /i2c_master_tb/GC_I2C_CLK
add wave -noupdate -divider i2c_master
add wave -noupdate /i2c_master_tb/UUT/arst_n
add wave -noupdate /i2c_master_tb/UUT/valid
add wave -noupdate /i2c_master_tb/UUT/addr
add wave -noupdate /i2c_master_tb/UUT/rnw
add wave -noupdate /i2c_master_tb/UUT/data_wr
add wave -noupdate /i2c_master_tb/UUT/data_rd
add wave -noupdate /i2c_master_tb/UUT/busy
add wave -noupdate /i2c_master_tb/UUT/ack_error
add wave -noupdate /i2c_master_tb/UUT/sda
add wave -noupdate /i2c_master_tb/UUT/scl
add wave -noupdate -divider internal_signals
add wave -noupdate /i2c_master_tb/UUT/state
add wave -noupdate /i2c_master_tb/UUT/state_ena
add wave -noupdate /i2c_master_tb/UUT/scl_high_ena
add wave -noupdate /i2c_master_tb/UUT/scl_clk
add wave -noupdate /i2c_master_tb/UUT/addr_rnw_i
add wave -noupdate /i2c_master_tb/UUT/scl_oe
add wave -noupdate /i2c_master_tb/UUT/data_tx
add wave -noupdate /i2c_master_tb/UUT/data_rx
add wave -noupdate /i2c_master_tb/UUT/sda_i
add wave -noupdate /i2c_master_tb/UUT/bit_cnt
add wave -noupdate /i2c_master_tb/UUT/ack_error_i
add wave -noupdate /i2c_master_tb/UUT/p_sclk/cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {39161971 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {41244 ns}
