// Verilog netlist produced by program LSE 
// Netlist written on Fri Mar 13 16:33:49 2026
// Source file index table: 
// Object locations will have the form @<file_index>(<first_ line>[<left_column>],<last_line>[<right_column>])
// file 0 "c:/lscc/radiant/2025.2/ip/lfmxo4/ram_dp/rtl/lscc_lfmxo4_ram_dp.v"
// file 1 "c:/lscc/radiant/2025.2/ip/lfmxo4/ram_dp_true/rtl/lscc_lfmxo4_ram_dp_true.v"
// file 2 "c:/lscc/radiant/2025.2/ip/lfmxo4/ram_dq/rtl/lscc_lfmxo4_ram_dq.v"
// file 3 "c:/lscc/radiant/2025.2/ip/common/adder/rtl/lscc_adder.v"
// file 4 "c:/lscc/radiant/2025.2/ip/common/adder_subtractor/rtl/lscc_add_sub.v"
// file 5 "c:/lscc/radiant/2025.2/ip/common/complex_mult/rtl/lscc_complex_mult.v"
// file 6 "c:/lscc/radiant/2025.2/ip/common/counter/rtl/lscc_cntr.v"
// file 7 "c:/lscc/radiant/2025.2/ip/common/distributed_dpram/rtl/lscc_distributed_dpram.v"
// file 8 "c:/lscc/radiant/2025.2/ip/common/distributed_rom/rtl/lscc_distributed_rom.v"
// file 9 "c:/lscc/radiant/2025.2/ip/common/distributed_spram/rtl/lscc_distributed_spram.v"
// file 10 "c:/lscc/radiant/2025.2/ip/common/fifo/rtl/lscc_fifo.v"
// file 11 "c:/lscc/radiant/2025.2/ip/common/fifo_dc/rtl/lscc_fifo_dc.v"
// file 12 "c:/lscc/radiant/2025.2/ip/common/mult_accumulate/rtl/lscc_mult_accumulate.v"
// file 13 "c:/lscc/radiant/2025.2/ip/common/mult_add_sub/rtl/lscc_mult_add_sub.v"
// file 14 "c:/lscc/radiant/2025.2/ip/common/mult_add_sub_sum/rtl/lscc_mult_add_sub_sum.v"
// file 15 "c:/lscc/radiant/2025.2/ip/common/multiplier/rtl/lscc_multiplier.v"
// file 16 "c:/lscc/radiant/2025.2/ip/common/ram_dp/rtl/lscc_ram_dp.v"
// file 17 "c:/lscc/radiant/2025.2/ip/common/ram_dp_true/rtl/lscc_ram_dp_true.v"
// file 18 "c:/lscc/radiant/2025.2/ip/common/ram_dq/rtl/lscc_ram_dq.v"
// file 19 "c:/lscc/radiant/2025.2/ip/common/ram_shift_reg/rtl/lscc_shift_register.v"
// file 20 "c:/lscc/radiant/2025.2/ip/common/rom/rtl/lscc_rom.v"
// file 21 "c:/lscc/radiant/2025.2/ip/common/subtractor/rtl/lscc_subtractor.v"
// file 22 "c:/lscc/radiant/2025.2/ip/pmi/pmi_add.v"
// file 23 "c:/lscc/radiant/2025.2/ip/pmi/pmi_addsub.v"
// file 24 "c:/lscc/radiant/2025.2/ip/pmi/pmi_complex_mult.v"
// file 25 "c:/lscc/radiant/2025.2/ip/pmi/pmi_counter.v"
// file 26 "c:/lscc/radiant/2025.2/ip/pmi/pmi_distributed_dpram.v"
// file 27 "c:/lscc/radiant/2025.2/ip/pmi/pmi_distributed_rom.v"
// file 28 "c:/lscc/radiant/2025.2/ip/pmi/pmi_distributed_shift_reg.v"
// file 29 "c:/lscc/radiant/2025.2/ip/pmi/pmi_distributed_spram.v"
// file 30 "c:/lscc/radiant/2025.2/ip/pmi/pmi_fifo.v"
// file 31 "c:/lscc/radiant/2025.2/ip/pmi/pmi_fifo_dc.v"
// file 32 "c:/lscc/radiant/2025.2/ip/pmi/pmi_mac.v"
// file 33 "c:/lscc/radiant/2025.2/ip/pmi/pmi_mult.v"
// file 34 "c:/lscc/radiant/2025.2/ip/pmi/pmi_multaddsub.v"
// file 35 "c:/lscc/radiant/2025.2/ip/pmi/pmi_multaddsubsum.v"
// file 36 "c:/lscc/radiant/2025.2/ip/pmi/pmi_ram_dp.v"
// file 37 "c:/lscc/radiant/2025.2/ip/pmi/pmi_ram_dp_be.v"
// file 38 "c:/lscc/radiant/2025.2/ip/pmi/pmi_ram_dp_true.v"
// file 39 "c:/lscc/radiant/2025.2/ip/pmi/pmi_ram_dq.v"
// file 40 "c:/lscc/radiant/2025.2/ip/pmi/pmi_ram_dq_be.v"
// file 41 "c:/lscc/radiant/2025.2/ip/pmi/pmi_rom.v"
// file 42 "c:/lscc/radiant/2025.2/ip/pmi/pmi_sub.v"
// file 43 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/acc54.v"
// file 44 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/adc.v"
// file 45 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/bb_adc.v"
// file 46 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/bb_cdr.v"
// file 47 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/bb_i3c_a.v"
// file 48 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/bfd1p3kx.v"
// file 49 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/bfd1p3lx.v"
// file 50 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/bnkref18.v"
// file 51 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/config_ip.v"
// file 52 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/config_lmmib.v"
// file 53 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/config_lmmig.v"
// file 54 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/cre.v"
// file 55 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ddrdll.v"
// file 56 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/diffio18.v"
// file 57 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/dlldel.v"
// file 58 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/dp16k.v"
// file 59 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/dpsc512k.v"
// file 60 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/dqsbuf.v"
// file 61 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ebr.v"
// file 62 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/eclkdiv.v"
// file 63 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/eclksync.v"
// file 64 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/fifo16k.v"
// file 65 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/i2cfifo.v"
// file 66 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ifd1p3bx.v"
// file 67 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ifd1p3dx.v"
// file 68 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ifd1p3ix.v"
// file 69 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ifd1p3jx.v"
// file 70 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/jtag.v"
// file 71 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/lram.v"
// file 72 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/m18x36.v"
// file 73 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/mipi.v"
// file 74 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/mult18.v"
// file 75 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/mult18x18.v"
// file 76 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/mult18x36.v"
// file 77 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/mult36.v"
// file 78 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/mult36x36.v"
// file 79 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/mult9.v"
// file 80 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/mult9x9.v"
// file 81 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/multaddsub18x18.v"
// file 82 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/multaddsub18x18wide.v"
// file 83 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/multaddsub18x36.v"
// file 84 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/multaddsub36x36.v"
// file 85 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/multaddsub9x9wide.v"
// file 86 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/multiboot.v"
// file 87 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/multpreadd18x18.v"
// file 88 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/multpreadd9x9.v"
// file 89 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ofd1p3bx.v"
// file 90 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ofd1p3dx.v"
// file 91 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ofd1p3ix.v"
// file 92 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/ofd1p3jx.v"
// file 93 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/osc.v"
// file 94 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/osca.v"
// file 95 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/pdp16k.v"
// file 96 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/pdpsc16k.v"
// file 97 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/pdpsc512k.v"
// file 98 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/pll.v"
// file 99 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/plla.v"
// file 100 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/pllrefcs.v"
// file 101 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/pmu.v"
// file 102 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/preadd9.v"
// file 103 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/refmux.v"
// file 104 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/reg18.v"
// file 105 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/sedc.v"
// file 106 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/seio18.v"
// file 107 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/seio33.v"
// file 108 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/sgmiicdr.v"
// file 109 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/sp16k.v"
// file 110 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/sp512k.v"
// file 111 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/tsalla.v"
// file 112 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/wdt.v"
// file 113 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/dpr16x4.v"
// file 114 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/fd1p3bx.v"
// file 115 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/fd1p3dx.v"
// file 116 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/fd1p3ix.v"
// file 117 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/fd1p3jx.v"
// file 118 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/gsr.v"
// file 119 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/ib.v"
// file 120 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/ob.v"
// file 121 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/obz.v"
// file 122 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/pclkdivsp.v"
// file 123 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/spr16x4.v"
// file 124 "c:/lscc/radiant/2025.2/cae_library/simulation/verilog/uaplatform/widefn9.v"

//
// Verilog Description of module ahb2apb
// module wrapper written out since it is a black-box. 
//

//

module ahb2apb (clk_i, rst_n_i, pclk_i, presetn_i, ahbl_hsel_i, ahbl_hready_i, 
            ahbl_haddr_i, ahbl_hburst_i, ahbl_hsize_i, ahbl_hmastlock_i, 
            ahbl_hprot_i, ahbl_htrans_i, ahbl_hwdata_i, ahbl_hwrite_i, 
            ahbl_hreadyout_o, ahbl_hresp_o, ahbl_hrdata_o, apb_pready_i, 
            apb_pslverr_i, apb_prdata_i, apb_psel_o, apb_paddr_o, apb_pwrite_o, 
            apb_pwdata_o, apb_penable_o) /* synthesis ORIG_MODULE_NAME="ahb2apb", LATTICE_IP_GENERATED="1", cpe_box=1 */ ;
    input clk_i;
    input rst_n_i;
    input pclk_i;
    input presetn_i;
    input ahbl_hsel_i;
    input ahbl_hready_i;
    input [31:0]ahbl_haddr_i;
    input [2:0]ahbl_hburst_i;
    input [2:0]ahbl_hsize_i;
    input ahbl_hmastlock_i;
    input [3:0]ahbl_hprot_i;
    input [1:0]ahbl_htrans_i;
    input [31:0]ahbl_hwdata_i;
    input ahbl_hwrite_i;
    output ahbl_hreadyout_o;
    output ahbl_hresp_o;
    output [31:0]ahbl_hrdata_o;
    input apb_pready_i;
    input apb_pslverr_i;
    input [31:0]apb_prdata_i;
    output apb_psel_o;
    output [31:0]apb_paddr_o;
    output apb_pwrite_o;
    output [31:0]apb_pwdata_o;
    output apb_penable_o;
    
    
    
endmodule
