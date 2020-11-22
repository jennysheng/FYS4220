if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
  onbreak {abort all; exit -f}
} else {
  onerror {abort all}
}

quit -sim

vlib work
vmap work work

quietly set prj_path "../.."


quietly set root_path "../../UVVM_light"
do $root_path/script/compile.do $root_path/ $root_path/sim


# Compile project source files
vcom -2008 -check_synthesis $prj_path/src/i2c_master.vhd
vcom -2008 -check_synthesis $prj_path/src/i2c_avalon_mm_if.vhd
vcom -2008 ../../tb/adxl345_simmodel.vhd
vcom -2008 ../../tb/i2c_master_pkg.vhd
vcom -2008 ../../tb/i2c_avalon_mm_if_tb.vhd


# Run simulation of I2C Avalon MM IF
vsim i2c_avalon_mm_if_tb
run -all
