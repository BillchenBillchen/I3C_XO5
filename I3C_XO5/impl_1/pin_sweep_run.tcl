#-- Pin Sweep: Parameterized Map -> PAR -> Bitgen TCL script
#-- Usage: radiantc pin_sweep_run.tcl <pdc_path> <output_prefix>
#-- Example: radiantc pin_sweep_run.tcl "C:/path/to/I3C_XO5_C3.pdc" "I3C_XO5_C3"

set ret 0
if {[catch {

# Get arguments
set pdc_path [lindex $argv 0]
set output_prefix [lindex $argv 1]

set impl_dir "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1"

if {![file exists $impl_dir]} {
  error "impl_1 directory not found: $impl_dir"
}
cd $impl_dir

puts "============================================"
puts "Pin Sweep: PDC = $pdc_path"
puts "Pin Sweep: Output prefix = $output_prefix"
puts "============================================"

# ---- Step 1: MAP ----
puts "\n>>> Step 1/3: MAP..."
sys_set_attribute -gui on -msg {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/promote.xml}
msg_load {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/promote.xml}
des_set_project_udb -in {I3C_XO5_impl_1_syn.udb} -out {I3C_XO5_impl_1_map.udb} -milestone map -pm jd5f00
des_set_reference_udb -clean
map_set_option [list pdc_file $pdc_path]
map_set_option { report_symbol_cross_reference false report_signal_cross_reference false infer_gsr false ignore_constraint_errors false vio false}
map_run
puts ">>> MAP completed."

# ---- Step 2: PAR ----
puts "\n>>> Step 2/3: PAR..."
des_set_project_udb -in {I3C_XO5_impl_1_map.udb} -out {I3C_XO5_impl_1.udb} -milestone par -pm jd5f00
des_set_reference_udb -clean
par_set_option { disable_timing_driven false placement_iterations 1 placement_iteration_start_point 1 placement_save_best_run "1" number_of_host_machine_cores "1" path_based_placement on stop_once_timing_is_met false set_speed_grade_for_hold_optimization m disable_auto_hold_timing_correction false prioritize_hold_correction_over_setup_performance false run_placement_only false impose_hold_timing_correction false}
par_run
puts ">>> PAR completed."

# ---- Step 3: BITGEN ----
puts "\n>>> Step 3/3: BITGEN..."
des_set_project_udb -in {I3C_XO5_impl_1.udb} -milestone bit -pm jd5f00
bit_set_option { enable_early_io_wakeup false output_format "binary" ip_evaluation false register_initialization true bitstream_mode normal }
bit_generate -w [file join $impl_dir "I3C_XO5_impl_1"]
puts ">>> BITGEN completed."

puts "\n============================================"
puts "Pin Sweep: All steps completed for $output_prefix"
puts "============================================"

} out]} {
   puts "ERROR: $out"
   set ret 1
}

exit -force ${ret}
