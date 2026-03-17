#-- Random Sweep: PAR TCL
#-- Usage: radiantc random_sweep_par.tcl

set ret 0
if {[catch {

set impl_dir "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1"
cd $impl_dir

puts ">>> PAR..."
sys_set_attribute -gui on -msg {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/promote.xml}
msg_load {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/promote.xml}
des_set_project_udb -in {I3C_XO5_impl_1_map.udb} -out {I3C_XO5_impl_1.udb} -milestone par -pm jd5f00
des_set_reference_udb -clean
par_set_option { disable_timing_driven false placement_iterations 1 placement_iteration_start_point 1 placement_save_best_run "1" number_of_host_machine_cores "1" path_based_placement on stop_once_timing_is_met false set_speed_grade_for_hold_optimization m disable_auto_hold_timing_correction false prioritize_hold_correction_over_setup_performance false run_placement_only false impose_hold_timing_correction false}
par_run
puts ">>> PAR completed."

} out]} {
   puts "ERROR: $out"
   set ret 1
}
exit -force ${ret}
