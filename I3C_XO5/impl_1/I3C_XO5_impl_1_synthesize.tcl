if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2025.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5"
if {![file exists {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1}]} {
  file mkdir {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1}
}
cd {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- I3C_XO5_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn synpro -f "I3C_XO5_impl_1.cprj" "i3c_m.cprj" "i3c_s.cprj" "ahb2apb.cprj" "pll0.cprj" "apb0.cprj" "uart0.cprj" "osc0.cprj" "gpio0.cprj" "ahbl.cprj" "risc_mc.cprj" "sys_mem.cprj" "I3C_target_inst.cprj" -a "LFMXO5"  -o I3C_XO5_impl_1_cpe.ldc
# synthesize top design
file delete -force -- I3C_XO5_impl_1.vm I3C_XO5_impl_1.ldc
if {[file normalize "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/I3C_XO5_impl_1_synplify.tcl"] != [file normalize "./I3C_XO5_impl_1_synplify.tcl"]} {
  file copy -force "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/I3C_XO5_impl_1_synplify.tcl" "./I3C_XO5_impl_1_synplify.tcl"
}
if {[ catch {::radiant::runengine::run_engine synpwrap -prj "I3C_XO5_impl_1_synplify.tcl" -log "I3C_XO5_impl_1.srf"} result options ]} {
    file delete -force -- I3C_XO5_impl_1.vm I3C_XO5_impl_1.ldc
    return -options $options $result
}
::radiant::runengine::run_postsyn [list -a LFMXO5 -p LFMXO5-25 -t BBG400 -sp 9_High-Performance_1.0V -oc Commercial -top -ipsdc ipsdclist.txt -w -o I3C_XO5_impl_1_syn.udb I3C_XO5_impl_1.vm] [list C:/lscc/radiant/2025.2/data/reveal/src/ertl/reveal_constraint.sdc I3C_XO5_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
