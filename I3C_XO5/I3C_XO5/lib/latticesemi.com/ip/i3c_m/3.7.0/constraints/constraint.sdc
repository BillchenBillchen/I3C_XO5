set device "LFMXO5-25"
set device_int "jd5f25"
set package "BBG256"
set package_int "BBG256"
set speed "7_High-Performance_1.0V"
set speed_int "10"
set operation "Commercial"
set family "LFMXO5"
set architecture "jd5f00"
set partnumber "LFMXO5-25-7BBG256C"
set WRAPPER_INST "lscc_i3c_controller_inst"
set DEVICE_ROLE 1
set FAMILY "LFMXO5"
set ENABLE_SMI 0
set ENABLE_IBI 1
set ENABLE_HJI 1
set ENABLE_HDR_DDR 0
set SEL_INTF "APB"
set REG_MAPPING 1
set MEM_IMPL "EBR"
set FIFO_DEPTH 512
set EN_FIFOINTF 0
set TXDWID 8
set RXDWID 8
set CLKDOMAIN "ASYNC"
set USE_INTCLKDIV 1
set TIMEOUT_100US 2500
set DEFAULT_RATE 0
set DEFAULT_ODTIMER 3
set EN_DYN_I2C_SWITCHING 1
set I2C_RATE 12
set ENABLE_IO_PRIMITIVE 1
set IBI_DATA_PAY 1
set MAX_D_SPEED_LIMIT 1
set DCR 0
set PID_MANUF 414
set PID_PART 1
set PID_INST 1
set PID_ADD 0
set STATIC_ADDR_EN 1
set STATIC_ADDR 8
set DYNAMIC_ADDR 8
set CLKI_FREQ 25
set MXDS_W 0
set MXDS_TSCO 0
set MXDS_R 0
set MXDS_RD_TURN 0


if { $radiant(stage) == "presyn" } {

} elseif { $radiant(stage) == "premap" } {

##================================================================================##
## Recommended to use these constraints if clock frequency is greater than 25MHz
##================================================================================##
if {$CLKI_FREQ > 25.0} {
  create_generated_clock -name {int_sysclk} -source [get_ports clk_i] -divide_by 2 [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/scl_src_*]
  set_multicycle_path -setup -end -from [get_pins -hierarchical {*i3c_controller_inst/u_i3c_mst/u_csr/csr_rdat[*]}] -to [get_clocks int_sysclk] 2
  set_multicycle_path -hold -end -from [get_pins -hierarchical {*i3c_controller_inst/u_i3c_mst/u_csr/csr_rdat[*]}] -to [get_clocks int_sysclk] 1
  set_multicycle_path -setup -start -from [get_pins -hierarchical {*i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wr_rdn_q*/Q *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wdata_q*[*]/Q *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_offset_q*[*]/Q}] -to [get_clocks int_sysclk] 2
  set_multicycle_path -hold -end -from [get_pins -hierarchical {*i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wr_rdn_q*/Q *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wdata_q*[*]/Q *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_offset_q*[*]/Q}] -to [get_clocks int_sysclk] 2
  set_max_delay -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_req_sys*/Q] -to [get_clocks int_sysclk] 10
  set_max_delay -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_csr/int_csr*/Q] -to [get_clocks int_sysclk] 10
  set_false_path -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wdata_q*/Q] -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_csr/gen_sec_mst.timeout_100us*/D]
  set_false_path -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wdata_q*/Q] -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_csr/od_timer*/D]
}

##================================================================================##
## Recommended to use these constraints if Secondary Controller feature is enabled
##================================================================================##
if {$ENABLE_SMI} {
  create_clock -name {scl_i} -period 80 [get_ports scl_io]
  create_clock -name {sda_i} -period 160 [get_ports sda_io]
  set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/sda_reg_sclp*]
  set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/sda_reg_scln*]
  set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/scl_reg_sdap*]
  set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/scl_reg_sdan*]
  set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/stop_det*]
  set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/sda_oe_reset*]
  set_false_path -through [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*sda*]
  set_false_path -through [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*scl*]
  set_false_path -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/scl_reg_clkp*/D*]
  set_false_path -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/*/sda_reg_clkp*/D*]
  set_false_path -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/scl_reg_sdap*/D*]
  set_multicycle_path -hold -end -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/*/Q] 2
  set_false_path -to [get_nets lscc_i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*reset*]
  set_false_path -from [get_ports scl_io] -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_i3c_p2s/stop_seq_reg*/D*]
  set_false_path -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/gen_ctl_role_handshake.u_i3c_tgt_ctl_role_handshake/tgt_cr_takeover_ack*/Q*] -to [get_pins -hierarchical {lscc_i3c_controller_inst/u_i3c_mst/u_packet_to_i3cbus/u_packet_decode/gen_sec_mst.tgt_cr_takeover_ack_ss[0]/D*}]
  set_false_path -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/gen_ctl_role_handshake.u_i3c_tgt_ctl_role_handshake/tgt_cr_handoff_req*/Q*] -to [get_pins -hierarchical {lscc_i3c_controller_inst/u_i3c_mst/u_packet_to_i3cbus/u_packet_decode/gen_sec_mst.tgt_cr_handoff_req_ss[0]/D*}]
}

##================================================================================##
## False Path constraints
##================================================================================##
set_false_path -from [get_ports rst_n_i]

##================================================================================##
## Max skew constraints
##================================================================================##
if {$ENABLE_IO_PRIMITIVE} {
  set_max_skew [get_pins -hierarchical {*i3c_controller_inst/gen_prim*.u_i3c_scl*/I *i3c_controller_inst/gen_prim*.u_i3c_scl*/T *i3c_controller_inst/gen_prim*.u_i3c_sda*/I *i3c_controller_inst/gen_prim*.u_i3c_sda*/T}] 2
}

}
