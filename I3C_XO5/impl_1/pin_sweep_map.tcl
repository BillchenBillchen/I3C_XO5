#-- Pin Sweep: MAP TCL
#-- Usage: radiantc pin_sweep_map.tcl <pdc_path>

set ret 0
if {[catch {

set pdc_path [lindex $argv 0]
set impl_dir "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1"
cd $impl_dir

puts ">>> MAP: PDC = $pdc_path"
sys_set_attribute -gui on -msg {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/promote.xml}
msg_load {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/promote.xml}
des_set_project_udb -in {I3C_XO5_impl_1_syn.udb} -out {I3C_XO5_impl_1_map.udb} -milestone map -pm jd5f00
des_set_reference_udb -clean
map_set_option [list pdc_file $pdc_path]
map_set_option { report_symbol_cross_reference false report_signal_cross_reference false infer_gsr false ignore_constraint_errors false vio false}
map_run
puts ">>> MAP completed."

} out]} {
   puts "ERROR: $out"
   set ret 1
}
exit -force ${ret}
