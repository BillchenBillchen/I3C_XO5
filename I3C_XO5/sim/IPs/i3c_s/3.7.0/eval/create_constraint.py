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

def load_defines(define_name):
    with open('eval/dut_params.v', 'r') as f_params:
        for line in f_params:
            if define_name in line and line.startswith('`define'):
                parts = line.strip().split()
                if len(parts) >= 3:
                    return parts[2]
    return None

f_pdc = open('eval/constraint.pdc', 'w')

# clk_freq        = load_parameter("CLKI_FREQ")
clk_freq        = load_defines("SYSCLK_FREQ")
clk_period      = (1000.0/float(clk_freq))
enable_io_prim  = load_parameter("EN_IO_PRIM")

f_pdc.write("##================================================================================##\n")
f_pdc.write("## Copy these constraints to your top-level pdc and replace path with actual path \n")
f_pdc.write("##================================================================================##\n")

# if ((float(clk_freq)) < 1.0):
#     f_pdc.write("set CLK_PERIOD 1000\n")
# else:
#     f_pdc.write("set CLK_PERIOD %0.1f\n" % clk_period)

f_pdc.write("set CLK_PERIOD %0.1f\n" % clk_period)

if (clk_period <= 100):
    f_pdc.write("set EDGE_VALUE %0.1f\n" % (clk_period/2))
else:
    f_pdc.write("set EDGE_VALUE 40\n")

f_pdc.write("\n")
f_pdc.write("## Change SDA and SCL frequency according to your design \n")
f_pdc.write("set EDGEV_SCLV 40.0\n")
f_pdc.write("set SCL_PERIOD 80.0\n")
f_pdc.write("set EDGEV_SDAV 80.0\n")
f_pdc.write("set SDA_PERIOD 160.0\n")

f_pdc.write("\n")
f_pdc.write("##================================================================================##\n")
f_pdc.write("## Create clock constraints \n")
f_pdc.write("##================================================================================##\n")
f_pdc.write("create_clock -name {clk_i} -period $CLK_PERIOD -waveform \"0 $EDGE_VALUE\" [get_ports clk_i]\n")
f_pdc.write("create_clock -name scl_i -period $SCL_PERIOD -waveform \"0 $EDGEV_SCLV\" [get_ports scl_io]\n")
f_pdc.write("create_clock -name sda_i -period $SDA_PERIOD -waveform \"0 $EDGEV_SDAV\" [get_ports sda_io]\n")

f_pdc.write("\n")
f_pdc.write("##================================================================================##\n")
f_pdc.write("## False path constraints                                                           \n")
f_pdc.write("##================================================================================##\n")
f_pdc.write("set_false_path -from [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/*rst_n*]\n")
f_pdc.write("set_false_path -from [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*reset*]\n")
f_pdc.write("\n")

f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/sda_reg_sclp*]\n")
f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/sda_reg_scln*]\n")
f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/scl_reg_sdap*]\n")
f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/scl_reg_sdan*]\n")
f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/scl_reg_clkp*]\n")
f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/sda_reg_clkp*]\n")
f_pdc.write("\n")

f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/stop_det*]\n")
f_pdc.write("set_false_path -to [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/sda_oe_reset*]\n")
f_pdc.write("set_false_path -through [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*sda*]\n")
f_pdc.write("set_false_path -through [get_nets -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main/u_i3c_tgt_pattern_detector/*scl*]\n")

f_pdc.write("set_multicycle_path 2 -hold -end -from [get_pins -hierarchical *i3c_target_inst/u_i3c_tgt/u_i3c_tgt_main*/Q]\n")

if (enable_io_prim):
    f_pdc.write("set_max_skew [get_pins -hierarchical {*i3c_target_inst/gen_prim*.u_i3c_scl.SEIO33_inst/I *i3c_target_inst/gen_prim*.u_i3c_scl.SEIO33_inst/T *i3c_target_inst/gen_prim*.u_i3c_sda.SEIO33_inst/I *i3c_target_inst/gen_prim*.u_i3c_sda.SEIO33_inst/T}] 2\n")

f_pdc.close()
