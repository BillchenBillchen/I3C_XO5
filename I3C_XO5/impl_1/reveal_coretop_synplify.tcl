#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology LFMXO5
set_option -part LFMXO5_25
set_option -package BBG400C
set_option -speed_grade -9
#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog standard option
set_option -vlog_std v2001

#map options
set_option -frequency 200
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0


set_option -default_enum_encoding default

#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 0
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


set_option -rw_check_on_ram 0
set_option -seqshift_no_replicate 0
set_option -automatic_compile_point 0

#-- set any command lines input by customer

set_option -dup 1
set_option -force_gsr false
set_option -disable_io_insertion true
add_file -constraint {C:/lscc/radiant/2025.2/scripts/tcl/flow/radiant_synplify_vars.tcl}
add_file -verilog {C:/lscc/radiant/2025.2/ip/pmi/pmi_lfmxo5.v}
add_file -vhdl -lib pmi {C:/lscc/radiant/2025.2/ip/pmi/pmi_lfmxo5.vhd}
add_file -verilog "C:/lscc/radiant/2025.2/data/reveal/src/ertl/ertl.v"
add_file -verilog {C:/lscc/radiant/2025.2/data/reveal/src/ertl/JTAG_SOFT.v}
add_file -verilog  -vlog_std v2001 {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/reveal_workspace/tmpreveal/i3c_xo5_la0_trig_gen.v}
add_file -verilog  -vlog_std v2001 {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/reveal_workspace/tmpreveal/i3c_xo5_la0_gen.v}
add_file -verilog  -vlog_std v2001 {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/reveal_workspace/tmpreveal/I3C_XO5_reveal_coretop.v}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_sim/I3C_target_sim/I3C_target_inst}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/gpio0/1.8.0}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/i3c_m/3.7.0}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/i3c_s/3.7.0}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/risc_mc/2.8.1}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/sys_mem/2.5.1}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/uart0/1.5.0}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/ahb2apb/1.2.0}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/ahbl/1.5.0}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/apb0/1.4.0}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/osc0/1.4.0}
set_option -include_path {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/pll0/1.9.1}

set_option -top_module reveal_coretop
#-- set result format/file last
project -result_format "vm"
project -result_file "./reveal_coretop.vm"

#-- error message log file
project -log_file {reveal_coretop.srf}

project -run -clean
