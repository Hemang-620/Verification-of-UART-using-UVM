############################################################
# UART APB UVM Verification
# QuestaSim Run Script
############################################################

quit -sim

#-----------------------------------------------------------
# Create Work Library
#-----------------------------------------------------------

if {[file exists work]} {
    vdel -all
}

vlib work
vmap work work

#-----------------------------------------------------------
# Include Directories
#-----------------------------------------------------------

set INC {
+incdir+../rtl
+incdir+../apb_vip
+incdir+../uart_vip
+incdir+../RAL
+incdir+../env
+incdir+../test
+incdir+../tb
}

#-----------------------------------------------------------
# Compile Interfaces
#-----------------------------------------------------------

vlog -sv $INC ../apb_vip/apb_if.sv
vlog -sv $INC ../uart_vip/uart_if.sv

#-----------------------------------------------------------
# Compile RTL
#-----------------------------------------------------------

vlog -sv $INC ../rtl/*.v

#-----------------------------------------------------------
# Compile Packages
#-----------------------------------------------------------

vlog -sv $INC ../apb_vip/apb_pkg.sv
vlog -sv $INC ../uart_vip/uart_pkg.sv
vlog -sv $INC ../RAL/ral_pkg.sv
vlog -sv $INC ../env/env_pkg.sv
vlog -sv $INC ../test/test_pkg.sv

#-----------------------------------------------------------
# Compile Top
#-----------------------------------------------------------

vlog -sv $INC ../tb/tb_top.sv

#-----------------------------------------------------------
# Launch Simulation
#-----------------------------------------------------------

vsim -debugDB work.tb_top +UVM_TESTNAME=loopback_test -voptargs="+acc"

run 0

add wave -r sim:/tb_top/*

run -all