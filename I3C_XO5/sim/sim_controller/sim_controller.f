-L work
-reflib pmi_work
-reflib ovi_lfmxo5
-sv

"+incdir+C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5"
"+incdir+C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/IPs/i3c_m/3.7.0/testbench"

"C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/IPs/i3c_m/3.7.0/rtl/i3c_m.v" 
"C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/IPs/i3c_m/3.7.0/testbench/dut_params.v" 
"C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/IPs/i3c_m/3.7.0/testbench/tb_models.v" 
"C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/IPs/i3c_m/3.7.0/testbench/tb_top.v" 
-optionset VOPTDEBUG
+noacc+pmi_work.*
+noacc+ovi_lfmxo5.*

-vopt.options
  -suppress vopt-7033
-end

-gui
-top tb_top
-vsim.options
  -suppress vsim-7033,vsim-8630,3009,3389
-end

-do "view wave"
-do "add wave /*"
-do "run -all"
