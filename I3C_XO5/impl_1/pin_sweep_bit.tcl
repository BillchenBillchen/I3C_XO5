#-- Pin Sweep: Bitstream Generation TCL
#-- Usage: radiantc pin_sweep_bit.tcl

set ret 0
if {[catch {

set impl_dir "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1"
cd $impl_dir

puts ">>> Bitgen..."
sys_set_attribute -gui on -msg {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/promote.xml}
msg_load {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/promote.xml}
des_set_project_udb -in {I3C_XO5_impl_1.udb} -milestone bit -pm jd5f00
bit_set_option { enable_early_io_wakeup false output_format "binary" ip_evaluation false register_initialization true bitstream_mode normal }
bit_generate -w {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/I3C_XO5_impl_1}
puts ">>> Bitgen completed."

} out]} {
   puts "ERROR: $out"
   set ret 1
}
exit -force ${ret}
