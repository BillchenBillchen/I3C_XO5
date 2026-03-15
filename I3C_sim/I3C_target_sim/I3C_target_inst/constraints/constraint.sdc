set device "LFMXO5-25"
set device_int "jd5f25"
set package "BBG400"
set package_int "BBG400"
set speed "9_High-Performance_1.0V"
set speed_int "12"
set operation "Commercial"
set family "LFMXO5"
set architecture "jd5f00"
set partnumber "LFMXO5-25-9BBG400C"
set WRAPPER_INST "lscc_i3c_target_inst"
set FAMILY "LFMXO5"
set INTERFACE "APB"
set REG_MAPPING 1
set MEM_IMPL "EBR"
set FIFO_SIZE 512
set EN_FIFOINTF 0
set TXDWID 8
set RXDWID 8
set EN_IO_PRIM 1
set HDR_CAPABLE 0
set IBI_CAPABLE 1
set IBI_DATA_PAY 1
set HOTJOIN_CAPABLE 1
set MAX_D_SPEED_LIMIT 1
set DCR 0
set PID_MANUF 414
set PID_PART 1
set PID_INST 1
set PID_ADD 0
set STATIC_ADDR_EN 1
set STATIC_ADDR 8
set CLKI_FREQ 25
set CLKI_FREQ_BYTE 50
set MXDS_W 0
set MXDS_TSCO 0
set MXDS_R 0
set MXDS_RD_TURN 0


if { $radiant(stage) == "presyn" } {

} elseif { $radiant(stage) == "premap" } {

##================================================================================##
## False Path constraints
##================================================================================##
set_false_path -from [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/*rst_n*]
set_false_path -from [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*reset*]

set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/sda_reg_sclp*]
set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/sda_reg_scln*]
set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/scl_reg_sdap*]
set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/scl_reg_sdan*]
set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/scl_reg_clkp*]
set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/sda_reg_clkp*]

set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/stop_det*]
set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/sda_oe_reset*]
set_false_path -through [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*sda*]
set_false_path -through [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*scl*]

set_multicycle_path 2 -hold -end -from [get_pins -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main*/Q]

##================================================================================##
## Max skew constraints
##================================================================================##
if {$EN_IO_PRIM} {
  set_max_skew [get_pins -hierarchical {*i3c_target_inst/gen_prim*.u_i3c_scl.SEIO33_inst/I *i3c_target_inst/gen_prim*.u_i3c_scl.SEIO33_inst/T *i3c_target_inst/gen_prim*.u_i3c_sda.SEIO33_inst/I *i3c_target_inst/gen_prim*.u_i3c_sda.SEIO33_inst/T}] 2
}

}
