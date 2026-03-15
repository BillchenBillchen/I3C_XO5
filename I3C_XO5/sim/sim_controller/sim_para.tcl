lappend auto_path "C:/lscc/radiant/2025.2/scripts/tcl/simulation"
package require simulation_generation
set ::bali::simulation::Para(DEVICEPM) {jd5f00}
set ::bali::simulation::Para(DEVICEFAMILYNAME) {LFMXO5}
set ::bali::simulation::Para(PROJECT) {sim_controller}
set ::bali::simulation::Para(MDOFILE) {}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/sim_controller}
set ::bali::simulation::Para(FILELIST) {"C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/IPs/i3c_m/3.7.0/rtl/i3c_m.v" "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/IPs/i3c_m/3.7.0/testbench/dut_params.v" "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/IPs/i3c_m/3.7.0/testbench/tb_models.v" "C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/IPs/i3c_m/3.7.0/testbench/tb_top.v" }
set ::bali::simulation::Para(GLBINCLIST) {"C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5"}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"" "" "" "" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(LANGSTDLIST) {"" "" "" "" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_lfmxo5}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {tb_top}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {C:/lscc/radiant/2025.2}
set ::bali::simulation::Para(MEMPATH) {C:/Users/billzhang/Desktop/I3C_XO5/I3C_sim/I3C_target_sim/I3C_target_inst;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/gpio0/1.8.0;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/i3c_m/3.7.0;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/i3c_s/3.7.0;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/risc_mc/2.8.1;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/sys_mem/2.5.1;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/ip/uart0/1.5.0;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/ahb2apb/1.2.0;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/ahbl/1.5.0;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/apb0/1.4.0;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/osc0/1.4.0;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/I3C_XO5/lib/latticesemi.com/module/pll0/1.9.1;C:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/.}
set ::bali::simulation::Para(UDOLIST) {}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(SIMULATIONTIME)  {0}
set ::bali::simulation::Para(SIMULATIONTIMEUNIT)  {ns}
set ::bali::simulation::Para(SIMULATION_RESOLUTION)  {default}
set ::bali::simulation::Para(NOGUI) {0}
set ::bali::simulation::Para(ISRTL)  {1}
set ::bali::simulation::Para(ISQRUNCLEAN)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(AUTOORDER)  {1}
set ::bali::simulation::Para(PERMISSIVE)  {0}
set ::bali::simulation::Para(OPTIMIZATION_DEBUG)  {1}
::bali::simulation::QuestaSim_Q_Run
