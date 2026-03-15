import os

def load_parameter(param_name):
    f_params = open('eval/dut_params.v', 'r')
    while f_params:
        line = f_params.readline()
        if (param_name in line):
            str_spl = line.split('=')
            param = str_spl[-1]
            val = str_spl[1]
            f_val = val.replace(";\n",'')
            f_val2 = f_val.replace("\"",'')
            f_val3 = f_val2.replace(" ",'')
            break
    f_params.close()
    return (f_val3)

def load_macro(macro_name):
    f_macros = open('eval/dut_params.v', 'r')
    while f_macros:
        line = f_macros.readline()
        if (macro_name in line):
            str_spl = line.split(' ')
            macro = str_spl[1]
            val = str_spl[2]
            f_val = val.replace(";\n",'')
            f_val2 = f_val.replace("\"",'')
            f_val3 = f_val2.replace(" ",'')
            break
    f_macros.close()
    return (f_val3)

f_pdc = open('eval/constraint.pdc', 'w')

clk_freq        = load_parameter("CLKI_FREQ")
default_rate    = load_parameter("DEFAULT_RATE")
enable_smi      = load_parameter("ENABLE_SMI")
use_intclkdiv   = load_parameter("USE_INTCLKDIV")
coreclk_freq    = load_macro("CORECLK_FREQ")
family          = load_macro("FAMILY")

f_pdc.write("##================================================================================##\n")
f_pdc.write("## Copy these constraints to your top-level pdc and replace path with actual path   \n")
f_pdc.write("##================================================================================##\n")

f_pdc.write("set CLK_PERIOD %0.1f\n" % (1000.0/float(clk_freq)))
f_pdc.write("create_clock -name {clk_i} -period $CLK_PERIOD [get_ports clk_i]\n")

if (not int(use_intclkdiv)):
    f_pdc.write("\n")
    f_pdc.write("##================================================================================##\n")
    f_pdc.write("## Recommended to use these constraints if internal clock divider is disabled\n")
    f_pdc.write("##================================================================================##\n")

    f_pdc.write("set CORECLK_PERIOD %0.1f\n" % (1000.0/float(coreclk_freq)))
    f_pdc.write("create_clock -name {int_sysclk} -period $CORECLK_PERIOD [get_ports src_clk_scl_i]\n")
    f_pdc.write("\n")


if (int(use_intclkdiv)):
    f_pdc.write("\n")
    f_pdc.write("##================================================================================##\n")
    f_pdc.write("## Recommended to use these constraints if clock frequency is greater than 25MHz\n")
    f_pdc.write("##================================================================================##\n")
    f_pdc.write("create_generated_clock -name {int_sysclk} -source [get_ports clk_i] -divide_by 2 [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/scl_src_*]\n")

if ((float(clk_freq)) > 25.0):
    f_pdc.write("\n")
    f_pdc.write("set_multicycle_path -setup -end   -from [get_pins -hierarchical {*i3c_controller_inst/u_i3c_mst/u_csr/csr_rdat[*]}] -to [get_clocks int_sysclk] 2\n")
    f_pdc.write("set_multicycle_path -hold  -end   -from [get_pins -hierarchical {*i3c_controller_inst/u_i3c_mst/u_csr/csr_rdat[*]}] -to [get_clocks int_sysclk] 1\n")
    f_pdc.write("set_multicycle_path -setup -start -from [get_pins -hierarchical {*i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wr_rdn_q*/Q *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wdata_q*[*]/Q *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_offset_q*[*]/Q}] -to [get_clocks int_sysclk] 2\n")
    f_pdc.write("set_multicycle_path -hold  -end -from [get_pins -hierarchical {*i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wr_rdn_q*/Q *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wdata_q*[*]/Q *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_offset_q*[*]/Q}] -to [get_clocks int_sysclk] 2\n")

    f_pdc.write("\n")
    f_pdc.write("set_max_delay -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_req_sys*/Q] -to [get_clocks int_sysclk] 10\n")
    f_pdc.write("set_max_delay -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_csr/int_csr*/Q] -to [get_clocks int_sysclk] 10\n")

    f_pdc.write("\n")
    f_pdc.write("set_false_path -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wdata_q*/Q] -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_csr/gen_sec_mst.timeout_100us*/D]\n")
    f_pdc.write("set_false_path -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_lmmi_slv/gen_lmmi_async.lmmi_wdata_q*/Q] -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_csr/od_timer*/D]\n")


if (int(enable_smi)):
    f_pdc.write("\n")
    f_pdc.write("##================================================================================##\n")
    f_pdc.write("## Recommended to use these constraints if Secondary Controller feature is enabled\n")
    f_pdc.write("##================================================================================##\n")
    f_pdc.write("set SCL_PERIOD 80.0\n")
    f_pdc.write("set SCL_PERIOD 160.0\n")
    f_pdc.write("create_clock -name {scl_i} -period $SCL_PERIOD [get_ports scl_io]\n")
    f_pdc.write("create_clock -name {sda_i} -period $SCL_PERIOD [get_ports sda_io]\n")

    f_pdc.write("\n")
    f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/sda_reg_sclp*]\n")
    f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/sda_reg_scln*]\n")
    f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/scl_reg_sdap*]\n")
    f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/scl_reg_sdan*]\n")
    f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/stop_det*]\n")
    f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/sda_oe_reset*]\n")
    f_pdc.write("set_false_path -through [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*sda*]\n")
    f_pdc.write("set_false_path -through [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*scl*]\n")
    f_pdc.write("set_false_path -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/scl_reg_clkp*/D*]\n")
    f_pdc.write("set_false_path -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/*/sda_reg_clkp*/D*]\n")
    f_pdc.write("set_false_path -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/scl_reg_sdap*/D*]\n")
    f_pdc.write("set_false_path -to [get_nets lscc_i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*reset*]\n")
    f_pdc.write("set_false_path -from [get_ports scl_io] -to [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/u_i3c_p2s/stop_seq_reg*/D*]\n")
    f_pdc.write("set_false_path -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/gen_ctl_role_handshake.u_i3c_tgt_ctl_role_handshake/tgt_cr_takeover_ack*/Q*] -to [get_pins -hierarchical {lscc_i3c_controller_inst/u_i3c_mst/u_packet_to_i3cbus/u_packet_decode/gen_sec_mst.tgt_cr_takeover_ack_ss[0]/D*}]\n")
    f_pdc.write("set_false_path -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/gen_ctl_role_handshake.u_i3c_tgt_ctl_role_handshake/tgt_cr_handoff_req*/Q*] -to [get_pins -hierarchical {lscc_i3c_controller_inst/u_i3c_mst/u_packet_to_i3cbus/u_packet_decode/gen_sec_mst.tgt_cr_handoff_req_ss[0]/D*}]\n")

    f_pdc.write("\n")
    f_pdc.write("set_multicycle_path 2 -hold -end -from [get_pins -hierarchical *i3c_controller_inst/u_i3c_mst/gen_sc.u_sc_i3c_tgt/u_i3c_tgt_main/*/Q]\n")


    f_pdc.write("\n")
    f_pdc.write("##================================================================================##\n")
    f_pdc.write("## Clock Pin Constraints \n")
    f_pdc.write("##================================================================================##\n")
    f_pdc.write("ldc_set_attribute {USE_PRIMARY=FALSE} [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/*sda_i*]\n")
    f_pdc.write("ldc_set_attribute {USE_PRIMARY=FALSE} [get_nets -hierarchical *i3c_controller_inst/u_i3c_mst/*/*sda_i*]\n")


f_pdc.write("\n")
f_pdc.write("##================================================================================##\n")
f_pdc.write("## False Path constraints \n")
f_pdc.write("##================================================================================##\n")
f_pdc.write("set_false_path -from [get_ports rst_n_i]\n")

f_pdc.write("\n")
f_pdc.write("##================================================================================##\n")
f_pdc.write("## Maximum skew constraints \n")
f_pdc.write("##================================================================================##\n")
f_pdc.write("set_max_skew [get_pins -hierarchical {*i3c_controller_inst/gen_prim*.u_i3c_scl*/I *i3c_controller_inst/gen_prim*.u_i3c_scl*/T *i3c_controller_inst/gen_prim*.u_i3c_sda*/I *i3c_controller_inst/gen_prim*.u_i3c_sda*/T}] 2\n")

f_pdc.write("\n")
f_pdc.write("##================================END OF COSTRAINTS===============================##\n")


f_pdc.close()
