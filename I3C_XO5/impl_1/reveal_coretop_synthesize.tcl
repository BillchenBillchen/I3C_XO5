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
# synthesize Reveal coretop
file delete -force -- reveal_coretop.vm reveal_coretop.ldc
if {[file normalize "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/reveal_coretop_synplify.tcl"] != [file normalize "./reveal_coretop_synplify.tcl"]} {
  file copy -force "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/reveal_coretop_synplify.tcl" "./reveal_coretop_synplify.tcl"
}
if {[ catch {::radiant::runengine::run_engine synpwrap -prj "reveal_coretop_synplify.tcl" -log "reveal_coretop.srf"} result options ]} {
    file delete -force -- reveal_coretop.vm reveal_coretop.ldc
    return -options $options $result
}
::radiant::runengine::run_postsyn [list -a LFMXO5 -p LFMXO5-25 -t BBG400 -sp 9_High-Performance_1.0V -oc Commercial -w -o reveal_coretop.udb reveal_coretop.vm] [list reveal_coretop.ldc]
# synthesize top Reveal generated VMs
::radiant::runengine::run_postsyn [list -a LFMXO5 -p LFMXO5-25 -t BBG400 -sp 9_High-Performance_1.0V -oc Commercial -top -iplist iplist.txt -ipsdc ipsdclist.txt -w -o I3C_XO5_impl_1_syn.udb C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/reveal_workspace/tmpreveal/I3C_XO5_rvl_top.vm] [list C:/lscc/radiant/2025.2/data/reveal/src/ertl/reveal_constraint.sdc C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/I3C_XO5_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
