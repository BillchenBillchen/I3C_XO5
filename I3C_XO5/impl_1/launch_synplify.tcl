#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/launch_synplify.tcl
#-- Written on Tue Mar 17 10:31:09 2026

project -close
set filename "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/impl_1_syn.prj"
project -new "$filename"
set create_new 1

#device options
set_option -technology LFMXO5
set_option -part LFMXO5_25
set_option -package BBG400C
set_option -speed_grade -9

if {$create_new == 1} {
	#-- add synthesis options
	#compilation/mapping options
	set_option -symbolic_fsm_compiler true
	set_option -resource_sharing true

	#use verilog standard option
	set_option -vlog_std v2001
	set_option -disable_io_insertion false

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
	
	set_option -dup false
}
#-- add_file options
add_file -constraint {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/I3C_XO5_impl_1_cpe.ldc}
add_file -verilog {C:/lscc/radiant/2025.2/ip/pmi/pmi_lfmxo5.v}
add_file -vhdl -lib pmi {C:/lscc/radiant/2025.2/ip/pmi/pmi_lfmxo5.vhd}
set_option -include_path "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5"
set_option -include_path "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/i3c_m/3.7.0/rtl/i3c_m.v"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/i3c_s/3.7.0/rtl/i3c_s.v"
add_file -verilog -vlog_std sysv "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/ahb2apb/1.2.0/rtl/ahb2apb.sv"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/pll0/1.9.1/rtl/pll0.v"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/apb0/1.4.0/rtl/apb0.v"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/I3C_XO5.v"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/uart0/1.5.0/rtl/uart0.v"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/osc0/1.4.0/rtl/osc0.v"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/gpio0/1.8.0/rtl/gpio0.v"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/ahbl/1.5.0/rtl/ahbl.v"
add_file -verilog -vlog_std sysv "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/risc_mc/2.8.1/rtl/risc_mc.sv"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/sys_mem/2.5.1/rtl/sys_mem.v"
add_file -verilog -vlog_std v2001 "C:/Users/billzhang/Desktop/I3C_XO5/I3C_sim/I3C_target_sim/I3C_target_inst/rtl/I3C_target_inst.v"
#-- top module name
set_option -top_module {I3C_XO5}
project -result_format "vm"
project -result_file {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/I3C_XO5_impl_1.vm}
project -save "$filename"
