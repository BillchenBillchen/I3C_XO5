`ifndef __RTL_MODULE__TB_TOP__
`define __RTL_MODULE__TB_TOP__
`timescale 1ns / 1ps
//==========================================================================
// Module : tb_top
//==========================================================================
module tb_top #

( //--begin_param--
//----------------------------
// Parameters
//----------------------------
 parameter                     SIMULATION = 1

) //--end_param--

( //--begin_ports--
//----------------------------
// Inputs
//----------------------------

//----------------------------
// Outputs
//----------------------------

); //--end_ports--



//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
`include "dut_params.v"

`define TGT_SEL 2
`define EN_I3C_SC0
`define EN_I3C_TGT0
`define EN_I3C_TGT1

`define I3C_SLV_MODEL(ip_name)                        ip_name``_ipgen_``i3c_s2p

`define MST_BFM_INST                                  `BFM_PATH.reg_intf_bfm

`ifdef EN_I3C_TGT1
  `define TGT1_BFM_INST                               `BFM_PATH.tgt1_reg_intf_bfm
  `ifdef EN_I3C_TGT0
    `define TGT0_BFM_INST                             `BFM_PATH.tgt0_reg_intf_bfm
    `ifdef EN_I3C_SC0
      `define TGT2_BFM_INST                           `BFM_PATH.sc0_reg_intf_bfm
    `else
      `define TGT2_BFM_INST                           `BFM_PATH.tgt0_reg_intf_bfm
    `endif
  `else
    `ifdef EN_I3C_SC0
      `define TGT0_BFM_INST                           `BFM_PATH.tgt1_reg_intf_bfm
      `define TGT2_BFM_INST                           `BFM_PATH.sc0_reg_intf_bfm
    `else
      `define TGT0_BFM_INST                           `BFM_PATH.tgt1_reg_intf_bfm
      `define TGT2_BFM_INST                           `BFM_PATH.tgt1_reg_intf_bfm
    `endif
  `endif
`else
  `ifdef EN_I3C_TGT0
    `define TGT0_BFM_INST                             `BFM_PATH.tgt0_reg_intf_bfm
    `define TGT1_BFM_INST                             `BFM_PATH.tgt0_reg_intf_bfm
    `ifdef EN_I3C_SC0
      `define TGT2_BFM_INST                           `BFM_PATH.sc0_reg_intf_bfm
    `else
      `define TGT2_BFM_INST                           `BFM_PATH.tgt0_reg_intf_bfm
    `endif
  `else
    `define TGT0_BFM_INST                             `BFM_PATH.sc0_reg_intf_bfm
    `define TGT1_BFM_INST                             `BFM_PATH.sc0_reg_intf_bfm
    `define TGT2_BFM_INST                             `BFM_PATH.sc0_reg_intf_bfm
  `endif
`endif

`define BFM_FFW(WDATA)                                tb_top.fifo_intf_bfm.memw(WDATA);
`define BFM_FFR(EXPDATA,VERIFY,RDATA)                 tb_top.fifo_intf_bfm.memr(EXPDATA,VERIFY,RDATA);

`define MST_BFM_MEMW(ADDR,WDATA)                      if(EN_FIFOINTF) begin \
                                                        if(ADDR == 8'h30) \
                                                          `BFM_FFW(WDATA) \
                                                        else if(ADDR == 8'h11) \
                                                          @(posedge clk_i); \
                                                        else begin \
                                                          if(use_sc_bfm) \
                                                            `TGT2_BFM_INST.memw(ADDR,WDATA); \
                                                          else \
                                                            `MST_BFM_INST.memw(ADDR,WDATA); \
                                                        end \
                                                      end \
                                                      else begin \
                                                        if(use_sc_bfm) \
                                                          `TGT2_BFM_INST.memw(ADDR,WDATA); \
                                                        else \
                                                          `MST_BFM_INST.memw(ADDR,WDATA); \
                                                      end

`define MST_BFM_MEMR(ADDR,EXPDATA,VERIFY,RDATA)       if(EN_FIFOINTF) begin \
                                                        if(ADDR == 8'h40) \
                                                          `BFM_FFR(EXPDATA,VERIFY,RDATA) \
                                                        else begin \
                                                          if(use_sc_bfm) \
                                                            `TGT2_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                          else \
                                                            `MST_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                        end \
                                                      end \
                                                      else begin \
                                                        if(use_sc_bfm) \
                                                          `TGT2_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                        else \
                                                          `MST_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                      end

`define MST_BFM_WTINT                                 if(use_sc_bfm) begin \
                                                        `TGT2_BFM_INST.wait_int(); \
                                                      end \
                                                      else begin \
                                                        `MST_BFM_INST.wait_int(); \
                                                      end

`define TGT_BFM_MEMW(SEL,ADDR,WDATA)                  case(SEL) \
                                                        2'd0    : `TGT0_BFM_INST.memw(ADDR,WDATA); \
                                                        2'd1    : `TGT1_BFM_INST.memw(ADDR,WDATA); \
                                                        default : `TGT2_BFM_INST.memw(ADDR|8'h80,WDATA); \
                                                      endcase

`define TGT_BFM_MEMR(SEL,ADDR,EXPDATA,VERIFY,RDATA)   case(SEL) \
                                                        2'd0    : `TGT0_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                        2'd1    : `TGT1_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                        default : `TGT2_BFM_INST.memr(ADDR|8'h80,EXPDATA,VERIFY,RDATA); \
                                                      endcase

`define TGT_BFM_WTINT(SEL)                            case(SEL) \
                                                        2'd0    : `TGT0_BFM_INST.wait_int(); \
                                                        2'd1    : `TGT1_BFM_INST.wait_int(); \
                                                        default : `TGT2_BFM_INST.wait_int(); \
                                                      endcase

`define SC_BFM_MEMW(ADDR,WDATA)                       `TGT2_BFM_INST.memw(ADDR,WDATA);
`define SC_BFM_MEMR(ADDR,EXPDATA,VERIFY,RDATA)        `TGT2_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA);
`define SC_BFM_WTINT                                  `TGT2_BFM_INST.wait_int();


`ifdef SYSCLK_FREQ
localparam                    SYS_CLK_PERIOD = 1000/`SYSCLK_FREQ;
`else
localparam                    SYS_CLK_PERIOD = 1000/25;
`endif
`ifdef EXT_SCL_FREQ
localparam                    SCL_CLK_PERIOD = 1000/(`EXT_SCL_FREQ*2);
`else
localparam                    SCL_CLK_PERIOD = 1000/12.5;
`endif
localparam                    SLV_STATIC_ADDR = 7'h10;

localparam                    TB_APB_AWID = 32;
localparam                    TB_APB_DWID = 32;
localparam                    TB_AHBL_AWID = 32;
localparam                    TB_AHBL_DWID = 32;

localparam                    I2C_FRAME      = 1'b1;
localparam                    I3C_FRAME      = 1'b0;
localparam                    END_OF_FRAME   = 1'b1;
localparam                    CONT_NXT_FRAME = 1'b0;
localparam                    WAIT_NXTPKT    = 1'b1;
localparam                    NOWAIT_NXTPKT  = 1'b0;
localparam                    START_OF_FRAME = 1'b0;
localparam                    REP_START      = 1'b1;
localparam                    IBI_NAK_RESP   = 1'b1;
localparam                    IBI_ACK_RESP   = 1'b0;

localparam                    TGT_LOOPBK_EN0 = 0;
localparam                    TGT_LOOPBK_EN1 = 0;
localparam                    SC_LOOPBK_EN0  = 0;

localparam integer            SYS_CLK_PERIOD_INT = SYS_CLK_PERIOD;
localparam integer            I2C_DIV_INT        = ((SYS_CLK_PERIOD_INT > 500)? 1 :
                                                    (500 % SYS_CLK_PERIOD_INT)? ((500 / SYS_CLK_PERIOD_INT) + 1) :
                                                                                 (500 / SYS_CLK_PERIOD_INT));
//--------------------------------------------------------------------------
//--- Combinational Wire/Reg ---
//--------------------------------------------------------------------------

reg                           clk_i;
reg                           rst_n_i;
reg                           scl_src_i;

tri1                          sda_io;
tri1                          scl_io;

wire                          mst_int_o;
wire                          tgt0_int_o;
wire                          tgt1_int_o;
wire                          sc0_int_o;

reg           [6:0]           tgt_addr_static;
reg           [7:0]           wdata_mem[255:0];

reg                           test_error;
integer                       data_err_cnt;
integer                       csr_err_cnt;
integer                       daa_err_cnt;
integer                       data_exp_cnt;
integer                       data_ok_cnt;

wire                          clk_w;
reg           [7:0]           sys_clkdiv;
reg           [7:0]           od_timer;
reg           [7:0]           i2c_clkdiv;
reg           [1:0]           idle_line_sel;
reg                           idle_line_lvl;
reg                           use_sc_bfm;

//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------


// SCL 12.5 MHz
initial begin
  scl_src_i = 1'b0;
  forever begin
    scl_src_i = #(SCL_CLK_PERIOD/2) ~scl_src_i;
  end
end

// System clock
initial begin
  clk_i = 1'b0;
  forever begin
    clk_i = #(SYS_CLK_PERIOD/2) ~clk_i;
  end
end

assign clk_w = (CLKDOMAIN == "SYNC")? scl_src_i : clk_i;

initial begin
  sys_clkdiv = DEFAULT_RATE;
  od_timer   = DEFAULT_ODTIMER;
  i2c_clkdiv = I2C_RATE;
  idle_line_sel = 2'b11; // (scl & sda)
  idle_line_lvl = 1'b1;
  use_sc_bfm    = 1'b0;
end

task wait_trans_then_idle;
  input [31:0]  num_clk_cycles;
  reg   [15:0]  clkdiv;
  begin
    if(od_timer > 0)
      clkdiv = (od_timer+1) * (sys_clkdiv+1);
    else
      clkdiv = (sys_clkdiv+1);

    wait_line_idle(num_clk_cycles,clkdiv,1'b1);
  end
endtask // wait_trans_then_idle

task wait_idle;
  input [31:0]  num_clk_cycles;
  reg   [15:0]  clkdiv;
  begin
    if(od_timer > 0)
      clkdiv = (od_timer+1) * (sys_clkdiv+1);
    else
      clkdiv = (sys_clkdiv+1);

    wait_line_idle(num_clk_cycles,clkdiv,1'b0);
  end
endtask // wait_idle

task wait_idle_i2c_clkdiv;
  input [31:0]  num_clk_cycles;
  reg   [15:0]  clkdiv;
  begin
    if(sys_clkdiv > i2c_clkdiv)
      clkdiv = (sys_clkdiv+1);
    else
      clkdiv = (i2c_clkdiv+1);

    wait_line_idle(num_clk_cycles,clkdiv,1'b0);
  end
endtask // wait_idle_i2c_clkdiv

task wait_line_idle;
  input [31:0]  num_clk_cycles;
  input [15:0]  clkdiv;
  input         wait_sda_scl_low;
  reg done, chk_idle_break;
  integer wait_cnt;
  integer cntr, j;
  begin
    done = 1'b0;
    cntr = 0;
    wait_cnt = clkdiv;
    if(wait_sda_scl_low) begin
      case(idle_line_sel)
        2'b01 : begin // sda
          wait(sda_io == ~idle_line_lvl);
        end
        2'b10 : begin // scl
          wait(scl_io == ~idle_line_lvl);
        end
        default : begin // scl & sda
          wait((scl_io & sda_io) == ~idle_line_lvl);
        end
      endcase
    end
    while(!done) begin
      chk_idle_break = 1'b0;
      for(j=0; j<wait_cnt; j=j+1) begin
        @(posedge clk_i);
        case(idle_line_sel)
          2'b01 : begin // sda
            if(sda_io == ~idle_line_lvl) begin
              chk_idle_break = 1'b1;
              cntr = 0;
            end
          end
          2'b10 : begin // scl
            if(scl_io == ~idle_line_lvl) begin
              chk_idle_break = 1'b1;
              cntr = 0;
            end
          end
          default : begin // scl & sda
            if((scl_io & sda_io) == ~idle_line_lvl) begin
              chk_idle_break = 1'b1;
              cntr = 0;
            end
          end
        endcase
      end
      if(~chk_idle_break) cntr = cntr + 1;
      done = (cntr >= num_clk_cycles);
    end
  end
endtask // wait_line_idle


task initialize_tb_mem;
  reg [8:0] mem_addr;
  begin
    for(mem_addr=0; mem_addr<256; mem_addr=mem_addr+1) begin
      wdata_mem[mem_addr] = $random;
    end
  end
endtask // initialize_tb_mem

// ==========================================================================
// I3C Controller API Tasks
// ==========================================================================

task initialize_i3c_controller;
  begin
    $display("%12d: ==== I3C CONTROLLER INITIALIZATION", $stime);
    `MST_BFM_MEMW(8'h02, 8'h34)  // controller config 0
                                 // - ibi_auto_resp, ignore_cmd_done, ignore NAK
    `MST_BFM_MEMW(8'h06, 8'h03)  // HDR config 0 - no_crc_after_term=0, en_wr_early_term=1, en_wrcmd_acknak_cap=1
    `MST_BFM_MEMW(8'h22, 8'hFF)  // interrupt enable 0
    `MST_BFM_MEMW(8'h26, 8'hFF)  // interrupt enable 1
    `MST_BFM_MEMW(8'h2E, 8'hFF)  // interrupt enable 2
    `MST_BFM_MEMW(8'h17, 8'h20)  // reduce sc timer
    `MST_BFM_MEMW(8'h18, 8'h00)  // reduce sc timer
  end
endtask // initialize_i3c_controller

task send_private_write;
  input  [6:0]    tgt_addr;
  input  [7:0]    length;
  input  [7:0]    mem_start_addr;
  input           start0_rstart1;
  input           last_burst;
  input           wait_nextpkt;
  input           i2c1_i3c0;

  reg    [7:0]    mem_addr;
  reg    [7:0]    control;
  integer         i;
  begin
    if(i2c1_i3c0)
      $display("%12d: ==== Private I2C Write", $stime);
    else
      $display("%12d: ==== Private I3C Write", $stime);
    control[0]    = 1'b0;         // -> not CCC
    control[1]    = start0_rstart1;//-> repeated start
    control[2]    = last_burst;   // -> terminate frame with P
    control[3]    = 1'b0;         // -> not CCC_start
    control[4]    = i2c1_i3c0;    // -> I3C protocol
    control[5]    = wait_nextpkt; // -> wait for next packet
    control[7:6]  = 3'd0;

    `MST_BFM_MEMW(8'h30, control) // Control
    `MST_BFM_MEMW(8'h30, {tgt_addr,1'b0})  // {7b target address,W}
    `MST_BFM_MEMW(8'h30, length)  // length (number of bytes) of data read
    for(i=0; i<length; i=i+1) begin
      mem_addr = mem_start_addr + i;
      `MST_BFM_MEMW(8'h30, wdata_mem[mem_addr])  // write data
    end
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_private_write

task send_private_read;
  input  [6:0]    tgt_addr;
  input  [7:0]    length;
  input           start0_rstart1;
  input           last_burst;
  input           wait_nextpkt;
  input           i2c1_i3c0;
  reg    [7:0]    control;
  begin
    if(i2c1_i3c0)
      $display("%12d: ==== Private I2C Read", $stime);
    else
      $display("%12d: ==== Private I3C Read", $stime);
    control[0]    = 1'b0;         // -> not CCC
    control[1]    = start0_rstart1; // -> repeated start
    control[2]    = last_burst;   // -> terminate frame with P
    control[3]    = 1'b0;         // -> not CCC_start
    control[4]    = i2c1_i3c0;    // -> I3C protocol
    control[5]    = wait_nextpkt; // -> wait for next packet
    control[7:6]  = 3'd0;
                                 // [0] = 0 -> not CCC
                                 // [1] = 0 -> no repeated start present in frame
                                 // [2] = 1 -> terminate frame with P
                                 // [3] = 0 -> not CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, control) // Control
    `MST_BFM_MEMW(8'h30, {tgt_addr,1'b1})  // {7b target address,R}
    `MST_BFM_MEMW(8'h30, length)  // length (number of bytes) of data read
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_private_read

task send_enter_daa_ccc;
  input [6:0]  tgt_addr;
  input [1:0]  fml;     // 0 - middle, 1 - first, 2 - last, 3 - first and last
  input [6:0]  num_tgt;
  begin
    $display("%12d: ==== SEND BROADCAST ENTER DAA", $stime);
    if((fml == 2'd1) || (fml == 2'd3)) begin
      `MST_BFM_MEMW(8'h30, 8'h0D)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 0 -> not repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 1 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `MST_BFM_MEMW(8'h30, 8'h01 + num_tgt)  // Length = 0x1 + number of target address that follows
      `MST_BFM_MEMW(8'h30, 8'h07)  // CCC Code - ENTDAA CCC
    end

    `MST_BFM_MEMW(8'h30, {tgt_addr,~^tgt_addr})  // {7b Dynamic Address assigned to target,Parity bit}

    if((fml == 2'd2) || (fml == 2'd3)) begin
      `MST_BFM_MEMW(8'h11, 8'h01)  // start
    end
  end
endtask // send_enter_daa_ccc

task send_enter_daa_ccc_1tgt;
  input [6:0]  tgt_addr;
  begin
    send_enter_daa_ccc(tgt_addr,2'd3,7'd1);
  end
endtask // send_enter_daa_ccc_1tgt

task send_enter_hdr_ddr;
  input           wait_nextpkt;
  reg    [7:0]    control;
  begin
    $display("%12d: ==== I3C Enter HDR-DDR", $stime);
    control[0]    = 1'b1;         // -> CCC
    control[1]    = 1'b0;         // -> not repeated start
    control[2]    = 1'b0;         // -> do not terminate frame with P
    control[3]    = 1'b1;         // -> CCC_start
    control[4]    = 1'b0;         // -> I3C protocol
    control[5]    = wait_nextpkt; // -> wait for next packet
    control[6]    = 1'b0;         // -> rsvd
    control[7]    = 1'b0;         // -> HDR mode
    `MST_BFM_MEMW(8'h30, control) // Control
    `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // {7E,W}
    `MST_BFM_MEMW(8'h30, 8'd1)    // length == 1
    `MST_BFM_MEMW(8'h30, 8'h20)   // CCC - HDR-DDR
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_enter_hdr_ddr

task send_ccc_entasx;
  input           broadcast;
  input  [1:0]    ccc_code;
  input  [6:0]    tgt_addr;
  input  [1:0]    fml; // [1] - first target, [0] - last target
  input           hdr1_sdr0;
  reg             wait_nextpkt;
  begin
    if(hdr1_sdr0) begin
      if(broadcast)
        $display("%12d: ==== SEND (HDR-DDR) BROADCAST ENTAS %0d ", $stime,ccc_code);
      else
        $display("%12d: ==== SEND (HDR-DDR) DIRECT ENTAS %0d ", $stime,ccc_code);
    end
    else begin
      if(broadcast)
        $display("%12d: ==== SEND BROADCAST ENTAS %0d ", $stime,ccc_code);
      else
        $display("%12d: ==== SEND DIRECT ENTAS %0d ", $stime,ccc_code);
    end

    if(hdr1_sdr0) begin // HDR
      if(broadcast | fml[1]) begin
        `MST_BFM_MEMW(8'h30, 8'hAB)  // Control
                                     // [0] = 1 -> CCC1_PRIV0
                                     // [1] = 1 -> repeated start
                                     // [2] = 0 -> Stop
                                     // [3] = 1 -> CCC_start
                                     // [4] = 0 -> rsvd
                                     // [5] = 1 -> wait_nextpkt
                                     // [6] = 0 -> rsvd
                                     // [7] = 1 -> HDR mode
        `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
        `MST_BFM_MEMW(8'h30, 8'h03)  // Length = 0x3
        `MST_BFM_MEMW(8'h30, 8'h00)  // {W, user_command_code[6:0]}
        `MST_BFM_MEMW(8'h30, {~broadcast,(7'd2+ccc_code)})  // CCC Code - ENTASx CCC
        `MST_BFM_MEMW(8'h30, 8'h00)  // 0 Padding - since no defining byte
      end
      if(~broadcast) begin // direct
        `MST_BFM_MEMW(8'h30, 8'hA3)  // Control
                                     // [0] = 1 -> CCC1_PRIV0
                                     // [1] = 1 -> repeated start
                                     // [2] = 0 -> Stop
                                     // [3] = 0 -> CCC_start
                                     // [4] = 0 -> rsvd
                                     // [5] = 1 -> wait_nextpkt
                                     // [6] = 0 -> rsvd
                                     // [7] = 1 -> HDR mode
        `MST_BFM_MEMW(8'h30, {tgt_addr,1'b0})  // {7b target DA,W}
        `MST_BFM_MEMW(8'h30, 8'h03)  // Length = 0x3
        `MST_BFM_MEMW(8'h30, 8'h00)  // {W, user_command_code[6:0]}
        `MST_BFM_MEMW(8'h30, 8'h00)  // dummy data
        `MST_BFM_MEMW(8'h30, 8'h00)  // dummy data
      end
    end // HDR
    else begin // SDR
      if(broadcast | fml[1]) begin
        `MST_BFM_MEMW(8'h30, {2'd0,1'b0,2'd1,broadcast,2'd1})  // Control
                                     // [0] = 1 -> CCC1_PRIV0
                                     // [1] = 0 -> not repeated start
                                     // [2] = 0 -> Stop
                                     // [3] = 1 -> CCC_start
                                     // [4] = 0 -> rsvd
                                     // [5] = 0 -> wait_nextpkt
                                     // [7:6] = 0 -> rsvd
        `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
        `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
        `MST_BFM_MEMW(8'h30, {~broadcast,(7'd2+ccc_code)})  // CCC Code - ENTASx CCC
      end

      wait_nextpkt = ~fml[0];
      if(~broadcast) begin // direct
        `MST_BFM_MEMW(8'h30, {2'd0,wait_nextpkt,2'd0,~wait_nextpkt,2'd3})  // Control
                                     // [0] = 1 -> CCC1_PRIV0
                                     // [1] = 1 -> repeated start
                                     // [2] = 1 -> Stop
                                     // [3] = 0 -> not CCC_start
                                     // [4] = 0 -> rsvd
                                     // [5] = wait_nextpkt
                                     // [7:6] = 0 -> rsvd
        `MST_BFM_MEMW(8'h30, {tgt_addr,1'b0})  // {7b target DA,W}
        `MST_BFM_MEMW(8'h30, 8'h00)  // Length = 0x0
      end
    end // SDR
    if(broadcast | fml[0]) begin
      `MST_BFM_MEMW(8'h11, 8'h01)  // start
    end
  end
endtask // send_ccc_entasx

task send_ccc_broadcast_entasx;
  input  [1:0]    ccc_code;
  begin
    send_ccc_entasx(1'b1,ccc_code,7'd0,2'd0,1'b0);
  end
endtask // send_ccc_broadcast_entasx

task send_ccc_direct_entasx_1tgt;
  input  [1:0]    ccc_code;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_entasx(1'b0,ccc_code,tgt_addr,2'd3,1'b0);
  end
endtask // send_ccc_direct_entasx_1tgt

task send_ccc_direct_entasx_multi_tgt;
  input  [1:0]    ccc_code;
  input  [6:0]    tgt_addr;
  input  [1:0]    fml;
  begin
    send_ccc_entasx(1'b0,ccc_code,tgt_addr,fml,1'b0);
  end
endtask // send_ccc_direct_entasx_multi_tgt

task send_ccc_enec_disec;
  input  [1:0]    enec_disec_typ; // {broad0_direct1,enec_disec1}
  input  [2:0]    hj_sm_int;
  input  [6:0]    tgt_addr;
  input  [1:0]    multiple_tgt; // [1] - first target, [0] - multiple target follows

  reg    [7:0]    ccc_code;
  reg    [7:0]    en_dis_event;
  begin
    en_dis_event = (enec_disec_typ[0])? ({4'd0,hj_sm_int[2],1'b0,hj_sm_int[1:0]}) : // disable event
                                        ({4'd0,hj_sm_int[2],1'b0,hj_sm_int[1:0]});  // enable event
    case(enec_disec_typ)
      2'b01   : begin
        $display("%12d: ==== SEND BROADCAST DISEC", $stime);
        ccc_code = 8'h01;
      end
      2'b10   : begin
        $display("%12d: ==== SEND DIRECT ENEC", $stime);
        ccc_code = 8'h80;
      end
      2'b11   : begin
        $display("%12d: ==== SEND DIRECT DISEC", $stime);
        ccc_code = 8'h81;
      end
      default : begin
        $display("%12d: ==== SEND BROADCAST ENEC", $stime);
        ccc_code = 8'h00;
      end
    endcase
    if(~enec_disec_typ[1] | multiple_tgt[1]) begin // broadcast or first time sending direct
      `MST_BFM_MEMW(8'h30, 8'h09)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 0 -> not repeated start
                                   // [2] = 0 -> Stop
                                   // [3] = 1 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `MST_BFM_MEMW(8'h30, (8'h01+{7'd0,~enec_disec_typ[1]}))  // Length = 0x1+(1 if broadcast)
      `MST_BFM_MEMW(8'h30, ccc_code)  // CCC Code - ENEC/DISEC CCC
    end

    if(~enec_disec_typ[1]) begin // broadcast
      `MST_BFM_MEMW(8'h30, en_dis_event)  // enable/disable event
    end
    else begin // direct
      `MST_BFM_MEMW(8'h30, {5'd0,~multiple_tgt[0],2'd3})  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 1 -> repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 0 -> not CCC_start
                                   // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {tgt_addr,1'b0})  // {7b target DA, W}
      `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
      `MST_BFM_MEMW(8'h30, en_dis_event)  // enable/disable event
    end
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_ccc_enec_disec

task send_ccc_broadcast_enec;
  input  [2:0]    hj_sm_int;
  begin
    send_ccc_enec_disec(2'd0,hj_sm_int,7'h00,2'd0);
  end
endtask // send_ccc_broadcast_enec

task send_ccc_broadcast_disec;
  input  [2:0]    hj_sm_int;
  begin
    send_ccc_enec_disec(2'd1,hj_sm_int,7'h00,2'd0);
  end
endtask // send_ccc_broadcast_disec

task send_ccc_direct_enec_1tgt;
  input  [2:0]    hj_sm_int;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_enec_disec(2'd2,hj_sm_int,tgt_addr,2'd2);
  end
endtask // send_ccc_direct_enec

task send_ccc_direct_disec_1tgt;
  input  [2:0]    hj_sm_int;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_enec_disec(2'd3,hj_sm_int,tgt_addr,2'd2);
  end
endtask // send_ccc_direct_disec_1tgt

task send_ccc_direct_enec_multi_tgt;
  input  [2:0]    hj_sm_int;
  input  [6:0]    tgt_addr;
  input           first_tgt;
  begin
    send_ccc_enec_disec(2'd2,hj_sm_int,tgt_addr,{first_tgt,1'b1});
  end
endtask // send_ccc_direct_enec_multi_tgt

task send_ccc_direct_disec_multi_tgt;
  input  [2:0]    hj_sm_int;
  input  [6:0]    tgt_addr;
  input           first_tgt;
  begin
    send_ccc_enec_disec(2'd3,hj_sm_int,tgt_addr,{first_tgt,1'b1});
  end
endtask // send_ccc_direct_disec_multi_tgt

task send_ccc_rstdaa;
  begin
    $display("%12d: ==== SEND BROADCAST RSTDAA", $stime);
    `MST_BFM_MEMW(8'h30, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
    `MST_BFM_MEMW(8'h30, 8'h06)  // CCC Code - RSTDAA CCC
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_ccc_rstdaa

task send_ccc_mwl_mrl;
  input  [2:0]    mwl_mrl_typ; // {broad0_direct1,set0_get1,mwl0_mrl1}
  input  [15:0]   mwl_mrl_value;  // MWL or MRL value (this is multiple of 16)
  input  [6:0]    tgt_addr;
  input           ibi_en;   // include IBI max payload size in SET/GET MRL
  input  [7:0]    ibi_mps;  // IBI max payload size

  reg    [1:0]    payldcnt;
  reg    [7:0]    ccc_code;
  begin
    if(mwl_mrl_typ[0] & ibi_en)
      payldcnt = 2'd3;
    else
      payldcnt = 2'd2;

    case(mwl_mrl_typ)
      3'b001  : begin
        $display("%12d: ==== SEND BROADCAST SET MRL", $stime);
        ccc_code = 8'h0A;
      end
      3'b010,
      3'b110  : begin
        $display("%12d: ==== SEND DIRECT GET MWL", $stime);
        ccc_code = 8'h8B;
      end
      3'b011,
      3'b111  : begin
        $display("%12d: ==== SEND DIRECT GET MRL", $stime);
        ccc_code = 8'h8C;
      end
      3'b100  : begin
        $display("%12d: ==== SEND DIRECT SET MWL", $stime);
        ccc_code = 8'h89;
      end
      3'b101  : begin
        $display("%12d: ==== SEND DIRECT SET MRL", $stime);
        ccc_code = 8'h8A;
      end
      default : begin
        $display("%12d: ==== SEND BROADCAST SET MWL", $stime);
        ccc_code = 8'h09;
      end
    endcase
    `MST_BFM_MEMW(8'h30, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}

    if(mwl_mrl_typ[2:1] == 2'd0) // broadcast
      `MST_BFM_MEMW(8'h30, 8'h01+payldcnt)  // Length = 0x1+payldcnt
    else
      `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1

    `MST_BFM_MEMW(8'h30, ccc_code)  // CCC Code

    if(mwl_mrl_typ[2:1] == 2'd0) begin // broadcast
      `MST_BFM_MEMW(8'h30, mwl_mrl_value[15:8])  // MWL/MRL msb
      `MST_BFM_MEMW(8'h30, mwl_mrl_value[7:0])   // MWL/MRL lsb
      if(mwl_mrl_typ[0] & ibi_en)
        `MST_BFM_MEMW(8'h30, ibi_mps)      // IBI mps
    end
    else begin // direct
      `MST_BFM_MEMW(8'h30, 8'h07)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 1 -> repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 0 -> not CCC_start
                                   // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {tgt_addr,mwl_mrl_typ[1]})  // {7b Dynamic Address assigned to target, set0_get1}
      `MST_BFM_MEMW(8'h30, {6'd0,payldcnt})  // Length = payldcnt
      if(~mwl_mrl_typ[1]) begin // set
        `MST_BFM_MEMW(8'h30, mwl_mrl_value[15:8])   // MWL/MRL msb
        `MST_BFM_MEMW(8'h30, mwl_mrl_value[7:0])    // MWL/MRL lsb
        if(mwl_mrl_typ[0] & ibi_en) begin
          `MST_BFM_MEMW(8'h30, ibi_mps)      // IBI mps
        end
      end
    end

    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_ccc_mwl_mrl

task send_ccc_broadcast_set_mwl;
  input  [15:0]   mwl_mrl_value;
  begin
    send_ccc_mwl_mrl(3'd0,mwl_mrl_value,7'd0,1'b0,8'd0);
  end
endtask // send_ccc_broadcast_set_mwl

task send_ccc_broadcast_set_mrl;
  input  [15:0]   mwl_mrl_value;
  begin
    send_ccc_mwl_mrl(3'd1,mwl_mrl_value,7'd0,1'b0,8'd0);
  end
endtask // send_ccc_broadcast_set_mrl

task send_ccc_broadcast_set_mrl_ibi;
  input  [15:0]   mwl_mrl_value;
  input  [7:0]    ibi_mps;
  begin
    send_ccc_mwl_mrl(3'd1,mwl_mrl_value,7'd0,1'b1,ibi_mps);
  end
endtask // send_ccc_broadcast_set_mrl_ibi

task send_ccc_direct_set_mwl;
  input  [6:0]    tgt_addr;
  input  [15:0]   mwl_mrl_value;
  begin
    send_ccc_mwl_mrl(3'd4,mwl_mrl_value,tgt_addr,1'b0,8'd0);
  end
endtask // send_ccc_direct_set_mwl

task send_ccc_direct_set_mrl;
  input  [6:0]    tgt_addr;
  input  [15:0]   mwl_mrl_value;
  begin
    send_ccc_mwl_mrl(3'd5,mwl_mrl_value,tgt_addr,1'b0,8'd0);
  end
endtask // send_ccc_direct_set_mrl

task send_ccc_direct_set_mrl_ibi;
  input  [6:0]    tgt_addr;
  input  [15:0]   mwl_mrl_value;
  input  [7:0]    ibi_mps;
  begin
    send_ccc_mwl_mrl(3'd5,mwl_mrl_value,tgt_addr,1'b1,ibi_mps);
  end
endtask // send_ccc_direct_set_mrl_ibi

task send_ccc_direct_get_mwl;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_mwl_mrl(3'd6,16'd0,tgt_addr,1'b0,8'd0);
  end
endtask // send_ccc_direct_get_mwl

task send_ccc_direct_get_mrl;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_mwl_mrl(3'd7,16'd0,tgt_addr,1'b0,8'd0);
  end
endtask // send_ccc_direct_get_mrl

task send_ccc_direct_get_mrl_ibi;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_mwl_mrl(3'd7,16'd0,tgt_addr,1'b1,8'd0);
  end
endtask // send_ccc_direct_get_mrl_ibi

task send_ccc_broadcast_set_aasa;
  begin
    $display("%12d: ==== SEND BROADCAST SET AASA", $stime);
    `MST_BFM_MEMW(8'h30, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
    `MST_BFM_MEMW(8'h30, 8'h29)  // CCC Code - SET AASA CCC
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_ccc_broadcast_set_aasa

task send_ccc_set_da_generic;
  input           dasa0_newda1;
  input  [6:0]    tgt_old_addr;
  input  [6:0]    tgt_new_addr;
  input  [1:0]    multiple_tgt; // [1] - first target, [0] - multiple target follows

  reg    [7:0]    ccc_code;
  begin
    if(dasa0_newda1) begin // new DA
      $display("%12d: ==== SEND DIRECT SET NEWDA", $stime);
      ccc_code = 8'h88;
    end
    else begin // DASA
      $display("%12d: ==== SEND DIRECT SET DASA", $stime);
      ccc_code = 8'h87;
    end

    if(multiple_tgt[1]) begin // first target
      `MST_BFM_MEMW(8'h30, 8'h09)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 0 -> not repeated start
                                   // [2] = 0 -> Stop
                                   // [3] = 1 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
      `MST_BFM_MEMW(8'h30, ccc_code)  // CCC Code
    end

    `MST_BFM_MEMW(8'h30, {5'd0,~multiple_tgt[0],2'd3})  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {tgt_old_addr,1'b0})  // {7b target current address, W}
    `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
    `MST_BFM_MEMW(8'h30, {tgt_new_addr,1'b0})  // {7b target new address, 1'b0}

    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_ccc_set_da_generic

task send_ccc_set_dasa_1tgt;
  input  [6:0]    tgt_sa;
  input  [6:0]    tgt_da;
  begin
    send_ccc_set_da_generic(1'b0,tgt_sa,tgt_da,2'd2);
  end
endtask // send_ccc_set_dasa_1tgt

task send_ccc_set_dasa_mult_tgt;
  input  [6:0]    tgt_sa;
  input  [6:0]    tgt_da;
  input           first_tgt;
  begin
    send_ccc_set_da_generic(1'b0,tgt_sa,tgt_da,{first_tgt,1'b1});
  end
endtask // send_ccc_set_dasa_mult_tgt

task send_ccc_set_newda_1tgt;
  input  [6:0]    tgt_old_da;
  input  [6:0]    tgt_new_da;
  begin
    send_ccc_set_da_generic(1'b1,tgt_old_da,tgt_new_da,2'd2);
  end
endtask // send_ccc_set_newda_1tgt

task send_ccc_set_newda_mult_tgt;
  input  [6:0]    tgt_old_da;
  input  [6:0]    tgt_new_da;
  input           first_tgt;
  begin
    send_ccc_set_da_generic(1'b1,tgt_old_da,tgt_new_da,{first_tgt,1'b1});
  end
endtask // send_ccc_set_newda_mult_tgt

task send_ccc_get_gen;
  input  [7:0]    ccc_code;
  input           with_def_byte;
  input  [7:0]    def_byte;
  input  [6:0]    tgt_addr;
  input  [1:0]    multiple_tgt; // [1] - first target, [0] - multiple target follows
  reg    [7:0]    length;
  begin

    case(ccc_code)
      8'h8D   : begin
        $display("%12d: ==== SEND DIRECT GET PID", $stime);
        length = 8'd6;
      end
      8'h8E   : begin
        $display("%12d: ==== SEND DIRECT GET BCR", $stime);
        length = 8'd1;
      end
      8'h8F   : begin
        $display("%12d: ==== SEND DIRECT GET DCR", $stime);
        length = 8'd1;
      end
      8'h90   : begin
        $display("%12d: ==== SEND DIRECT GET DEVICE STATUS", $stime);
        length = 8'd2;
      end
      8'h91   : begin
        $display("%12d: ==== SEND GET ACCEPT CONTROLLER ROLE", $stime);
        length = 8'd1;
      end
      default : begin
        $display("%12d: ==== SEND DIRECT GET xxx", $stime);
        length = 8'd1;
      end
    endcase


    if(multiple_tgt[1]) begin // first target
      `MST_BFM_MEMW(8'h30, 8'h09)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 0 -> not repeated start
                                   // [2] = 0 -> Stop
                                   // [3] = 1 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `MST_BFM_MEMW(8'h30, 8'h01+with_def_byte)  // Length = 0x1+(1 if with_def_byte)
      `MST_BFM_MEMW(8'h30, ccc_code)  // CCC Code
      if(with_def_byte) begin
        `MST_BFM_MEMW(8'h30, def_byte)  // defining byte
      end
    end

    `MST_BFM_MEMW(8'h30, {5'd0,~multiple_tgt[0],2'd3})  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {tgt_addr,1'b1})  // {7b target current address, R}
    `MST_BFM_MEMW(8'h30, length)  // Length
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_ccc_get_gen

task send_ccc_get_pid_1tgt;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_get_gen(8'h8D,1'b0,8'd0,tgt_addr,2'd2);
  end
endtask // send_ccc_get_pid_1tgt

task send_ccc_get_pid_mult_tgt;
  input  [6:0]    tgt_addr;
  input           first_tgt;
  begin
    send_ccc_get_gen(8'h8D,1'b0,8'd0,tgt_addr,{first_tgt,1'b1});
  end
endtask // send_ccc_get_pid_mult_tgt

task send_ccc_get_bcr_1tgt;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_get_gen(8'h8E,1'b0,8'd0,tgt_addr,2'd2);
  end
endtask // send_ccc_get_bcr_1tgt

task send_ccc_get_bcr_mult_tgt;
  input  [6:0]    tgt_addr;
  input           first_tgt;
  begin
    send_ccc_get_gen(8'h8E,1'b0,8'd0,tgt_addr,{first_tgt,1'b1});
  end
endtask // send_ccc_get_bcr_mult_tgt

task send_ccc_get_dcr_1tgt;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_get_gen(8'h8F,1'b0,8'd0,tgt_addr,2'd2);
  end
endtask // send_ccc_get_dcr_1tgt

task send_ccc_get_dcr_mult_tgt;
  input  [6:0]    tgt_addr;
  input           first_tgt;
  begin
    send_ccc_get_gen(8'h8F,1'b0,8'd0,tgt_addr,{first_tgt,1'b1});
  end
endtask // send_ccc_get_dcr_mult_tgt

task send_ccc_get_status_1tgt;
  input  [6:0]    tgt_addr;
  input           with_def_byte;
  input  [6:0]    def_byte;
  begin
    send_ccc_get_gen(8'h90,with_def_byte,def_byte,tgt_addr,2'd2);
  end
endtask // send_ccc_get_status_1tgt

task send_ccc_get_status_mult_tgt;
  input  [6:0]    tgt_addr;
  input           with_def_byte;
  input  [6:0]    def_byte;
  input           first_tgt;
  begin
    send_ccc_get_gen(8'h90,with_def_byte,def_byte,tgt_addr,{first_tgt,1'b1});
  end
endtask // send_ccc_get_status_mult_tgt

task send_ccc_rstact_gen;
  input  [1:0]    rstact_typ; // {broad0_direct1,set0_get1}
  input  [7:0]    def_byte;   // defining byte
  input  [6:0]    tgt_addr;
  input  [1:0]    fml;        // [1] - first target, [0] - last target

  reg    [7:0]    ccc_code;
  reg             wait_nextpkt;
  begin
    case(rstact_typ)
      2'b10   : begin // set
        $display("%12d: ==== SEND DIRECT SET RSTACT", $stime);
        ccc_code = 8'h9A;
      end
      2'b11   : begin // get
        $display("%12d: ==== SEND DIRECT GET RSTACT", $stime);
        ccc_code = 8'h9A;
      end
      default : begin // broadcast
        $display("%12d: ==== SEND BROADCAST RSTACT", $stime);
        ccc_code = 8'h2A;
      end
    endcase

    if(~rstact_typ[1] | fml[1]) begin
      `MST_BFM_MEMW(8'h30, 8'h09)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 0 -> not repeated start
                                   // [2] = 0 -> Stop
                                   // [3] = 1 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `MST_BFM_MEMW(8'h30, 8'h02)         // Length = 0x2
      `MST_BFM_MEMW(8'h30, ccc_code)      // CCC Code
      `MST_BFM_MEMW(8'h30, def_byte)      // defining byte
    end

    wait_nextpkt = 1'b0;//~fml[0];
    if(rstact_typ[1]) begin
      `MST_BFM_MEMW(8'h30, {2'd0,wait_nextpkt,2'd0,fml[0]/*~wait_nextpkt*/,2'd3})  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 1 -> repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 0 -> not CCC_start
                                   // [4] = 0 -> rsvd
                                   // [5] = wait_nextpkt
                                   // [7:6] = 0 -> rsvd
      if(rstact_typ[0]) begin // get
        `MST_BFM_MEMW(8'h30, {tgt_addr,1'b1})  // {7b target DA, R}
        `MST_BFM_MEMW(8'h30, 8'h01)         // Length = 0x1
      end
      else begin // set
        `MST_BFM_MEMW(8'h30, {tgt_addr,1'b0})  // {7b target DA, W}
        `MST_BFM_MEMW(8'h30, 8'h00)         // Length = 0x0
      end
    end

    if(~rstact_typ[1] | fml[0]) begin
      `MST_BFM_MEMW(8'h11, 8'h01)  // start
    end
  end
endtask // send_ccc_rstact_gen

task send_ccc_broadcast_rstact;
  input  [7:0]    def_byte;   // defining byte
  begin
    send_ccc_rstact_gen(2'd0,def_byte,7'h7E,2'd3);
  end
endtask // send_ccc_broadcast_rstact

task send_ccc_direct_set_rstact_1tgt;
  input  [7:0]    def_byte;   // defining byte
  input  [6:0]    tgt_addr;
  begin
    send_ccc_rstact_gen(2'd2,def_byte,tgt_addr,2'd3);
  end
endtask // send_ccc_direct_set_rstact_1tgt

task send_ccc_direct_set_rstact_mult_tgt;
  input  [7:0]    def_byte;   // defining byte
  input  [6:0]    tgt_addr;
  input  [1:0]    fml;
  begin
    send_ccc_rstact_gen(2'd2,def_byte,tgt_addr,fml);
  end
endtask // send_ccc_direct_set_rstact_mult_tgt

task send_ccc_direct_get_rstact_1tgt;
  input  [7:0]    def_byte;   // defining byte
  input  [6:0]    tgt_addr;
  begin
    send_ccc_rstact_gen(2'd3,def_byte,tgt_addr,2'd3);
  end
endtask // send_ccc_direct_get_rstact_1tgt

task send_ccc_direct_get_rstact_mult_tgt;
  input  [7:0]    def_byte;   // defining byte
  input  [6:0]    tgt_addr;
  input  [1:0]    fml;
  begin
    send_ccc_rstact_gen(2'd3,def_byte,tgt_addr,fml);
  end
endtask // send_ccc_direct_get_rstact_mult_tgt

task send_ccc_getacccr;
  input  [6:0]    tgt_addr;
  begin
    send_ccc_get_gen(8'h91,1'b0,8'd0,tgt_addr,2'd2);
  end
endtask // send_ccc_getacccr

task send_ccc_endxfer;
  input  [1:0]    endxfer_typ;     // {broad0_direct1,wr0_rd1}
  input  [6:0]    tgt_addr;
  input  [2:0]    endxfer_cfg;     // [2] - no_crc,  [1] - en_wr_term, [0] - en_wr_acknak
  input           confirm1_setget0;
  input  [1:0]    fml;             // [1] - first target, [0] - last target

  reg    [7:0]    ccc_code;
  reg    [7:0]    def_byte;
  reg    [7:0]    dat_byte;
  reg    [1:0]    length;
  begin
    def_byte = (confirm1_setget0)? 8'hAA : 8'hF7;
    dat_byte = (confirm1_setget0)? 8'hAA :
                                   {((endxfer_cfg[2])? 2'b11 : 2'b01)
                                   ,~endxfer_cfg[1]
                                   ,~endxfer_cfg[0]
                                   ,4'd0};
    length   = (endxfer_typ[1])? 2'd2 : 2'd3;
    case(endxfer_typ)
      2'b10   : begin
        $display("%12d: ==== SEND DIRECT ENDXFER (SET)", $stime);
        ccc_code = 8'h92;
      end
      2'b11   : begin
        $display("%12d: ==== SEND DIRECT ENDXFER (GET)", $stime);
        ccc_code = 8'h92;
      end
      default : begin
        $display("%12d: ==== SEND BROADCAST ENDXFER", $stime);
        ccc_code = 8'h12;
      end
    endcase
    if(~endxfer_typ[1] | fml[1]) begin // broadcast or first time sending direct
      `MST_BFM_MEMW(8'h30, 8'h09)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 0 -> not repeated start
                                   // [2] = 0 -> Stop
                                   // [3] = 1 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `MST_BFM_MEMW(8'h30, {6'd0,length})  // Length = 0x2+(1 if broadcast)
      `MST_BFM_MEMW(8'h30, ccc_code)  // CCC Code - ENDXFER
      `MST_BFM_MEMW(8'h30, def_byte)  // Defining Byte
      if(~endxfer_typ[1]) begin // broadcast
        `MST_BFM_MEMW(8'h30, dat_byte)  // data byte
      end
    end

    if(endxfer_typ[1]) begin // direct
      `MST_BFM_MEMW(8'h30, {5'd0,fml[0],2'd3})  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 1 -> repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 0 -> not CCC_start
                                   // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {tgt_addr,endxfer_typ[0]})  // {7b target DA, W or R}
      `MST_BFM_MEMW(8'h30, 8'h01)     // Length = 0x1
      if(~endxfer_typ[0]) begin // write
        `MST_BFM_MEMW(8'h30, dat_byte)  // data byte
      end
    end

    if(~endxfer_typ[1] | fml[0]) begin
      `MST_BFM_MEMW(8'h11, 8'h01)  // start
    end
  end
endtask // send_ccc_endxfer

task send_ccc_broadcast_endxfer;
  input  [2:0]    endxfer_cfg;     // [2] - no_crc,  [1] - en_wr_term, [0] - en_wr_acknak
  input           confirm1_setget0;
  begin
    send_ccc_endxfer(2'd0,7'h7E,endxfer_cfg,confirm1_setget0,2'd3);
  end
endtask // send_ccc_broadcast_endxfer

task send_ccc_direct_set_endxfer_1tgt;
  input  [6:0]    tgt_addr;
  input  [2:0]    endxfer_cfg;     // [2] - no_crc,  [1] - en_wr_term, [0] - en_wr_acknak
  input           confirm1_setget0;
  begin
    send_ccc_endxfer(2'd2,tgt_addr,endxfer_cfg,confirm1_setget0,2'd3);
  end
endtask // send_ccc_direct_set_endxfer_1tgt

task send_ccc_direct_get_endxfer_1tgt;
  input  [6:0]    tgt_addr;
  input  [2:0]    endxfer_cfg;     // [2] - no_crc,  [1] - en_wr_term, [0] - en_wr_acknak
  input           confirm1_setget0;
  begin
    send_ccc_endxfer(2'd3,tgt_addr,endxfer_cfg,confirm1_setget0,2'd3);
  end
endtask // send_ccc_direct_get_endxfer_1tgt

task send_ccc_direct_set_endxfer_mult_tgt;
  input  [6:0]    tgt_addr;
  input  [2:0]    endxfer_cfg;     // [2] - no_crc,  [1] - en_wr_term, [0] - en_wr_acknak
  input           confirm1_setget0;
  input  [1:0]    fml;
  begin
    send_ccc_endxfer(2'd2,tgt_addr,endxfer_cfg,confirm1_setget0,fml);
  end
endtask // send_ccc_direct_set_endxfer_mult_tgt

task send_ccc_direct_get_endxfer_mult_tgt;
  input  [6:0]    tgt_addr;
  input  [2:0]    endxfer_cfg;     // [2] - no_crc,  [1] - en_wr_term, [0] - en_wr_acknak
  input           confirm1_setget0;
  input  [1:0]    fml;
  begin
    send_ccc_endxfer(2'd3,tgt_addr,endxfer_cfg,confirm1_setget0,fml);
  end
endtask // send_ccc_direct_get_endxfer_mult_tgt

task send_hdr_end_ccc_mode;
  input           wait_nextpkt;

  reg    [7:0]    mem_addr;
  reg    [7:0]    control;
  integer         i;
  begin
    $display("%12d: ==== I3C HDR-DDR End of CCC mode", $stime);

    control[0]    = 1'b0;         // -> user command
    control[1]    = 1'b1;         // -> repeated start
    control[2]    = 1'b0;         // -> terminate frame with P
    control[3]    = 1'b0;         // -> not CCC_start
    control[4]    = 1'b0;         // -> I3C protocol
    control[5]    = wait_nextpkt; // -> wait for next packet
    control[6]    = 1'b0;         // -> rsvd
    control[7]    = 1'b1;         // -> HDR mode

    `MST_BFM_MEMW(8'h30, control)           // Control
    `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})      // {7b target address,W}
    `MST_BFM_MEMW(8'h30, 8'd3)              // length (number of bytes) of data payload + 1 byte command code
    `MST_BFM_MEMW(8'h30, 8'd0)              // {W, user command code}
    // dummy command code to end CCC
    `MST_BFM_MEMW(8'h30, 8'd0)              // write data
    `MST_BFM_MEMW(8'h30, 8'h1F)             // write data
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_hdr_end_ccc_mode

task send_hdr_write;
  input  [6:0]    tgt_addr;
  input  [7:0]    length;
  input  [7:0]    mem_start_addr;
  input           first_burst;
  input           last_burst;
  input           wait_nextpkt;
  input  [6:0]    cmd_code;

  reg    [7:0]    mem_addr;
  reg    [7:0]    control;
  integer         i;
  begin
    if(first_burst) begin
      $display("%12d: ==== I3C Enter HDR-DDR", $stime);
      `MST_BFM_MEMW(8'h30, 8'h09)   // Control
                                    // [0] = 1 -> CCC1_PRIV0
                                    // [1] = 0 -> not repeated start
                                    // [2] = 0 -> Stop
                                    // [3] = 1 -> CCC_start
                                    // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // {7E,W}
      `MST_BFM_MEMW(8'h30, 8'd1)    // length == 1
      `MST_BFM_MEMW(8'h30, 8'h20)   // CCC - HDR-DDR
    end

    $display("%12d: ==== I3C HDR-DDR Write", $stime);

    control[0]    = 1'b0;         // -> user command
    control[1]    = 1'b1;         // -> repeated start
    control[2]    = last_burst;   // -> terminate frame with P
    control[3]    = 1'b0;         // -> not CCC_start
    control[4]    = 1'b0;         // -> I3C protocol
    control[5]    = wait_nextpkt; // -> wait for next packet
    control[6]    = 1'b0;         // -> rsvd
    control[7]    = 1'b1;         // -> HDR mode

    `MST_BFM_MEMW(8'h30, control)           // Control
    `MST_BFM_MEMW(8'h30, {tgt_addr,1'b0})   // {7b target address,W}
    `MST_BFM_MEMW(8'h30, length+1)          // length (number of bytes) of data payload + 1 byte command code
    `MST_BFM_MEMW(8'h30, {1'b0, cmd_code})  // {W, user command code}
    for(i=0; i<length; i=i+1) begin
      mem_addr = mem_start_addr + i;
      `MST_BFM_MEMW(8'h30, wdata_mem[mem_addr])  // write data
    end
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_hdr_write

task send_hdr_read;
  input  [6:0]    tgt_addr;
  input  [7:0]    length;
  input           first_burst;
  input           last_burst;
  input           wait_nextpkt;
  input  [6:0]    cmd_code;

  reg    [7:0]    control;
  begin
    if(first_burst) begin
      $display("%12d: ==== I3C Enter HDR-DDR", $stime);
      `MST_BFM_MEMW(8'h30, 8'h09)   // Control
                                    // [0] = 1 -> CCC1_PRIV0
                                    // [1] = 0 -> not repeated start
                                    // [2] = 0 -> Stop
                                    // [3] = 1 -> CCC_start
                                    // [7:4] = 0 -> rsvd
      `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // {7E,W}
      `MST_BFM_MEMW(8'h30, 8'd1)    // length == 1
      `MST_BFM_MEMW(8'h30, 8'h20)   // CCC - HDR-DDR
    end

    $display("%12d: ==== I3C HDR-DDR Read (command code)", $stime);
    `MST_BFM_MEMW(8'h30, 8'h82)     // Control
                                    // [0] = 0 -> user command
                                    // [1] = 1 -> repeated start
                                    // [2] = 0 -> Stop
                                    // [3] = 0 -> CCC_start
                                    // [6:4] = 0 -> rsvd
                                    // [7] = 1 -> HDR mode
    `MST_BFM_MEMW(8'h30, {tgt_addr,1'b0})   // {7b target address,W}
    `MST_BFM_MEMW(8'h30, 8'd1)      // length = 1 byte command code
    `MST_BFM_MEMW(8'h30, {1'b1,cmd_code})   // {R, user command code}

    $display("%12d: ==== I3C HDR-DDR Read (get read data)", $stime);
    control[0]    = 1'b0;         // -> user command
    control[1]    = 1'b1;         // -> repeated start
    control[2]    = last_burst;   // -> terminate frame with P
    control[3]    = 1'b0;         // -> not CCC_start
    control[4]    = 1'b0;         // -> I3C protocol
    control[5]    = wait_nextpkt; // -> wait for next packet
    control[6]    = 1'b0;         // -> rsvd
    control[7]    = 1'b1;         // -> HDR mode

    `MST_BFM_MEMW(8'h30, control)           // Control
    `MST_BFM_MEMW(8'h30, {tgt_addr,1'b1})   // {7b target address,R}
    `MST_BFM_MEMW(8'h30, length)            // length (number of bytes) of read data
    `MST_BFM_MEMW(8'h11, 8'h01)  // start
  end
endtask // send_hdr_read

task isr_generic;
  reg [7:0]     int_status0;
  reg [7:0]     int_status1;
  reg [7:0]     int_status2;
  reg [7:0]     rdata;
  begin
    `MST_BFM_WTINT
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 0, int_status0)  // get int status
    $display("%12d: [DEBUG] int_status0 = %0h",$stime,int_status0);
    `MST_BFM_MEMR(8'h24, 8'h00, 0, int_status1)  // get int status
    $display("%12d: [DEBUG] int_status1 = %0h",$stime,int_status1);
    `MST_BFM_MEMR(8'h2C, 8'h00, 0, int_status2)  // get int status
    $display("%12d: [DEBUG] int_status2 = %0h",$stime,int_status2);
    if(int_status0) begin
      // clear interrupt status
      `MST_BFM_MEMW(8'h20, (int_status0 & 8'hFF)) // clear int status
    end
    if(int_status1) begin
      // clear interrupt status
      `MST_BFM_MEMW(8'h24, (int_status1 & 8'hFF)) // clear int status
    end
    if(int_status2) begin
      // clear interrupt status
      `MST_BFM_MEMW(8'h2C, (int_status2 & 8'hFF)) // clear int status
    end
    @(posedge clk_i);
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 1, int_status0)  // verify int status
    `MST_BFM_MEMR(8'h24, 8'h00, 1, int_status1)  // verify int status
    `MST_BFM_MEMR(8'h2C, 8'h00, 1, int_status2)  // verify int status
  end
endtask // isr_generic

task isr_priv_read;
  input [7:0]   rd_staddr;
  input [7:0]   length;
  input         ibi_rd;

  reg [7:0]     int_status0;
  reg [7:0]     int_status1;
  reg [7:0]     int_status2;
  reg [7:0]     rdata;
  reg           rd_cmd_done, rxfifo_not_empty, ddr_rd_cmd_done;
  reg [7:0]     rd_cnt;
  reg           isr_done;
  begin
    rd_cmd_done = 0;
    rd_cnt      = 0;
    isr_done    = 0;
    `MST_BFM_WTINT
    while(!isr_done) begin
      // read interrupt status
      `MST_BFM_MEMR(8'h20, 8'h00, 0, int_status0)  // get int status
      $display("%12d: [DEBUG] int_status0 = %0h",$stime,int_status0);
      `MST_BFM_MEMR(8'h24, 8'h00, 0, int_status1)  // get int status
      $display("%12d: [DEBUG] int_status1 = %0h",$stime,int_status1);
      `MST_BFM_MEMR(8'h2C, 8'h00, 0, int_status2)  // get int status
      $display("%12d: [DEBUG] int_status2 = %0h",$stime,int_status2);
      ddr_rd_cmd_done  = int_status2[0];
      rd_cmd_done      = (ibi_rd)? int_status1[2] : int_status0[0] | ddr_rd_cmd_done;
      rxfifo_not_empty = int_status0[1];
      if(rd_cmd_done && rxfifo_not_empty) begin
        for(rd_cnt=0; rd_cnt < length; rd_cnt=rd_cnt+1) begin
          // Read Rx FIFO content
          `MST_BFM_MEMR(8'h40, wdata_mem[rd_staddr+rd_cnt], 1, rdata)  // get read data
          if(rdata !== wdata_mem[rd_staddr+rd_cnt]) begin
            data_err_cnt = data_err_cnt + 1;
            test_error = 1;
          end
          else begin
            data_ok_cnt = data_ok_cnt + 1;
            $display("%12d: [MST_READ_OK] Obs = %0h, Exp = %0h",$stime,rdata,wdata_mem[rd_staddr+rd_cnt]);
          end
        end
        // check ddr parity error
        if(ddr_rd_cmd_done & int_status2[4]) begin
          $display("%12d: [ERROR] Parity Error detected during HDR-DDR Read!",$stime);
          csr_err_cnt = csr_err_cnt + 1;
          test_error = 1;
        end
        // check ddr CRC error
        if(ddr_rd_cmd_done & int_status2[3]) begin
          $display("%12d: [ERROR] CRC Error detected during HDR-DDR Read!",$stime);
          csr_err_cnt = csr_err_cnt + 1;
          test_error = 1;
        end
        if(int_status0) begin
          // clear interrupt status
          `MST_BFM_MEMW(8'h20, (int_status0 & 8'hFF)) // clear int status
        end
        if(int_status1) begin
          // clear interrupt status
          `MST_BFM_MEMW(8'h24, (int_status1 & 8'hFF)) // clear int status
        end
        if(int_status2) begin
          // clear interrupt status
          `MST_BFM_MEMW(8'h2C, (int_status2 & 8'hFF)) // clear int status
        end
        repeat(10) @(posedge clk_i);
        isr_done = 1;
      end
      else begin
        repeat(100) @(posedge clk_i);
      end
    end // isr_done
    if(rd_cnt < length) begin
      $display("%12d: [Warning] Missing read data! Expected(%0d) vs Observed(%0d)",
               $stime,length,rd_cnt);
    end
    @(posedge clk_i);
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 1, int_status0)  // verify int status
    `MST_BFM_MEMR(8'h24, 8'h00, 1, int_status1)  // verify int status
    `MST_BFM_MEMR(8'h2C, 8'h00, 1, int_status2)  // verify int status
  end
endtask // isr_priv_read

task isr_gen_read;
  input [7:0]   exp_rdata;
  input         last_read;

  reg [7:0]     int_status0;
  reg [7:0]     int_status1;
  reg [7:0]     int_status2;
  reg [7:0]     rdata;
  reg           isr_done, rxfifo_not_empty;
  begin
    isr_done = 0;
    `MST_BFM_WTINT
    while(!isr_done) begin
      // read interrupt status
      `MST_BFM_MEMR(8'h20, 8'h00, 0, int_status0)  // get int status
      $display("%12d: [DEBUG] int_status0 = %0h",$stime,int_status0);
      `MST_BFM_MEMR(8'h24, 8'h00, 0, int_status1)  // get int status
      $display("%12d: [DEBUG] int_status1 = %0h",$stime,int_status1);
      `MST_BFM_MEMR(8'h2C, 8'h00, 0, int_status2)  // get int status
      $display("%12d: [DEBUG] int_status2 = %0h",$stime,int_status2);
      rxfifo_not_empty = int_status0[1];
      if(rxfifo_not_empty) begin
        // Read Rx FIFO content
        `MST_BFM_MEMR(8'h40, exp_rdata, 1, rdata)  // get read data
        if(rdata !== exp_rdata) begin
          data_err_cnt = data_err_cnt + 1;
          test_error = 1;
        end
        else begin
          data_ok_cnt = data_ok_cnt + 1;
          $display("%12d: [MST_READ_OK] Obs = %0h, Exp = %0h",$stime,rdata,exp_rdata);
        end

        // clear interrupt status
        `MST_BFM_MEMW(8'h20, (int_status0 & 8'h02)) // clear int status
        repeat(10) @(posedge clk_i);
        isr_done = 1'b1;
      end
      else begin
        repeat(100) @(posedge clk_i);
      end
    end // isr_done
    @(posedge clk_i);
    // read interrupt status
    `MST_BFM_MEMR(8'h20, (int_status0 & 8'hFD), last_read, int_status0)  // verify int status
  end
endtask // isr_gen_read

task isr_hot_join;
  input         respond_nak;
  reg [7:0]     int_status0;
  reg [7:0]     rdata;
  begin
    `MST_BFM_WTINT
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 0, int_status0)  // get int status
    $display("%12d: [DEBUG] int_status0 = %0h",$stime,int_status0);
    if(int_status0[3]) begin // Hot Join detected
      // Check IBI address
      `MST_BFM_MEMR(8'h1F, {7'h02,1'b0}, 1, rdata)  // get read data and verify
      $display("%12d: [DEBUG] Hot Join Request Detected",$stime);
      if(rdata[7:1] !== 7'h02) begin
        test_error = 1;
        csr_err_cnt = csr_err_cnt + 1;
        $display("%12d: [ERROR] Received IBI Address (%0h) is not equal to expected Hot Join address (7'h02)!",
                 $stime,rdata[7:1]);
      end

      // clear interrupt status
      `MST_BFM_MEMW(8'h20, (int_status0 & 8'h08)) // clear int status

      // respond to Hot Join
      `MST_BFM_MEMW(8'h1E, {7'd0,respond_nak}) // ACK the Hot Join
    end
    @(posedge clk_i);
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 1, int_status0)  // verify int status
  end
endtask // isr_hot_join

task isr_ibi_req;
  input [6:0]   exp_tgt_addr;
  input         respond_nak;
  input [7:0]   ibi_rd_cnt;
  input [7:0]   rd_staddr;

  reg   [7:0]   int_status0;
  reg   [7:0]   rdata;
  begin
    `MST_BFM_WTINT
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 0, int_status0)  // get int status
    $display("%12d: [DEBUG] int_status0 = %0h",$stime,int_status0);
    if(int_status0[4]) begin // IBI detected
      // Check IBI address
      `MST_BFM_MEMR(8'h1F, 8'd0, 0, rdata)  // get address of requestor
      $display("%12d: [DEBUG] IBI Request Generated by Target Address : %0h",$stime,rdata[7:1]);
      if(rdata[7:1] !== exp_tgt_addr) begin
        test_error = 1;
        csr_err_cnt = csr_err_cnt + 1;
        $display("%12d: [ERROR] Received IBI Address (%0h) is not equal to expected Target address (%0h)!",
                 $stime,rdata[7:1],exp_tgt_addr);
      end

      // clear interrupt status
      `MST_BFM_MEMW(8'h20, int_status0) // clear int status

      if(~respond_nak) begin
        `MST_BFM_MEMW(8'h1D, ibi_rd_cnt) // IBI read count
      end
      // respond to IBI request
      `MST_BFM_MEMW(8'h1E, {7'd0,respond_nak})
    end
    @(posedge clk_i);
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 1, int_status0)  // verify int status

    // get IBI payload
    if(~respond_nak & |ibi_rd_cnt) begin
      isr_priv_read(rd_staddr,ibi_rd_cnt,1'b1);
    end
  end
endtask // isr_ibi_req

task isr_sec_ibi;
  input [6:0]   exp_tgt_addr;
  input         respond_nak;

  reg   [7:0]   int_status0;
  reg   [7:0]   rdata;
  begin
    `MST_BFM_WTINT
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 0, int_status0)  // get int status
    $display("%12d: [DEBUG] int_status0 = %0h",$stime,int_status0);
    if(int_status0[5]) begin // Secondary Controller IBI detected
      // Check IBI address
      `MST_BFM_MEMR(8'h1F, 8'd0, 0, rdata)  // get address of requestor
      $display("%12d: [DEBUG] IBI Request Generated by Secondary Controller Address : %0h",$stime,rdata[7:1]);
      if(rdata[7:1] !== exp_tgt_addr) begin
        test_error = 1;
        csr_err_cnt = csr_err_cnt + 1;
        $display("%12d: [ERROR] Received IBI Address (%0h) is not equal to expected Secondary Controller address (%0h)!",
                 $stime,rdata[7:1],exp_tgt_addr);
      end

      // clear interrupt status
      `MST_BFM_MEMW(8'h20, int_status0) // clear int status

      // respond to IBI request
      `MST_BFM_MEMW(8'h1E, {7'd0,respond_nak})
    end
    @(posedge clk_i);
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 1, int_status0)  // verify int status
  end
endtask // isr_sec_ibi

task isr_getacccr;
  input         exp_result;
  input         exp_role;

  reg   [7:0]   int_status0;
  reg   [7:0]   int_status1;
  reg   [7:0]   rdata;
  reg   [8*4:0] msg_stat;
  reg           isr_done;
  begin
    `MST_BFM_WTINT
    isr_done = 1'b0;
    while(!isr_done) begin
      // read interrupt status
      `MST_BFM_MEMR(8'h20, 8'h00, 0, int_status0)  // get int status
      $display("%12d: [DEBUG] int_status0 = %0h",$stime,int_status0);
      `MST_BFM_MEMR(8'h24, 8'h00, 0, int_status1)  // get int status
      $display("%12d: [DEBUG] int_status1 = %0h",$stime,int_status1);
      if(int_status1[3]) begin // Done GETACCCR detected
        // Check Secondary Controller Status Info
        `MST_BFM_MEMR(8'h15, 8'd0, 0, rdata)  // get status
        msg_stat = (rdata[2])? "FAIL" : "DONE";
        $display("%12d: [DEBUG] Done GETACCCR detected.",$stime);
        $display("%12d: [DEBUG] \tsc_stat_info:Active Controller: %0b",$stime,rdata[0]);
        $display("%12d: [DEBUG] \tsc_stat_info:GETACCCR Started : %0b",$stime,rdata[1]);
        $display("%12d: [DEBUG] \tsc_stat_info:GETACCCR Result  : %0b (%0s)",$stime,rdata[2],msg_stat);
        if(rdata[0] !== exp_role) begin
          test_error = 1;
          csr_err_cnt = csr_err_cnt + 1;
          $display("%12d: [ERROR] sc_stat_info:Active Controller (%0b) is not equal to expected role (%0b)!",
                   $stime,rdata[0],exp_role);
        end
        if(rdata[2] !== exp_result) begin
          test_error = 1;
          csr_err_cnt = csr_err_cnt + 1;
          $display("%12d: [ERROR] sc_stat_info:GETACCCR Result (%0b) is not equal to expected (%0b)!",
                   $stime,rdata[2],exp_result);
        end

        // clear interrupt status
        `MST_BFM_MEMW(8'h20, int_status0) // clear int status
        `MST_BFM_MEMW(8'h24, int_status1) // clear int status
        isr_done = 1'b1;
      end
      else begin
        $display("%12d: [DEBUG] Waiting for GETACCCR Done...",$stime);
        repeat(50) @(posedge clk_i);
      end
    end // isr_done
    @(posedge clk_i);
    // read interrupt status
    `MST_BFM_MEMR(8'h20, 8'h00, 1, int_status0)  // verify int status
    `MST_BFM_MEMR(8'h24, 8'h00, 1, int_status1)  // verify int status
  end
endtask // isr_getacccr

// ==========================================================================
// I3C Target API Tasks
// ==========================================================================

task initialize_i3c_target;
  input [1:0] tgt_sel;
  reg         tgt_loopbk_en;
  begin
    tgt_loopbk_en = (tgt_sel == 2'd1)? TGT_LOOPBK_EN1 : TGT_LOOPBK_EN0;
    $display("%12d: ==== I3C TARGET INITIALIZATION", $stime);
    `TGT_BFM_MEMW(tgt_sel,8'h17, tgt_addr_static)  // static address
    `TGT_BFM_MEMW(tgt_sel,8'h06, 8'h02)  // Hot Join/ IBI number of retry
    `TGT_BFM_MEMW(tgt_sel,8'h29, {3'd0,tgt_loopbk_en,4'd1})  // loopback enable, respond with NAK when reading empty Tx FIFO
    `TGT_BFM_MEMW(tgt_sel,8'h30, 8'hEF)  // Hot Join/ IBI interrupt enable
    `TGT_BFM_MEMW(tgt_sel,8'h34, 8'h0F)  // SDR interrupt enable
    `TGT_BFM_MEMW(tgt_sel,8'h39, 8'h03)  // FIFO interrupt enable
    `TGT_BFM_MEMW(tgt_sel,8'h43, 8'h00)  // Controller Handoff response ([7]==0 - ACK)
  end
endtask // initialize_i3c_target

task tgt_send_hot_join_req;
  input [1:0] tgt_sel;
  begin
    $display("%12d: ==== (TGT) SEND HOT JOIN REQUEST", $stime);
    `TGT_BFM_MEMW(tgt_sel,8'h05, 8'h08) // events command request register
  end
endtask // tgt_send_hot_join_req

task tgt_send_sec_ibi_req;
  input [1:0] tgt_sel;
  begin
    $display("%12d: ==== (TGT) SEND SECONDARY CONTROLLER IBI REQUEST", $stime);
    `TGT_BFM_MEMW(tgt_sel,8'h05, 8'h02) // events command request register
  end
endtask // tgt_send_sec_ibi_req

task tgt_write_ibi_payload;
  input [1:0] tgt_sel;
  input [7:0] ibi_data;
  begin
    $display("%12d: ==== (TGT) Write IBI Payload to Tx FIFO", $stime);
    `TGT_BFM_MEMW(tgt_sel,8'h22, ibi_data) // write IBI payload to Tx FIFO
  end
endtask // tgt_write_ibi_payload

task tgt_send_ibi_req;
  input [1:0] tgt_sel;
  begin
    $display("%12d: ==== (TGT) SEND IBI REQUEST", $stime);
    `TGT_BFM_MEMW(tgt_sel,8'h05, 8'h01) // events command request register
  end
endtask // tgt_send_ibi_req

task tgt_write_tx_fifo;
  input [1:0]   tgt_sel;
  input [7:0]   wdata;
  begin
    $display("%12d: ==== (TGT %0d) TX FIFO WRITE", $stime,tgt_sel);
    `TGT_BFM_MEMW(tgt_sel,8'h22, wdata) // write payload to Tx FIFO
  end
endtask // tgt_write_tx_fifo

task tgt_read_rx_fifo;
  input   [1:0]   tgt_sel;
  input           verify_rd;
  input   [7:0]   exp_data;
  output  [7:0]   rdata;
  begin
    $display("%12d: ==== (TGT %0d) RX FIFO READ", $stime,tgt_sel);
    `TGT_BFM_MEMR(tgt_sel,8'h20, exp_data, verify_rd, rdata)  // read target rx fifo
    if(verify_rd) begin
      if(rdata !== exp_data) begin
        data_err_cnt = data_err_cnt + 1;
        test_error   = 1;
      end
      else begin
        data_ok_cnt = data_ok_cnt + 1;
        $display("%12d: [TGT_READ_OK] Obs = %0h, Exp = %0h",$stime,rdata,exp_data);
      end
    end
  end
endtask // tgt_read_rx_fifo

task tgt_check_assigned_da;
  input [1:0]   tgt_sel;
  input         exp_tgt_daa_done;
  input [6:0]   exp_tgt_da;

  reg           obs_tgt_daa_done;
  reg   [6:0]   obs_tgt_da;
  begin
    `TGT_BFM_MEMR(tgt_sel,8'h02, 8'h00, 0, {obs_tgt_daa_done,obs_tgt_da})  // read target DA register
    if(exp_tgt_daa_done !== obs_tgt_daa_done) begin
      test_error = 1;
      daa_err_cnt = daa_err_cnt + 1;
      if(obs_tgt_daa_done) begin
        $display("%12d: [ERROR] Unable to reset the Dynamic Address of Target %0d!",$stime,tgt_sel);
      end
      else begin
        $display("%12d: [ERROR] Failed Dynamic Address Assignment!",$stime);
      end
    end

    if(exp_tgt_daa_done) begin
      if(exp_tgt_da !== obs_tgt_da) begin
        test_error = 1;
        daa_err_cnt = daa_err_cnt + 1;
        $display("%12d: [ERROR] Dynamic Address of Target %0d is not equal to expected! exp=%0h vs obs=%0h",
                 $stime,tgt_sel,exp_tgt_da,obs_tgt_da);
      end
      else begin
        $display("%12d: [DEBUG] Successful Dynamic Address Assignment of Target %0d : DA = %0h",
                 $stime,tgt_sel,obs_tgt_da);
      end
    end
  end
endtask // tgt_check_assigned_da

task tgt_check_entasx;
  input [1:0]   tgt_sel;
  input [1:0]   exp_state;

  reg   [7:0]   rdata;
  begin
    `TGT_BFM_MEMR(tgt_sel,8'h2C, 8'h00, 0, rdata)  // read bus activity state register
    if(rdata[1:0] !== exp_state) begin
      test_error = 1;
      csr_err_cnt = csr_err_cnt + 1;
      $display("%12d: [ERROR] Target %0d bus activity state register (%0d) is not equal to expected (%0d)!",
               $stime,tgt_sel,rdata[1:0],exp_state);
    end
  end
endtask // tgt_check_entasx

task tgt_check_rstact;
  input [1:0]   tgt_sel;
  input [7:0]   exp_data;

  reg   [7:0]   rdata;
  begin
    `TGT_BFM_MEMR(tgt_sel,8'h36, 8'h00, 0, rdata)  // read status 3 register
    if(~rdata[5]) begin
      test_error = 1;
      csr_err_cnt = csr_err_cnt + 1;
      $display("%12d: [ERROR] Target %0d rstacc ccc received status register (%0d) is not asserted!",
               $stime,tgt_sel,rdata[5]);
    end
    `TGT_BFM_MEMR(tgt_sel,8'h2D, 8'h00, 0, rdata)  // read reset action register
    if(rdata !== exp_data) begin
      test_error = 1;
      csr_err_cnt = csr_err_cnt + 1;
      $display("%12d: [ERROR] Target %0d reset action register (%0d) is not equal to expected (%0d)!",
               $stime,tgt_sel,rdata,exp_data);
    end
  end
endtask // tgt_check_rstact

task tgt_isr_priv_write;
  input   [1:0] tgt_sel;
  input   [7:0] rd_staddr;
  input   [7:0] length;

  reg     [7:0] rdata;
  reg     [7:0] rd_cnt;
  reg           wr_done;
  begin
    wr_done = 1;
    if(wr_done) begin
      for(rd_cnt=0; rd_cnt<length; rd_cnt=rd_cnt+1) begin
        tgt_read_rx_fifo(tgt_sel,1,wdata_mem[rd_staddr+rd_cnt],rdata);
      end
    end
    else begin
      `TGT_BFM_WTINT(tgt_sel)
    end
  end
endtask // tgt_isr_priv_write

// ==========================================================================
// Sample Tests
// ==========================================================================

task sample_test_rstact;
  input [1:0] tgt_sel;
  reg [7:0] rdata, int_status, rd_cnt;
  reg       rd_cmd_done;

  reg [6:0] tgt_addr;
  reg [7:0] length;
  reg [7:0] mem_staddr;
  reg [8:0] total_wcnt;
  reg [7:0] wr_staddr;
  reg [7:0] rd_staddr;
  begin

    rdata       = 8'd0;
    int_status  = 8'd0;
    rd_cmd_done = 0;
    rd_cnt      = 0;

    total_wcnt  = 9'd0;
    length      = 8'd0;
    mem_staddr  = $random;

    // reset dynamic address
    send_ccc_rstdaa;
    wait_trans_then_idle(2);

    tgt_addr    = 7'h14;
    // send_enter_daa_ccc_1tgt(tgt_addr);
    send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
    send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
    send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
    tgt_check_assigned_da(0,1'd1,tgt_addr+1);
    tgt_check_assigned_da(1,1'd1,tgt_addr+2);
    isr_generic;
    wait_idle(100);

    // Start Test
    send_ccc_broadcast_rstact(8'd0); // no reset on target reset pattern
    wait_trans_then_idle(8);
    tgt_check_rstact(tgt_sel,8'd0);

    send_ccc_broadcast_rstact(8'd1); // reset the I3C peripheral only
    wait_trans_then_idle(8);
    tgt_check_rstact(tgt_sel,8'd1);

    send_ccc_broadcast_rstact(8'd2); // reset the whole target
    wait_trans_then_idle(8);
    tgt_check_rstact(tgt_sel,8'd2);

    send_ccc_direct_set_rstact_1tgt(8'd1,tgt_addr);
    wait_trans_then_idle(8);
    send_ccc_direct_get_rstact_1tgt(8'd2,tgt_addr);
    wait_trans_then_idle(8);
    tgt_check_rstact(tgt_sel,8'd2); // exp rstact=2 in status register
    data_exp_cnt = data_exp_cnt + 1;
    isr_gen_read(8'd1,1'b1); // exp rstact=1 in get ccc

    send_ccc_direct_set_rstact_mult_tgt(8'd1,tgt_addr+3,2'd2);
    send_ccc_direct_set_rstact_mult_tgt(8'd1,tgt_addr+2,2'd0);
    send_ccc_direct_set_rstact_mult_tgt(8'd1,tgt_addr+1,2'd0);
    send_ccc_direct_set_rstact_mult_tgt(8'd1,tgt_addr+0,2'd0);
    send_ccc_direct_set_rstact_mult_tgt(8'd1,tgt_addr+1,2'd0);
    send_ccc_direct_set_rstact_mult_tgt(8'd1,tgt_addr+2,2'd0);
    send_ccc_direct_set_rstact_mult_tgt(8'd1,tgt_addr+0,2'd0);
    send_ccc_direct_set_rstact_mult_tgt(8'd1,tgt_addr+4,2'd1);
    wait_trans_then_idle(8);

    wait_idle(8);
  end
endtask // sample_test_rstact

task sample_test_hot_join;
  input [1:0] tgt_sel;
  reg [7:0]  tgt_addr;
  begin
    if(ENABLE_HJI) begin
      tgt_send_hot_join_req(tgt_sel);

      send_ccc_rstdaa;
      wait_trans_then_idle(8);
      isr_generic;

      @(negedge sda_io);
      @(negedge scl_io);
      wait_idle(1);
      // wait SDA in high for some time
      idle_line_sel = 2'b01;
      wait_idle(20);
      idle_line_sel = 2'b11;

      isr_hot_join(1'b1); // NAK response

      @(negedge sda_io);
      @(negedge scl_io);
      wait_idle(1);
      // wait SDA in high for some time
      idle_line_sel = 2'b01;
      wait_idle(20);
      idle_line_sel = 2'b11;

      isr_hot_join(1'b0); // ACK response

      wait_idle(8);
      // assign Target DA using Enter DAA
      tgt_addr = 7'h22;
      // send_enter_daa_ccc_1tgt(tgt_addr);
      send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
      send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
      send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
      wait_trans_then_idle(8);
      tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
      tgt_check_assigned_da(0,1'd1,tgt_addr+1);
      tgt_check_assigned_da(1,1'd1,tgt_addr+2);
    end
    else begin
      $display("%12d: [SKIP TEST] Hot Join Feature is not enabled!",$stime);
    end
  end
endtask // sample_test_hot_join

task sample_test_ibi;
  input [1:0] tgt_sel;
  reg [7:0]  tgt_addr;
  reg [7:0] length;
  reg [7:0] mem_staddr;
  reg [8:0] total_wcnt;
  reg [7:0] wr_staddr;
  reg [7:0] rdata;
  reg [7:0] config0;
  reg [7:0] ibi_pld_staddr;
  reg [7:0] ibi_pld_cnt;
  reg [7:0] ibi_mdb;
  integer   i;
  begin
    total_wcnt  = 9'd0;
    length      = 8'd0;
    mem_staddr  = $random;

    if(ENABLE_IBI) begin
      // -----------------------------
      // Disable IBI auto response
      `MST_BFM_MEMR(8'h02, 8'h00, 0, config0)  // read config register
      `MST_BFM_MEMW(8'h02, (config0 & 8'hDF))  // disable IBI auto response

      send_ccc_rstdaa;
      wait_trans_then_idle(2);
      // assign Target DA using Enter DAA
      tgt_addr = 7'h22;
      send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
      send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
      send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
      wait_trans_then_idle(8);
      tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
      tgt_check_assigned_da(0,1'd1,tgt_addr+1);
      tgt_check_assigned_da(1,1'd1,tgt_addr+2);
      isr_generic;
      wait_idle(8);

      // Disable all interrupt other than IBI
      `MST_BFM_MEMW(8'h22, 8'h10)  // interrupt enable 0 (rcvd_ibi)
      `MST_BFM_MEMW(8'h26, 8'h04)  // interrupt enable 1 (ibi_rdone)

      // Use Target 0 configured with IBI capability but no payload
      tgt_send_ibi_req(0); // no payload
      @(negedge sda_io); // wait start of IBI
      @(negedge scl_io); // wait start of IBI

      ibi_pld_staddr = $random;
      ibi_pld_cnt    = 8'd0;
      isr_ibi_req(tgt_addr+1,IBI_ACK_RESP,ibi_pld_cnt,ibi_pld_staddr);

      wait_idle(8);

      wr_staddr   = mem_staddr;
      length      = 8'd4;

      total_wcnt  = total_wcnt + length;
      send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                         CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
      data_exp_cnt = data_exp_cnt + length;

      wr_staddr   = mem_staddr + total_wcnt;
      length      = 8'd8;

      total_wcnt  = total_wcnt + length;
      send_private_write(tgt_addr,length,wr_staddr,REP_START,
                         CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
      data_exp_cnt = data_exp_cnt + length;

      ibi_pld_staddr = $random;
      ibi_pld_cnt    = 8'd4;
      ibi_mdb        = wdata_mem[ibi_pld_staddr];
      ibi_mdb        = (ibi_mdb[7:5] == 3'd4)?  {3'd3,ibi_mdb[4:0]} : ibi_mdb;
      wdata_mem[ibi_pld_staddr] = ibi_mdb;
      for(i=0; i<ibi_pld_cnt; i=i+1) begin
        tgt_write_ibi_payload(tgt_sel,wdata_mem[ibi_pld_staddr+i]);
      end
      data_exp_cnt = data_exp_cnt + ibi_pld_cnt;

      tgt_send_ibi_req(tgt_sel);
      isr_ibi_req(tgt_addr,IBI_NAK_RESP,ibi_pld_cnt,ibi_pld_staddr);
      isr_ibi_req(tgt_addr,IBI_ACK_RESP,ibi_pld_cnt,ibi_pld_staddr);

      tgt_isr_priv_write(tgt_sel,mem_staddr,total_wcnt);

      // -----------------------------
      total_wcnt  = 9'd0;
      length      = 8'd0;
      mem_staddr  = $random;
      // Enable IBI auto response
      `MST_BFM_MEMR(8'h02, 8'h00, 0, config0)  // read config register
      `MST_BFM_MEMW(8'h02, (config0 | 8'h20))  // enable IBI auto response

      ibi_pld_staddr = $random;
      ibi_pld_cnt    = 8'd5;
      ibi_mdb        = wdata_mem[ibi_pld_staddr];
      ibi_mdb        = (ibi_mdb[7:5] == 3'd4)?  {3'd3,ibi_mdb[4:0]} : ibi_mdb;
      wdata_mem[ibi_pld_staddr] = ibi_mdb;
      for(i=0; i<ibi_pld_cnt; i=i+1) begin
        tgt_write_ibi_payload(tgt_sel,wdata_mem[ibi_pld_staddr+i]);
      end
      data_exp_cnt = data_exp_cnt + ibi_pld_cnt;

      tgt_send_ibi_req(tgt_sel);
      @(negedge sda_io); // wait start of IBI
      @(negedge scl_io); // wait start of IBI

      wr_staddr   = mem_staddr;
      length      = 8'd5;

      total_wcnt  = total_wcnt + length;
      send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                         CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
      data_exp_cnt = data_exp_cnt + length;

      wr_staddr   = mem_staddr + total_wcnt;
      length      = 8'd14;

      total_wcnt  = total_wcnt + length;
      send_private_write(tgt_addr,length,wr_staddr,REP_START,
                         CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
      data_exp_cnt = data_exp_cnt + length;

      wait_idle(1);
      // wait SDA in high for some time
      idle_line_sel = 2'b01;
      wait_idle(20);
      idle_line_sel = 2'b11;

      isr_ibi_req(tgt_addr,IBI_ACK_RESP,ibi_pld_cnt,ibi_pld_staddr);
      tgt_isr_priv_write(tgt_sel,mem_staddr,total_wcnt);

      wait_idle(8);
      // Enable all interrupt
      `MST_BFM_MEMW(8'h22, 8'hFF)  // interrupt enable 0 (rcvd_ibi)
      `MST_BFM_MEMW(8'h26, 8'hFF)  // interrupt enable 1 (ibi_rdone)
    end
    else begin
      $display("%12d: [SKIP TEST] In-band Interrupt Feature is not enabled!",$stime);
    end
  end
endtask // sample_test_ibi

task sample_test_daa;
  input [1:0] tgt_sel;
  reg [7:0]  rdata;
  reg [7:0]  tgt_addr;
  begin
    send_ccc_rstdaa;
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd0,7'd0);

    // assign Target SA as DA
    send_ccc_broadcast_set_aasa;
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr_static);

    // assign Target DA through SA
    tgt_addr = 7'h15;
    send_ccc_rstdaa;
    wait_trans_then_idle(2);
    send_ccc_set_dasa_1tgt(tgt_addr_static,tgt_addr);
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);

    // assign New Target DA - exp fail
    send_ccc_set_newda_1tgt(7'h28,tgt_addr);
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr); // expect to retain previous DA

    // assign New Target DA - exp good
    send_ccc_set_newda_1tgt(tgt_addr,7'h28);
    wait_trans_then_idle(8);
    tgt_addr = 7'h28; // expected new DA
    tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);

    send_ccc_rstdaa;
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd0,7'd0);

    // assign Target DA using Enter DAA
    tgt_addr = 7'h31;
    // send_enter_daa_ccc_1tgt(tgt_addr);
    send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
    send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
    send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
    tgt_check_assigned_da(0,1'd1,tgt_addr+1);
    tgt_check_assigned_da(1,1'd1,tgt_addr+2);

    send_ccc_direct_entasx_1tgt(2'd0,tgt_addr);
    wait_trans_then_idle(4);
    tgt_check_entasx(tgt_sel,2'd0);

    send_ccc_direct_entasx_1tgt(2'd1,tgt_addr);
    wait_trans_then_idle(4);
    tgt_check_entasx(tgt_sel,2'd1);

    send_ccc_direct_entasx_1tgt(2'd2,tgt_addr);
    wait_trans_then_idle(4);
    tgt_check_entasx(tgt_sel,2'd2);

    send_ccc_direct_entasx_1tgt(2'd3,tgt_addr);
    wait_trans_then_idle(4);
    tgt_check_entasx(tgt_sel,2'd3);

    send_ccc_direct_entasx_multi_tgt(2'd1,tgt_addr+1,2'd2);
    send_ccc_direct_entasx_multi_tgt(2'd0,tgt_addr+0,2'd0);
    send_ccc_direct_entasx_multi_tgt(2'd0,tgt_addr+2,2'd0);
    send_ccc_direct_entasx_multi_tgt(2'd0,tgt_addr+0,2'd0);
    send_ccc_direct_entasx_multi_tgt(2'd0,tgt_addr+3,2'd0);
    send_ccc_direct_entasx_multi_tgt(2'd0,tgt_addr+0,2'd0);
    send_ccc_direct_entasx_multi_tgt(2'd0,tgt_addr+4,2'd0);
    send_ccc_direct_entasx_multi_tgt(2'd0,tgt_addr+0,2'd1);
    wait_trans_then_idle(16);
    tgt_check_entasx(tgt_sel,2'd1);

    wait_idle(16);
  end
endtask // sample_test_daa

task sample_test_0;
  input [1:0] tgt_sel;
  reg [7:0] rdata, int_status, rd_cnt;
  reg       rd_cmd_done;

  reg [6:0] tgt_addr;
  reg [7:0] length;
  reg [7:0] mem_staddr;
  reg [8:0] total_wcnt;
  reg [7:0] wr_staddr;
  reg [7:0] rd_staddr;
  reg [7:0] i2c_clk_div;
  integer   i;
  begin
    rdata       = 8'd0;
    int_status  = 8'd0;
    rd_cmd_done = 0;
    rd_cnt      = 0;

    total_wcnt  = 9'd0;
    length      = 8'd0;
    mem_staddr  = 8'd0;

    // reset dynamic address
    send_ccc_rstdaa;
    wait_trans_then_idle(2);

    tgt_addr    = 7'h37;
    // send_enter_daa_ccc_1tgt(tgt_addr);
    send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
    send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
    send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
    tgt_check_assigned_da(0,1'd1,tgt_addr+1);
    tgt_check_assigned_da(1,1'd1,tgt_addr+2);
    isr_generic;
    wait_idle(100);

    // Start Test
    // -----------------------------------------
    wr_staddr   = mem_staddr;
    length      = 8'd4;

    // Fill target fifo with expected data
    for(i=0; i<length; i=i+1) begin
      tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
    end

    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                       END_OF_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + length;
    repeat(100) @(posedge clk_i);

    rd_staddr   = wr_staddr;
    length      = 8'd4;
    send_private_read(tgt_addr,length,START_OF_FRAME,
                      END_OF_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

    // -----------------------------------------
    wait_trans_then_idle(16);

    // -----------------------------------------
    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd8;

    // Fill target fifo with expected data
    for(i=0; i<length; i=i+1) begin
      tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
    end

    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + length;

    length      = 8'd8;
    send_private_read(tgt_addr,length,REP_START,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

    // -----------------------------------------
    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd16;

    // Fill target fifo with expected data
    for(i=0; i<length; i=i+1) begin
      tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
    end

    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + length;

    length      = 8'd16;
    send_private_read(tgt_addr,length,REP_START,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

    // -----------------------------------------
    // Send to wrong Address
    send_private_read(7'h50,8'd2,REP_START,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    send_private_write(7'h60,8'd2,mem_staddr,REP_START,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    send_private_read(7'h70,8'd2,REP_START,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

    // -----------------------------------------
    // Read when TGT FIFO is empty

    // configure target response when reading with empty FIFO
    // 1 byte data 0xFF then terminate read
    //`TGT_BFM_MEMW(tgt_sel,8'h29, 8'h00)
    // respond with NAK
    `TGT_BFM_MEMW(tgt_sel,8'h29, 8'h01)

    send_private_read(tgt_addr,8'd4,REP_START,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    // TGT FIFO is expected to be empty so
    // need to wait until this command is done before
    // proceeding to next transaction to avoid filling it with next expected data
    wait_trans_then_idle(16);

    // -----------------------------------------
    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd7;

    // Fill target fifo with expected data
    for(i=0; i<length; i=i+1) begin
      tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
    end

    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + length;

    length      = 8'd2;
    send_private_read(tgt_addr,length,START_OF_FRAME,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

    length      = 8'd3;
    send_private_read(tgt_addr,length,START_OF_FRAME,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

    length      = 8'd2;
    send_private_read(tgt_addr,length,START_OF_FRAME,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

    // -----------------------------------------
    wait_trans_then_idle(16);
    isr_priv_read(rd_staddr,total_wcnt,1'b0);
    data_exp_cnt = data_exp_cnt + total_wcnt;
    tgt_isr_priv_write(tgt_sel,rd_staddr,total_wcnt);

    wait_idle(16);
    total_wcnt  = 0; // reset counter
    mem_staddr  = $random;

    // -----------------------------------------
    // allow I2C frames
    `MST_BFM_MEMR(8'h02, 8'h00, 0, rdata)  // read config register
    `MST_BFM_MEMW(8'h02, (rdata | 8'h08))  // modify then write config
    // set I2C clock divider
    i2c_clk_div = ((I2C_DIV_INT - 1) > 8'hFF)? 8'hFF : (I2C_DIV_INT -1);
    `MST_BFM_MEMW(8'h04, i2c_clk_div)

    // reset dynamic address
    send_ccc_rstdaa;
    wait_trans_then_idle(16);

    i2c_clkdiv  = i2c_clk_div; // update for timer

    // -----------------------------------------
    // I2C mode transfer
    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd8;

    // Fill target fifo with expected data
    for(i=0; i<length; i=i+1) begin
      tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
    end

    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr_static,length,wr_staddr,START_OF_FRAME,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I2C_FRAME);
    data_exp_cnt = data_exp_cnt + length;

    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd16;

    // Fill target fifo with expected data
    for(i=0; i<length; i=i+1) begin
      tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
    end

    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr_static,length,wr_staddr,REP_START,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I2C_FRAME);
    data_exp_cnt = data_exp_cnt + length;

    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd8;

    // Fill target fifo with expected data
    for(i=0; i<length; i=i+1) begin
      tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
    end

    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr_static,length,wr_staddr,REP_START,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I2C_FRAME);
    data_exp_cnt = data_exp_cnt + length;

    rd_staddr   = mem_staddr;
    length      = 8'd32;
    send_private_read(tgt_addr_static,length,START_OF_FRAME,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I2C_FRAME);

    wait_trans_then_idle(1);
    wait_idle_i2c_clkdiv(16);
    // -----------------------------------------
    // Return to I3C mode
    // Set DASA
    send_ccc_set_dasa_1tgt(tgt_addr_static,tgt_addr);

    wait_trans_then_idle(1);
    wait_idle_i2c_clkdiv(16);

    // -----------------------------------------
    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd1;

    // Fill target fifo with expected data
    for(i=0; i<length; i=i+1) begin
      tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
    end

    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + length;

    length      = 8'd1;
    send_private_read(tgt_addr,length,START_OF_FRAME,
                      CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

    // -----------------------------------------
    wait_trans_then_idle(16);
    isr_priv_read(rd_staddr,total_wcnt,1'b0);
    data_exp_cnt = data_exp_cnt + total_wcnt;
    tgt_isr_priv_write(tgt_sel,rd_staddr,total_wcnt);

    wait_idle(16);
    total_wcnt  = 0; // reset counter
    mem_staddr  = $random;

    // -----------------------------------------
  end
endtask // sample_test_0

task sample_test_1;
  input [1:0] tgt_sel;
  reg [7:0] rdata, int_status, rd_cnt;
  reg       rd_cmd_done;

  reg [6:0] tgt_addr;
  reg [7:0] length;
  reg [7:0] mem_staddr;
  reg [8:0] total_wcnt;
  reg [7:0] wr_staddr;
  reg [7:0] rd_staddr;
  integer   i;
  begin
    rdata       = 8'd0;
    int_status  = 8'd0;
    rd_cmd_done = 0;
    rd_cnt      = 0;

    total_wcnt  = 9'd0;
    length      = 8'd0;
    mem_staddr  = 8'd0;

    // reset dynamic address
    send_ccc_rstdaa;
    wait_trans_then_idle(2);

    tgt_addr    = 7'h2D;
    // send_enter_daa_ccc_1tgt(tgt_addr);
    send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
    send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
    send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
    tgt_check_assigned_da(0,1'd1,tgt_addr+1);
    tgt_check_assigned_da(1,1'd1,tgt_addr+2);
    isr_generic;
    wait_idle(100);

    // Start Test
    wr_staddr   = mem_staddr;
    length      = 8'd4;
    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                       CONT_NXT_FRAME,WAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + length;
    repeat(700) @(posedge clk_i);

    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd4;
    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr,length,wr_staddr,REP_START,
                       CONT_NXT_FRAME,WAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + length;
    repeat(700) @(posedge clk_i);

    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd4;
    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr,length,wr_staddr,REP_START,
                       CONT_NXT_FRAME,WAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + length;
    repeat(700) @(posedge clk_i);

    wr_staddr   = mem_staddr + total_wcnt;
    length      = 8'd4;
    total_wcnt  = total_wcnt + length;
    send_private_write(tgt_addr,length,wr_staddr,REP_START,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + length;
    repeat(700) @(posedge clk_i);


    // Fill target fifo with expected data
    for(i=0; i<total_wcnt; i=i+1) begin
      tgt_write_tx_fifo(tgt_sel,wdata_mem[mem_staddr+i]);
    end

    rd_staddr   = mem_staddr;
    length      = 8'd4;
    send_private_read(tgt_addr,length,REP_START,
                      CONT_NXT_FRAME,WAIT_NXTPKT,I3C_FRAME);

    isr_priv_read(rd_staddr,length,1'b0);
    data_exp_cnt = data_exp_cnt + length;
    tgt_isr_priv_write(tgt_sel,rd_staddr,length);

    rd_staddr   = rd_staddr + length;
    length      = 8'd4;
    send_private_read(tgt_addr,length,REP_START,
                      CONT_NXT_FRAME,WAIT_NXTPKT,I3C_FRAME);

    isr_priv_read(rd_staddr,length,1'b0);
    data_exp_cnt = data_exp_cnt + length;
    tgt_isr_priv_write(tgt_sel,rd_staddr,length);

    rd_staddr   = rd_staddr + length;
    length      = 8'd4;
    send_private_read(tgt_addr,length,REP_START,
                      CONT_NXT_FRAME,WAIT_NXTPKT,I3C_FRAME);

    isr_priv_read(rd_staddr,length,1'b0);
    data_exp_cnt = data_exp_cnt + length;
    tgt_isr_priv_write(tgt_sel,rd_staddr,length);

    rd_staddr   = rd_staddr + length;
    length      = 8'd4;
    send_private_read(tgt_addr,length,REP_START,
                      CONT_NXT_FRAME,WAIT_NXTPKT,I3C_FRAME);

    repeat(700) @(posedge clk_i);
    wr_staddr   = mem_staddr + total_wcnt;
    total_wcnt  = total_wcnt + 1;
    send_private_write(tgt_addr,1,wr_staddr,REP_START,
                       CONT_NXT_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
    data_exp_cnt = data_exp_cnt + 1;
    wait_trans_then_idle(2);

    isr_priv_read(rd_staddr,length,1'b0);
    data_exp_cnt = data_exp_cnt + length;
    tgt_isr_priv_write(tgt_sel,rd_staddr,length);

    tgt_isr_priv_write(tgt_sel,wr_staddr,1);

    wait_idle(16);
  end
endtask // sample_test_1

task sample_test_2;
  input [1:0] tgt_sel;
  reg [7:0] rdata, int_status, rd_cnt;
  reg       rd_cmd_done;

  reg [6:0] tgt_addr;
  reg [7:0] length;
  reg [7:0] mem_staddr;
  reg [8:0] total_wcnt;
  reg [7:0] wr_staddr;
  reg [7:0] rd_staddr;
  reg [7:0] i2c_clk_div;
  begin
    rdata       = 8'd0;
    int_status  = 8'd0;
    rd_cmd_done = 0;
    rd_cnt      = 0;

    total_wcnt  = 9'd0;
    length      = 8'd0;
    mem_staddr  = $random;

    // reset dynamic address
    send_ccc_rstdaa;
    wait_trans_then_idle(2);

    tgt_addr    = 7'h1D;
    // send_enter_daa_ccc_1tgt(tgt_addr);
    send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
    send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
    send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
    wait_trans_then_idle(8);
    tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
    tgt_check_assigned_da(0,1'd1,tgt_addr+1);
    tgt_check_assigned_da(1,1'd1,tgt_addr+2);
    isr_generic;
    wait_idle(100);

    // Start Test
    // -----------------------------------------
    // Enable I3C Target loopback mode
    `TGT_BFM_MEMR(tgt_sel,8'h29, 8'h00, 0, rdata)  // read current setting
    `TGT_BFM_MEMW(tgt_sel,8'h29, (rdata | 8'h10))  // modify to enable loopback enable
    // -----------------------------------------
    repeat(2) begin
      wr_staddr   = mem_staddr;
      length      = 8'd255;

      total_wcnt  = total_wcnt + length;
      send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                         END_OF_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
      data_exp_cnt = data_exp_cnt + length;
      repeat(100) @(posedge clk_i);

      rd_staddr   = wr_staddr;
      length      = 8'd255;
      send_private_read(tgt_addr,length,START_OF_FRAME,
                        END_OF_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

      // -----------------------------------------
      wait_trans_then_idle(16);
      isr_priv_read(rd_staddr,total_wcnt,1'b0);

      wait_idle(8);
      total_wcnt  = 0; // reset counter
      mem_staddr  = $random;
    end

    // -----------------------------------------
    // Disable I3C Target loopback mode
    `TGT_BFM_MEMR(tgt_sel,8'h29, 8'h00, 0, rdata)  // read current setting
    `TGT_BFM_MEMW(tgt_sel,8'h29, (rdata & 8'hEF))  // modify to disable loopback enable
    wait_idle(8);
  end
endtask // sample_test_2

task sample_test_ccc;
  input [1:0] tgt_sel;
  reg [7:0] rdata, int_status, rd_cnt;
  reg       rd_cmd_done;

  reg [6:0] tgt_addr;
  reg [7:0] length;
  reg [7:0] mem_staddr;
  reg [8:0] total_wcnt;
  reg [7:0] wr_staddr;
  reg [7:0] rd_staddr;
  begin
    rdata       = 8'd0;
    int_status  = 8'd0;
    rd_cmd_done = 0;
    rd_cnt      = 0;

    total_wcnt  = 9'd0;
    length      = 8'd0;
    mem_staddr  = $random;

    // reset dynamic address
    send_ccc_rstdaa;
    wait_trans_then_idle(2);

    tgt_addr    = 7'h25;
    // send_enter_daa_ccc_1tgt(tgt_addr);
      send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
      send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
      send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
      wait_trans_then_idle(8);
      tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
      tgt_check_assigned_da(0,1'd1,tgt_addr+1);
      tgt_check_assigned_da(1,1'd1,tgt_addr+2);
    isr_generic;
    wait_idle(100);

    // Start Test
    $display("%12d: ==== SEND DIRECT ENTAS %0d ", $stime,2'd0);
    `MST_BFM_MEMW(8'h30, {2'd0,1'b0,2'd1,1'b0,2'd1})  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [4] = 0 -> rsvd
                                 // [5] = 0 -> wait_nextpkt
                                 // [7:6] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
    `MST_BFM_MEMW(8'h30, {1'b1,(7'd2+2'd0)})  // CCC Code - ENTASx CCC

    `MST_BFM_MEMW(8'h30, {2'd0,1'b0,2'd0,1'b0,2'd3})  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> not CCC_start
                                 // [4] = 0 -> rsvd
                                 // [5] = wait_nextpkt
                                 // [7:6] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {tgt_addr+1,1'b0})  // {7b target DA,W}
    `MST_BFM_MEMW(8'h30, 8'h00)  // Length = 0x0

    $display("%12d: ==== SEND DIRECT DISEC", $stime);
    `MST_BFM_MEMW(8'h30, 8'h0B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1+(1 if broadcast)
    `MST_BFM_MEMW(8'h30, 8'h81)  // CCC Code - ENEC/DISEC CCC

    `MST_BFM_MEMW(8'h30, {5'd0,1'b0,2'd3})  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> not CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {tgt_addr,1'b0})  // {7b target DA, W}
    `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
    `MST_BFM_MEMW(8'h30, 8'h00)  // enable/disable event

    `MST_BFM_MEMW(8'h30, {5'd0,1'b0,2'd3})  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> not CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {tgt_addr+1,1'b0})  // {7b target DA, W}
    `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
    `MST_BFM_MEMW(8'h30, 8'h00)  // enable/disable event

    `MST_BFM_MEMW(8'h30, {5'd0,1'b0,2'd3})  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> not CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {tgt_addr+2,1'b0})  // {7b target DA, W}
    `MST_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
    `MST_BFM_MEMW(8'h30, 8'h00)  // enable/disable event

    $display("%12d: ==== SEND BROADCAST DISEC", $stime);
    `MST_BFM_MEMW(8'h30, 8'h0B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `MST_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `MST_BFM_MEMW(8'h30, 8'h02)  // Length = 0x1+(1 if broadcast)
    `MST_BFM_MEMW(8'h30, 8'h01)  // CCC Code - ENEC/DISEC CCC
    `MST_BFM_MEMW(8'h30, 8'h00)  // enable/disable event

    `MST_BFM_MEMW(8'h11, 8'h01)  // start

    send_ccc_direct_enec_multi_tgt(3'd7,tgt_addr+0,1'b1);
    send_ccc_direct_enec_multi_tgt(3'd7,tgt_addr+1,1'b0);
    send_ccc_direct_enec_multi_tgt(3'd7,tgt_addr+2,1'b0);
    send_ccc_direct_enec_multi_tgt(3'd7,tgt_addr+3,1'b0);
    send_ccc_direct_enec_multi_tgt(3'd7,tgt_addr+4,1'b0);
    send_ccc_direct_enec_multi_tgt(3'd7,tgt_addr+5,1'b0);
    wait_trans_then_idle(2);
    isr_generic;

    wr_staddr   = mem_staddr;
    length      = 8'd2;

    total_wcnt  = total_wcnt + length;

    send_ccc_direct_set_mwl(tgt_addr,{wdata_mem[wr_staddr+0],
                                      wdata_mem[wr_staddr+1]});
    data_exp_cnt = data_exp_cnt + length;

    send_ccc_direct_get_mwl(tgt_addr);
    wait_trans_then_idle(8);

    isr_gen_read(wdata_mem[wr_staddr+0],1'b0);
    isr_gen_read(wdata_mem[wr_staddr+1],1'b1);

    wait_idle(8);
  end
endtask // sample_test_ccc

task sample_test_sec_ibi;
  input [1:0] tgt_sel;
  reg [7:0]  tgt_addr;
  begin
    if(ENABLE_SMI) begin
      send_ccc_rstdaa;
      wait_trans_then_idle(8);

      // assign Target DA using Enter DAA
      tgt_addr = 7'h22;
      // send_enter_daa_ccc_1tgt(tgt_addr);
      send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
      send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
      send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
      wait_trans_then_idle(8);
      tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
      tgt_check_assigned_da(0,1'd1,tgt_addr+1);
      tgt_check_assigned_da(1,1'd1,tgt_addr+2);
      wait_idle(8);

      tgt_send_sec_ibi_req(tgt_sel);
      @(negedge sda_io);
      repeat(60*(od_timer+1)*(sys_clkdiv+1)) @(posedge clk_i);
      isr_sec_ibi(tgt_addr,1'b1);
      @(negedge sda_io);
      repeat(60*(od_timer+1)*(sys_clkdiv+1)) @(posedge clk_i);
      isr_sec_ibi(tgt_addr,1'b0);

      wait_idle(8);
    end
    else begin
      $display("%12d: [SKIP TEST] Secondary Controller Feature is not enabled!",$stime);
    end
  end
endtask // sample_test_sec_ibi

task sample_test_getacccr;
  input [1:0] tgt_sel;
  reg [7:0]  tgt_addr;
  reg [19:0] timeout_100us;
  reg [7:0] rdata, int_status, rd_cnt;
  reg       rd_cmd_done;
  reg [7:0] length;
  reg [7:0] mem_staddr;
  reg [8:0] total_wcnt;
  reg [7:0] wr_staddr;
  reg [7:0] rd_staddr;
  begin
    if(ENABLE_SMI) begin
      timeout_100us = 20'd32;
      `SC_BFM_MEMW(8'h17,timeout_100us[7:0])          // reduce timer
      `SC_BFM_MEMW(8'h18,timeout_100us[15:8])         // reduce timer
      `SC_BFM_MEMW(8'h19,{4'd0,timeout_100us[19:16]}) // reduce timer
      `SC_BFM_MEMW(8'h20,8'hFF)                       // clear interrupt status
      `SC_BFM_MEMW(8'h24,8'hFF)                       // clear interrupt status

      `SC_BFM_MEMW((8'h30|8'h80),8'hFF)               // clear interrupt status
      `SC_BFM_MEMW((8'h33|8'h80),8'hFF)               // clear interrupt status
      `SC_BFM_MEMW((8'h36|8'h80),8'hFF)               // clear interrupt status

      send_ccc_rstdaa;
      wait_trans_then_idle(8);

      // assign Target DA using Enter DAA
      tgt_addr = 7'h36;
      // send_enter_daa_ccc_1tgt(tgt_addr);
      send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
      send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
      send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
      wait_trans_then_idle(8);
      tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
      tgt_check_assigned_da(0,1'd1,tgt_addr+1);
      tgt_check_assigned_da(1,1'd1,tgt_addr+2);
      wait_idle(8);
      isr_generic;

      `SC_BFM_MEMW(8'h05,8'h09)                       // enable pull-up resistor in SC

      send_ccc_getacccr(~tgt_addr); // non-existent address - expect NAK
      wait_trans_then_idle(8);
      isr_getacccr(1'b1,1'b1); // exp_result,exp_role - expect to retain previous active controller
      wait_idle(8);

      send_ccc_getacccr(tgt_addr);
      wait_trans_then_idle(8);
      isr_getacccr(1'b0,1'b0); // exp_result,exp_role - succesful handoff, expect new active controller
      wait_idle(8);

      // -----------------------------------------
      // Enable I3C Target loopback mode in DUT
      `MST_BFM_MEMR((8'h29|8'h80), 8'h00, 0, rdata)  // read current setting
      `MST_BFM_MEMW((8'h29|8'h80), (rdata | 8'h10))  // modify to enable loopback enable
      // -----------------------------------------
      `SC_BFM_MEMW(8'h02, 8'h34)  // controller config 0
                                  // - ibi_auto_resp, ignore_cmd_done, ignore NAK
      `SC_BFM_MEMW(8'h22, 8'hFF)  // interrupt enable 0
      `SC_BFM_MEMW(8'h26, 8'hFF)  // interrupt enable 1
      // DUT has become a Target - change BFM
      use_sc_bfm  = 1'b1;
      send_ccc_rstdaa;
      wait_trans_then_idle(8);

      // assign Target DA using Enter DAA
      tgt_addr = 7'h55;
      // send_enter_daa_ccc_1tgt(tgt_addr);
      send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
      send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
      send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
      wait_trans_then_idle(8);
      // tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
      tgt_check_assigned_da(0,1'd1,tgt_addr+1);
      tgt_check_assigned_da(1,1'd1,tgt_addr+2);
      // wait_idle(8);
      //isr_generic;

      rdata       = 8'd0;
      int_status  = 8'd0;
      rd_cmd_done = 0;
      rd_cnt      = 0;

      total_wcnt  = 9'd0;
      length      = 8'd0;
      mem_staddr  = $random;

      // -----------------------------------------
      wr_staddr   = mem_staddr;
      length      = 8'd16;
      total_wcnt  = total_wcnt + length;
      send_private_write(tgt_addr,length,wr_staddr,START_OF_FRAME,
                         END_OF_FRAME,NOWAIT_NXTPKT,I3C_FRAME);
      data_exp_cnt = data_exp_cnt + length;

      rd_staddr   = wr_staddr;
      length      = 8'd16;
      send_private_read(tgt_addr,length,START_OF_FRAME,
                        END_OF_FRAME,NOWAIT_NXTPKT,I3C_FRAME);

      // -----------------------------------------
      wait_trans_then_idle(16);
      isr_priv_read(rd_staddr,total_wcnt,1'b0);
      // -----------------------------------------

      wait_idle(8);
      use_sc_bfm  = 1'b0;
      // -----------------------------------------
      // Disable I3C Target loopback mode in DUT
      `MST_BFM_MEMR((8'h29|8'h80), 8'h00, 0, rdata)  // read current setting
      `MST_BFM_MEMW((8'h29|8'h80), (rdata & 8'hEF))  // modify to disable loopback enable
      total_wcnt  = 0; // reset counter
      mem_staddr  = $random;

    end
    else begin
      $display("%12d: [SKIP TEST] Secondary Controller Feature is not enabled!",$stime);
    end
  end
endtask // sample_test_getacccr

task sample_test_hdr_0;
  input [1:0] tgt_sel;
  reg [7:0] rdata, int_status, rd_cnt;
  reg       rd_cmd_done;

  reg [6:0] tgt_addr;
  reg [7:0] length;
  reg [7:0] mem_staddr;
  reg [8:0] total_wcnt;
  reg [7:0] wr_staddr;
  reg [7:0] rd_staddr;
  reg [6:0] usr_cmd_code;
  reg       first_burst;
  reg       last_burst;
  reg       ddr_ignore_cmd_done;
  reg       ddr_ignore_rcvd_nak;
  reg [2:0] endxfer_cfg;
  reg [7:0] exp_endxfer_dat_byte;
  integer   i;

  begin
    if(ENABLE_HDR_DDR) begin
      rdata       = 8'd0;
      int_status  = 8'd0;
      rd_cmd_done = 0;
      rd_cnt      = 0;
      usr_cmd_code= 7'd0;

      total_wcnt  = 9'd0;
      length      = 8'd0;
      mem_staddr  = $random;

      // reset dynamic address
      send_ccc_rstdaa;
      wait_trans_then_idle(2);

      tgt_addr    = 7'h37;
      // send_enter_daa_ccc_1tgt(tgt_addr);
      send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
      send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
      send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
      wait_trans_then_idle(8);
      tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
      tgt_check_assigned_da(0,1'd1,tgt_addr+1);
      tgt_check_assigned_da(1,1'd1,tgt_addr+2);
      isr_generic;
      wait_idle(10);

      // Configure End Transfer
      // -----------------------------------------
      endxfer_cfg = 3'd3;   // HDR config 0 - no_crc_after_term=0, en_wr_early_term=1, en_wrcmd_acknak_cap=1
      ddr_ignore_cmd_done = 1'b1;
      ddr_ignore_rcvd_nak = 1'b0;
      exp_endxfer_dat_byte = {((endxfer_cfg[2])? 2'b11 : 2'b01)
                             ,~endxfer_cfg[1]
                             ,~endxfer_cfg[0]
                             ,4'd0};
      `MST_BFM_MEMW(8'h06, {3'd0,ddr_ignore_rcvd_nak,ddr_ignore_cmd_done,endxfer_cfg})
      send_ccc_broadcast_endxfer(endxfer_cfg,1'b0); // set endxfer cfg
      send_ccc_broadcast_endxfer(endxfer_cfg,1'b1); // set confirm cfg
      send_ccc_direct_get_endxfer_1tgt(tgt_addr,endxfer_cfg,1'b0); // get endxfer cfg
      send_ccc_direct_get_endxfer_1tgt(tgt_addr,endxfer_cfg,1'b1); // get confirm cfg
      wait_trans_then_idle(2);
      data_exp_cnt = data_exp_cnt + 2;
      isr_gen_read(exp_endxfer_dat_byte,1'b0);
      isr_gen_read(exp_endxfer_dat_byte,1'b1);
      isr_generic;
      wait_idle(10);

      // Start Test
      // -----------------------------------------
      wr_staddr   = mem_staddr;
      length      = 8'd8;

      // Fill target fifo with expected data
      for(i=0; i<length; i=i+1) begin
        tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
      end

      total_wcnt  = total_wcnt + length;
      first_burst = 1'b1;
      last_burst  = 1'b0;
      send_hdr_write(tgt_addr,length,wr_staddr,first_burst,
                         last_burst,WAIT_NXTPKT,usr_cmd_code);
      data_exp_cnt = data_exp_cnt + length;
      repeat(100) @(posedge clk_i);

      rd_staddr   = wr_staddr;
      length      = 8'd8;
      first_burst = 1'b0;
      last_burst  = 1'b0;
      send_hdr_read(tgt_addr,length,first_burst,
                        last_burst,WAIT_NXTPKT,usr_cmd_code);

      wr_staddr   = mem_staddr + total_wcnt;
      length      = 8'd10;

      // Fill target fifo with expected data
      for(i=0; i<length; i=i+1) begin
        tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
      end

      total_wcnt  = total_wcnt + length;
      first_burst = 1'b0;
      last_burst  = 1'b0;
      send_hdr_write(tgt_addr,length,wr_staddr,first_burst,
                         last_burst,WAIT_NXTPKT,usr_cmd_code);
      data_exp_cnt = data_exp_cnt + length;

      length      = 8'd10;
      first_burst = 1'b0;
      last_burst  = 1'b1;
      send_hdr_read(tgt_addr,length,first_burst,
                        last_burst,NOWAIT_NXTPKT,usr_cmd_code);

      // -----------------------------------------
      wait_trans_then_idle(16);
      isr_priv_read(rd_staddr,total_wcnt,1'b0);
      data_exp_cnt = data_exp_cnt + total_wcnt;
      tgt_isr_priv_write(tgt_sel,rd_staddr,total_wcnt);

      wait_idle(16);
      total_wcnt  = 0; // reset counter
      mem_staddr  = $random;

      // -----------------------------------------
    end
    else begin
      $display("%12d: [SKIP TEST] HDR-DDR Feature is not enabled!",$stime);
    end
  end
endtask // sample_test_hdr_0

task sample_test_hdr_ccc;
  input [1:0] tgt_sel;
  reg [7:0] rdata, int_status, rd_cnt;
  reg       rd_cmd_done;

  reg [6:0] tgt_addr;
  reg [7:0] length;
  reg [7:0] mem_staddr;
  reg [8:0] total_wcnt;
  reg [7:0] wr_staddr;
  reg [7:0] rd_staddr;
  reg [6:0] usr_cmd_code;
  reg       first_burst;
  reg       last_burst;
  reg       ddr_ignore_cmd_done;
  reg       ddr_ignore_rcvd_nak;
  reg [2:0] endxfer_cfg;
  reg [7:0] exp_endxfer_dat_byte;
  integer   i;

  begin
    if(ENABLE_HDR_DDR) begin
      rdata       = 8'd0;
      int_status  = 8'd0;
      rd_cmd_done = 0;
      rd_cnt      = 0;
      usr_cmd_code= 7'd0;

      total_wcnt  = 9'd0;
      length      = 8'd0;
      mem_staddr  = $random;

      // reset dynamic address
      send_ccc_rstdaa;
      wait_trans_then_idle(2);

      tgt_addr    = 7'h25;
      // send_enter_daa_ccc_1tgt(tgt_addr);
      send_enter_daa_ccc(tgt_addr,2'd1,7'd3);
      send_enter_daa_ccc(tgt_addr+1,2'd0,7'd3);
      send_enter_daa_ccc(tgt_addr+2,2'd2,7'd3);
      wait_trans_then_idle(8);
      tgt_check_assigned_da(tgt_sel,1'd1,tgt_addr);
      tgt_check_assigned_da(0,1'd1,tgt_addr+1);
      tgt_check_assigned_da(1,1'd1,tgt_addr+2);
      isr_generic;
      wait_idle(10);

      // Configure End Transfer
      // -----------------------------------------
      endxfer_cfg = 3'd3;   // HDR config 0 - no_crc_after_term=0, en_wr_early_term=1, en_wrcmd_acknak_cap=1
      ddr_ignore_cmd_done = 1'b1;
      ddr_ignore_rcvd_nak = 1'b0;
      exp_endxfer_dat_byte = {((endxfer_cfg[2])? 2'b11 : 2'b01)
                             ,~endxfer_cfg[1]
                             ,~endxfer_cfg[0]
                             ,4'd0};
      `MST_BFM_MEMW(8'h06, {3'd0,ddr_ignore_rcvd_nak,ddr_ignore_cmd_done,endxfer_cfg})
      send_ccc_broadcast_endxfer(endxfer_cfg,1'b0); // set endxfer cfg
      send_ccc_broadcast_endxfer(endxfer_cfg,1'b1); // set confirm cfg
      send_ccc_direct_get_endxfer_1tgt(tgt_addr,endxfer_cfg,1'b0); // get endxfer cfg
      send_ccc_direct_get_endxfer_1tgt(tgt_addr,endxfer_cfg,1'b1); // get confirm cfg
      wait_trans_then_idle(2);
      data_exp_cnt = data_exp_cnt + 2;
      isr_gen_read(exp_endxfer_dat_byte,1'b0);
      isr_gen_read(exp_endxfer_dat_byte,1'b1);
      isr_generic;
      wait_idle(10);

      // Start Test
      // -----------------------------------------
      send_enter_hdr_ddr(WAIT_NXTPKT);
      repeat(200) @(posedge clk_i);

                     // broadcast, ccc_code, tgt_addr, fml, hdr1_sdr0
      send_ccc_entasx(1'b1,2'd0,tgt_addr,2'd3,1'b1);
      repeat(200) @(posedge clk_i);
      send_ccc_entasx(1'b0,2'd1,tgt_addr,2'd3,1'b1);
      send_hdr_end_ccc_mode(WAIT_NXTPKT);
      repeat(200) @(posedge clk_i);

      wr_staddr   = mem_staddr;
      length      = 8'd8;

      total_wcnt  = total_wcnt + length;
      first_burst = 1'b0;
      last_burst  = 1'b0;
      send_hdr_write(tgt_addr,length,wr_staddr,first_burst,
                         last_burst,WAIT_NXTPKT,usr_cmd_code);
      data_exp_cnt = data_exp_cnt + length;
      repeat(200) @(posedge clk_i);

      // Fill target fifo with expected data
      for(i=0; i<length; i=i+1) begin
        tgt_write_tx_fifo(tgt_sel,wdata_mem[wr_staddr+i]);
      end

      rd_staddr   = wr_staddr;
      length      = 8'd8;
      first_burst = 1'b0;
      last_burst  = 1'b1;
      send_hdr_read(tgt_addr,length,first_burst,
                        last_burst,NOWAIT_NXTPKT,usr_cmd_code);
      // -----------------------------------------
      wait_trans_then_idle(16);
      isr_priv_read(rd_staddr,total_wcnt,1'b0);
      data_exp_cnt = data_exp_cnt + total_wcnt;
      tgt_isr_priv_write(tgt_sel,rd_staddr,total_wcnt);

      // -----------------------------------------
      wait_idle(16);
    end
    else begin
      $display("%12d: [SKIP TEST] HDR-DDR Feature is not enabled!",$stime);
    end
  end
endtask // sample_test_hdr_ccc

// Test to transfer Controller Role to DUT when it is configured to start as Secondary Controller
task sample_test_sec_ctrl;
  reg [19:0] timeout_100us;
  reg [ 6:0] tgt_addr;
  begin
    if (ENABLE_SMI && ~DEVICE_ROLE[0]) begin
      $display("%12d: [SKIP TEST] DUT is Secondary Controller ",$stime);

      timeout_100us = 20'd32;
      `MST_BFM_MEMW(8'h17,timeout_100us[7:0])          // reduce timer
      `MST_BFM_MEMW(8'h18,timeout_100us[15:8])         // reduce timer
      `MST_BFM_MEMW(8'h19,{4'd0,timeout_100us[19:16]}) // reduce timer
      `MST_BFM_MEMW(8'h20,8'hFF)                       // clear interrupt status
      `MST_BFM_MEMW(8'h24,8'hFF)                       // clear interrupt status

      `MST_BFM_MEMW((8'h30|8'h80),8'hFF)               // clear interrupt status
      `MST_BFM_MEMW((8'h33|8'h80),8'hFF)               // clear interrupt status
      `MST_BFM_MEMW((8'h36|8'h80),8'hFF)               // clear interrupt status

      $display("%12d: ==== [TB PRIMARY CONTROLLER] SEND BROADCAST RSTDAA", $stime);
      `SC_BFM_MEMW(8'h30, 8'h0D)  // Control
                                  // [0] = 1 -> CCC1_PRIV0
                                  // [1] = 0 -> not repeated start
                                  // [2] = 1 -> Stop
                                  // [3] = 1 -> CCC_start
                                  // [7:4] = 0 -> rsvd
      `SC_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `SC_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1
      `SC_BFM_MEMW(8'h30, 8'h06)  // CCC Code - RSTDAA CCC
      `SC_BFM_MEMW(8'h11, 8'h01)  // start

      wait_trans_then_idle(8);

      tgt_addr = 7'h38;
      $display("%12d: ==== [TB PRIMARY CONTROLLER] SEND BROADCAST ENTER DAA", $stime);
      `SC_BFM_MEMW(8'h30, 8'h0D)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 0 -> not repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 1 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `SC_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `SC_BFM_MEMW(8'h30, 8'h04)  // Length = 0x1 + number of target address that follows
      `SC_BFM_MEMW(8'h30, 8'h07)  // CCC Code - ENTDAA CCC
      `SC_BFM_MEMW(8'h30, {tgt_addr,~^tgt_addr})  // {7b Dynamic Address assigned to target,Parity bit}
      `SC_BFM_MEMW(8'h30, {tgt_addr+1,~^(tgt_addr+1)})  // {7b Dynamic Address assigned to target,Parity bit}
      `SC_BFM_MEMW(8'h30, {tgt_addr+2,~^(tgt_addr+2)})  // {7b Dynamic Address assigned to target,Parity bit}

      `SC_BFM_MEMW(8'h11, 8'h01)  // start

      wait_idle(8);

      `MST_BFM_MEMW(8'hC3,8'h00)      // set GETACCCR response to ACK


      $display("%12d: ==== [TB PRIMARY CONTROLLER] SEND GET ACCEPT CONTROLLER ROLE", $stime);
      `SC_BFM_MEMW(8'h30, 8'h09)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 0 -> not repeated start
                                   // [2] = 0 -> Stop
                                   // [3] = 1 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `SC_BFM_MEMW(8'h30, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `SC_BFM_MEMW(8'h30, 8'h01)  // Length = 0x1+(1 if with_def_byte)
      `SC_BFM_MEMW(8'h30, 8'h91)  // CCC Code


      `SC_BFM_MEMW(8'h30, {5'd0,1'b1,2'd3})  // Control
                                  // [0] = 1 -> CCC1_PRIV0
                                  // [1] = 1 -> repeated start
                                  // [2] = 1 -> Stop
                                  // [3] = 0 -> CCC_start
                                  // [7:4] = 0 -> rsvd
      `SC_BFM_MEMW(8'h30, {tgt_addr,1'b1})  // {7b target current address, R}
      `SC_BFM_MEMW(8'h30, 8'h01)  // Length

      `SC_BFM_MEMW(8'h11, 8'h01)  // start
      wait_idle(8);
    end
    else begin
      $display("%12d: [SKIP TEST] DUT is Primary Controller ",$stime);
    end
  end
endtask // sample_test_sec_ctrl

initial begin
  wait(test_error);
  repeat(100) @(posedge clk_i);
  $stop;
end

// Max Simulation Time
`ifndef MAX_SIM_TIME
  `define MAX_SIM_TIME 15
`endif
initial begin
  #(`MAX_SIM_TIME*1e6); // End simulation after 10ms (default)
  $stop;
end

`define RUN_SAMPLE_TEST \
        initial begin                                                          \
          #1;                                                                  \
          test_error   = 1'b0;                                                 \
          daa_err_cnt  = 0;                                                    \
          data_err_cnt = 0;                                                    \
          csr_err_cnt  = 0;                                                    \
          data_exp_cnt = 0;                                                    \
          data_ok_cnt  = 0;                                                    \
          tgt_addr_static = 7'h09;                                             \
          rst_n_i = 1'b0;                                                      \
          repeat(10) @(posedge clk_i);                                       \
          rst_n_i = 1'b1;                                                      \
          repeat(10) @(posedge clk_i);                                       \
                                                                               \
          // initialize memory                                                 \
          initialize_tb_mem;                                                   \
          initialize_i3c_controller;                                           \
          initialize_i3c_target(`TGT_SEL);                                     \
          repeat(100) @(posedge clk_i);                                      \
                                                                               \
          sample_test_sec_ctrl;                                                \
          sample_test_rstact(`TGT_SEL);                                        \
          sample_test_hot_join(`TGT_SEL);                                      \
          sample_test_daa(`TGT_SEL);                                           \
          sample_test_0(`TGT_SEL);                                             \
          sample_test_1(`TGT_SEL);                                             \
          sample_test_2(`TGT_SEL);                                             \
          sample_test_ibi(`TGT_SEL);                                           \
          sample_test_ccc(`TGT_SEL);                                           \
          sample_test_hdr_0(`TGT_SEL);                                         \
          sample_test_hdr_ccc(`TGT_SEL);                                       \
          sample_test_sec_ibi(`TGT_SEL);                                       \
          sample_test_getacccr(`TGT_SEL);                                      \
                                                                               \
          // End Test                                                          \
          repeat(400) @(posedge scl_src_i);                                  \
          $display("\n\tData [ok]  count = %0d", data_ok_cnt);                 \
          $display("\tData [exp] count = %0d\n", data_exp_cnt);                \
          test_error = test_error | (data_exp_cnt != data_ok_cnt);             \
          if(test_error) begin                                                \
            $display("-----------------------------------------------------"); \
            $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!"); \
            $display("-----------------------------------------------------"); \
            $display("CSR  mismatch count = %0d", csr_err_cnt);                \
            $display("DAA  mismatch count = %0d", daa_err_cnt);                \
            $display("Data mismatch count = %0d", data_err_cnt);               \
            $display("Data missing count  = %0d", (data_exp_cnt-data_ok_cnt-   \
                                                                data_err_cnt));\
          end                                                                  \
          else begin                                                          \
            $display("-----------------------------------------------------"); \
            $display("----------------- SIMULATION PASSED -----------------"); \
            $display("-----------------------------------------------------"); \
          end                                                                  \
          $stop;                                                               \
        end                                                                    \

//--------------------------------------------------------------------------
//--- Module Instantiation ---
//--------------------------------------------------------------------------
`ifndef iCE40UP
  `ifdef ap6a00a
  GSRA GSR_INST (.GSR_N  (rst_n_i));
  `elsif LAV_AT
  GSRA GSR_INST (.GSR_N  (rst_n_i));
  `elsif LKH_CT_20
  GSRA GSR_INST (.GSR_N  (rst_n_i));
  `elsif LKH_MH_20
  GSRA GSR_INST (.GSR_N  (rst_n_i));
  `else
  GSR GSR_INST (.CLK(clk_i) ,.GSR_N  (rst_n_i));
  `endif
`endif


assign mst_int_o = u_i3c_dev.int_o;
`ifdef EN_I3C_SC0
assign sc0_int_o = u_i3c_dev.sc0_int_o;
`else
assign sc0_int_o = 1'b0;
`endif
`ifdef EN_I3C_TGT0
assign tgt0_int_o = u_i3c_dev.tgt0_int_o;
`else
assign tgt0_int_o = 1'b0;
`endif
`ifdef EN_I3C_TGT1
assign tgt1_int_o = u_i3c_dev.tgt1_int_o;
`else
assign tgt1_int_o = 1'b0;
`endif

i3c_device_inst #
(
 // Parameters
 .SIMULATION                            (SIMULATION)
,.SYS_CLK_PERIOD                        (SYS_CLK_PERIOD)
,.TGT_LOOPBK_EN0                        (TGT_LOOPBK_EN0)
,.TGT_LOOPBK_EN1                        (TGT_LOOPBK_EN1)
 )
u_i3c_dev
(
 // Inputs
 .clk_i                                 (clk_i)
,.rst_n_i                               (rst_n_i)
,.src_clk_scl_i                         (scl_src_i)
 // Inouts
,.scl_io                                (scl_io)
,.sda_io                                (sda_io)
,.sc0_scl_io                            (scl_io)
,.sc0_sda_io                            (sda_io)
,.tgt0_scl_io                           (scl_io)
,.tgt0_sda_io                           (sda_io)
,.tgt1_scl_io                           (scl_io)
,.tgt1_sda_io                           (sda_io)
 /*AUTOINST*/);

mst_bfm_stream #(.TXDWID(TXDWID), .RXDWID(RXDWID)) fifo_intf_bfm
(
 // Inputs
 .clk_i                                 (clk_i),
 .rst_n_i                               (rst_n_i),
 .tx_ready_o                            (u_i3c_dev.tx_ready_o),
 .rx_valid_o                            (u_i3c_dev.rx_valid_o),
 .rx_data_o                             (u_i3c_dev.rx_data_o),
 // Outputs
 .tx_valid_i                            (u_i3c_dev.tx_valid_i),
 .tx_data_i                             (u_i3c_dev.tx_data_i),
 .rx_ready_i                            (u_i3c_dev.rx_ready_i)
 /*AUTOINST*/);

initial begin
  fifo_intf_bfm.init;
end

generate
  if(SEL_INTF == "LMMI") begin : gen_bfm_0
    mst_bfm_lmmi reg_intf_bfm
    (
    // Inputs
     .clk_i                                 (clk_w)
    ,.rst_n_i                               (rst_n_i)
    ,.lmmi_ready_i                          (u_i3c_dev.lmmi_ready_o      )
    ,.lmmi_rdata_valid_i                    (u_i3c_dev.lmmi_rdata_valid_o)
    ,.lmmi_error_i                          (u_i3c_dev.lmmi_error_o      )
    ,.lmmi_rdata_i                          (u_i3c_dev.lmmi_rdata_o      )
    ,.int_i                                 (u_i3c_dev.int_o             )
    // Outputs
    ,.lmmi_request_o                        (u_i3c_dev.lmmi_request_i    )
    ,.lmmi_wr_rdn_o                         (u_i3c_dev.lmmi_wr_rdn_i     )
    ,.lmmi_offset_o                         (u_i3c_dev.lmmi_offset_i     )
    ,.lmmi_wdata_o                          (u_i3c_dev.lmmi_wdata_i      )
    /*AUTOINST*/);
     initial begin
       reg_intf_bfm.init;
     end

    `ifdef EN_I3C_SC0
      mst_bfm_lmmi sc0_reg_intf_bfm
      (
      // Inputs
       .clk_i                                 (clk_w)
      ,.rst_n_i                               (rst_n_i)
      ,.lmmi_ready_i                          (u_i3c_dev.sc0_lmmi_ready_o      )
      ,.lmmi_rdata_valid_i                    (u_i3c_dev.sc0_lmmi_rdata_valid_o)
      ,.lmmi_error_i                          (u_i3c_dev.sc0_lmmi_error_o      )
      ,.lmmi_rdata_i                          (u_i3c_dev.sc0_lmmi_rdata_o      )
      ,.int_i                                 (u_i3c_dev.sc0_int_o             )
      // Outputs
      ,.lmmi_request_o                        (u_i3c_dev.sc0_lmmi_request_i    )
      ,.lmmi_wr_rdn_o                         (u_i3c_dev.sc0_lmmi_wr_rdn_i     )
      ,.lmmi_offset_o                         (u_i3c_dev.sc0_lmmi_offset_i     )
      ,.lmmi_wdata_o                          (u_i3c_dev.sc0_lmmi_wdata_i      )
      /*AUTOINST*/);
      initial begin
        sc0_reg_intf_bfm.init;
      end
    `endif

    `ifdef EN_I3C_TGT0
      mst_bfm_lmmi tgt0_reg_intf_bfm
      (
      // Inputs
       .clk_i                                 (clk_w)
      ,.rst_n_i                               (rst_n_i)
      ,.lmmi_ready_i                          (u_i3c_dev.tgt0_lmmi_ready_o      )
      ,.lmmi_rdata_valid_i                    (u_i3c_dev.tgt0_lmmi_rdata_valid_o)
      ,.lmmi_error_i                          (u_i3c_dev.tgt0_lmmi_error_o      )
      ,.lmmi_rdata_i                          (u_i3c_dev.tgt0_lmmi_rdata_o      )
      ,.int_i                                 (u_i3c_dev.tgt0_int_o             )
      // Outputs
      ,.lmmi_request_o                        (u_i3c_dev.tgt0_lmmi_request_i    )
      ,.lmmi_wr_rdn_o                         (u_i3c_dev.tgt0_lmmi_wr_rdn_i     )
      ,.lmmi_offset_o                         (u_i3c_dev.tgt0_lmmi_offset_i     )
      ,.lmmi_wdata_o                          (u_i3c_dev.tgt0_lmmi_wdata_i      )
      /*AUTOINST*/);
      initial begin
        tgt0_reg_intf_bfm.init;
      end
    `endif

    `ifdef EN_I3C_TGT1
      mst_bfm_lmmi tgt1_reg_intf_bfm
      (
      // Inputs
       .clk_i                                 (clk_w)
      ,.rst_n_i                               (rst_n_i)
      ,.lmmi_ready_i                          (u_i3c_dev.tgt1_lmmi_ready_o      )
      ,.lmmi_rdata_valid_i                    (u_i3c_dev.tgt1_lmmi_rdata_valid_o)
      ,.lmmi_error_i                          (u_i3c_dev.tgt1_lmmi_error_o      )
      ,.lmmi_rdata_i                          (u_i3c_dev.tgt1_lmmi_rdata_o      )
      ,.int_i                                 (u_i3c_dev.tgt1_int_o             )
      // Outputs
      ,.lmmi_request_o                        (u_i3c_dev.tgt1_lmmi_request_i    )
      ,.lmmi_wr_rdn_o                         (u_i3c_dev.tgt1_lmmi_wr_rdn_i     )
      ,.lmmi_offset_o                         (u_i3c_dev.tgt1_lmmi_offset_i     )
      ,.lmmi_wdata_o                          (u_i3c_dev.tgt1_lmmi_wdata_i      )
      /*AUTOINST*/);
      initial begin
        tgt1_reg_intf_bfm.init;
      end
    `endif

    `RUN_SAMPLE_TEST
  end // gen_bfm_0

  if(SEL_INTF == "APB") begin : gen_bfm_1
    wire        [TB_APB_AWID-1:0]             apb_paddr_w;

    assign u_i3c_dev.apb_paddr_i = (REG_MAPPING)? {apb_paddr_w,2'd0} : apb_paddr_w;

    mst_bfm_apb reg_intf_bfm
    (
     .PCLK                                  (clk_i)
    ,.PRST_N                                (rst_n_i)
    ,.PENABLE                               (u_i3c_dev.apb_penable_i)
    ,.PSEL                                  (u_i3c_dev.apb_psel_i   )
    ,.PWRITE                                (u_i3c_dev.apb_pwrite_i )
    ,.PADDR                                 (apb_paddr_w            )
    ,.PWDATA                                (u_i3c_dev.apb_pwdata_i )
    ,.PREADY                                (u_i3c_dev.apb_pready_o )
    ,.PSLVERR                               (u_i3c_dev.apb_pslverr_o)
    ,.PRDATA                                (u_i3c_dev.apb_prdata_o )
    ,.INTR                                  (u_i3c_dev.int_o        )
    /*AUTOINST*/);
     initial begin
       reg_intf_bfm.init;
     end

    `ifdef EN_I3C_SC0
      wire        [TB_APB_AWID-1:0]             sc0_apb_paddr_w;
      assign u_i3c_dev.sc0_apb_paddr_i = (REG_MAPPING)? {sc0_apb_paddr_w,2'd0} : sc0_apb_paddr_w;
      mst_bfm_apb sc0_reg_intf_bfm
      (
       .PCLK                                  (clk_i)
      ,.PRST_N                                (rst_n_i)
      ,.PENABLE                               (u_i3c_dev.sc0_apb_penable_i)
      ,.PSEL                                  (u_i3c_dev.sc0_apb_psel_i   )
      ,.PWRITE                                (u_i3c_dev.sc0_apb_pwrite_i )
      ,.PADDR                                 (sc0_apb_paddr_w            )
      ,.PWDATA                                (u_i3c_dev.sc0_apb_pwdata_i )
      ,.PREADY                                (u_i3c_dev.sc0_apb_pready_o )
      ,.PSLVERR                               (u_i3c_dev.sc0_apb_pslverr_o)
      ,.PRDATA                                (u_i3c_dev.sc0_apb_prdata_o )
      ,.INTR                                  (u_i3c_dev.sc0_int_o        )
      /*AUTOINST*/);
       initial begin
         sc0_reg_intf_bfm.init;
       end
    `endif

    `ifdef EN_I3C_TGT0
      wire        [TB_APB_AWID-1:0]             tgt0_apb_paddr_w;
      assign u_i3c_dev.tgt0_apb_paddr_i = (REG_MAPPING)? {tgt0_apb_paddr_w,2'd0} : tgt0_apb_paddr_w;
      mst_bfm_apb tgt0_reg_intf_bfm
      (
       .PCLK                                  (clk_i)
      ,.PRST_N                                (rst_n_i)
      ,.PENABLE                               (u_i3c_dev.tgt0_apb_penable_i)
      ,.PSEL                                  (u_i3c_dev.tgt0_apb_psel_i   )
      ,.PWRITE                                (u_i3c_dev.tgt0_apb_pwrite_i )
      ,.PADDR                                 (tgt0_apb_paddr_w            )
      ,.PWDATA                                (u_i3c_dev.tgt0_apb_pwdata_i )
      ,.PREADY                                (u_i3c_dev.tgt0_apb_pready_o )
      ,.PSLVERR                               (u_i3c_dev.tgt0_apb_pslverr_o)
      ,.PRDATA                                (u_i3c_dev.tgt0_apb_prdata_o )
      ,.INTR                                  (u_i3c_dev.tgt0_int_o        )
      /*AUTOINST*/);
       initial begin
         tgt0_reg_intf_bfm.init;
       end
    `endif

    `ifdef EN_I3C_TGT1
      wire        [TB_APB_AWID-1:0]             tgt1_apb_paddr_w;
      assign u_i3c_dev.tgt1_apb_paddr_i = (REG_MAPPING)? {tgt1_apb_paddr_w,2'd0} : tgt1_apb_paddr_w;
      mst_bfm_apb tgt1_reg_intf_bfm
      (
       .PCLK                                  (clk_i)
      ,.PRST_N                                (rst_n_i)
      ,.PENABLE                               (u_i3c_dev.tgt1_apb_penable_i)
      ,.PSEL                                  (u_i3c_dev.tgt1_apb_psel_i   )
      ,.PWRITE                                (u_i3c_dev.tgt1_apb_pwrite_i )
      ,.PADDR                                 (tgt1_apb_paddr_w            )
      ,.PWDATA                                (u_i3c_dev.tgt1_apb_pwdata_i )
      ,.PREADY                                (u_i3c_dev.tgt1_apb_pready_o )
      ,.PSLVERR                               (u_i3c_dev.tgt1_apb_pslverr_o)
      ,.PRDATA                                (u_i3c_dev.tgt1_apb_prdata_o )
      ,.INTR                                  (u_i3c_dev.tgt1_int_o        )
      /*AUTOINST*/);
       initial begin
         tgt1_reg_intf_bfm.init;
       end
    `endif

    `RUN_SAMPLE_TEST
  end // gen_bfm_1

  if(SEL_INTF == "AHBL") begin : gen_bfm_2
    wire         [TB_AHBL_AWID-1:0]                     ahbl_haddr_w;

    assign u_i3c_dev.ahbl_haddr_i  = (REG_MAPPING)? {ahbl_haddr_w,2'd0} : ahbl_haddr_w;
    assign u_i3c_dev.ahbl_hready_i = 1'b1;

    mst_bfm_ahbl reg_intf_bfm
    (
     // Inputs
     .clk_i                             (clk_i),
     .rst_n_i                           (rst_n_i),
     .ahbl_hready_i                     (u_i3c_dev.ahbl_hreadyout_o),
     .ahbl_hresp_i                      (u_i3c_dev.ahbl_hresp_o),
     .ahbl_hrdata_i                     (u_i3c_dev.ahbl_hrdata_o),
     .int_i                             (u_i3c_dev.int_o),
     // Outputs
     .ahbl_hsel_o                       (u_i3c_dev.ahbl_hsel_i),
     .ahbl_haddr_o                      (ahbl_haddr_w),
     .ahbl_hburst_o                     (u_i3c_dev.ahbl_hburst_i),
     .ahbl_hsize_o                      (u_i3c_dev.ahbl_hsize_i),
     .ahbl_hmastlock_o                  (u_i3c_dev.ahbl_hmastlock_i),
     .ahbl_hprot_o                      (u_i3c_dev.ahbl_hprot_i),
     .ahbl_htrans_o                     (u_i3c_dev.ahbl_htrans_i),
     .ahbl_hwrite_o                     (u_i3c_dev.ahbl_hwrite_i),
     .ahbl_hwdata_o                     (u_i3c_dev.ahbl_hwdata_i)
    /*AUTOINST*/);
     initial begin
       reg_intf_bfm.init;
     end

    `ifdef EN_I3C_SC0
      wire         [TB_AHBL_AWID-1:0]                     sc0_ahbl_haddr_w;
      assign u_i3c_dev.sc0_ahbl_haddr_i  = (REG_MAPPING)? {sc0_ahbl_haddr_w,2'd0} : sc0_ahbl_haddr_w;
      assign u_i3c_dev.sc0_ahbl_hready_i = 1'b1;
      mst_bfm_ahbl sc0_reg_intf_bfm
      (
       // Inputs
       .clk_i                             (clk_i),
       .rst_n_i                           (rst_n_i),
       .ahbl_hready_i                     (u_i3c_dev.sc0_ahbl_hreadyout_o),
       .ahbl_hresp_i                      (u_i3c_dev.sc0_ahbl_hresp_o),
       .ahbl_hrdata_i                     (u_i3c_dev.sc0_ahbl_hrdata_o),
       .int_i                             (u_i3c_dev.sc0_int_o),
       // Outputs
       .ahbl_hsel_o                       (u_i3c_dev.sc0_ahbl_hsel_i),
       .ahbl_haddr_o                      (sc0_ahbl_haddr_w),
       .ahbl_hburst_o                     (u_i3c_dev.sc0_ahbl_hburst_i),
       .ahbl_hsize_o                      (u_i3c_dev.sc0_ahbl_hsize_i),
       .ahbl_hmastlock_o                  (u_i3c_dev.sc0_ahbl_hmastlock_i),
       .ahbl_hprot_o                      (u_i3c_dev.sc0_ahbl_hprot_i),
       .ahbl_htrans_o                     (u_i3c_dev.sc0_ahbl_htrans_i),
       .ahbl_hwrite_o                     (u_i3c_dev.sc0_ahbl_hwrite_i),
       .ahbl_hwdata_o                     (u_i3c_dev.sc0_ahbl_hwdata_i)
      /*AUTOINST*/);
       initial begin
         sc0_reg_intf_bfm.init;
       end
    `endif

    `ifdef EN_I3C_TGT0
      wire         [TB_AHBL_AWID-1:0]                     tgt0_ahbl_haddr_w;
      assign u_i3c_dev.tgt0_ahbl_haddr_i  = (REG_MAPPING)? {tgt0_ahbl_haddr_w,2'd0} : tgt0_ahbl_haddr_w;
      assign u_i3c_dev.tgt0_ahbl_hready_i = 1'b1;
      mst_bfm_ahbl tgt0_reg_intf_bfm
      (
       // Inputs
       .clk_i                             (clk_i),
       .rst_n_i                           (rst_n_i),
       .ahbl_hready_i                     (u_i3c_dev.tgt0_ahbl_hreadyout_o),
       .ahbl_hresp_i                      (u_i3c_dev.tgt0_ahbl_hresp_o),
       .ahbl_hrdata_i                     (u_i3c_dev.tgt0_ahbl_hrdata_o),
       .int_i                             (u_i3c_dev.tgt0_int_o),
       // Outputs
       .ahbl_hsel_o                       (u_i3c_dev.tgt0_ahbl_hsel_i),
       .ahbl_haddr_o                      (tgt0_ahbl_haddr_w),
       .ahbl_hburst_o                     (u_i3c_dev.tgt0_ahbl_hburst_i),
       .ahbl_hsize_o                      (u_i3c_dev.tgt0_ahbl_hsize_i),
       .ahbl_hmastlock_o                  (u_i3c_dev.tgt0_ahbl_hmastlock_i),
       .ahbl_hprot_o                      (u_i3c_dev.tgt0_ahbl_hprot_i),
       .ahbl_htrans_o                     (u_i3c_dev.tgt0_ahbl_htrans_i),
       .ahbl_hwrite_o                     (u_i3c_dev.tgt0_ahbl_hwrite_i),
       .ahbl_hwdata_o                     (u_i3c_dev.tgt0_ahbl_hwdata_i)
      /*AUTOINST*/);
       initial begin
         tgt0_reg_intf_bfm.init;
       end
    `endif

    `ifdef EN_I3C_TGT1
      wire         [TB_AHBL_AWID-1:0]                     tgt1_ahbl_haddr_w;
      assign u_i3c_dev.tgt1_ahbl_haddr_i  = (REG_MAPPING)? {tgt1_ahbl_haddr_w,2'd0} : tgt1_ahbl_haddr_w;
      assign u_i3c_dev.tgt1_ahbl_hready_i = 1'b1;
      mst_bfm_ahbl tgt1_reg_intf_bfm
      (
       // Inputs
       .clk_i                             (clk_i),
       .rst_n_i                           (rst_n_i),
       .ahbl_hready_i                     (u_i3c_dev.tgt1_ahbl_hreadyout_o),
       .ahbl_hresp_i                      (u_i3c_dev.tgt1_ahbl_hresp_o),
       .ahbl_hrdata_i                     (u_i3c_dev.tgt1_ahbl_hrdata_o),
       .int_i                             (u_i3c_dev.tgt1_int_o),
       // Outputs
       .ahbl_hsel_o                       (u_i3c_dev.tgt1_ahbl_hsel_i),
       .ahbl_haddr_o                      (tgt1_ahbl_haddr_w),
       .ahbl_hburst_o                     (u_i3c_dev.tgt1_ahbl_hburst_i),
       .ahbl_hsize_o                      (u_i3c_dev.tgt1_ahbl_hsize_i),
       .ahbl_hmastlock_o                  (u_i3c_dev.tgt1_ahbl_hmastlock_i),
       .ahbl_hprot_o                      (u_i3c_dev.tgt1_ahbl_hprot_i),
       .ahbl_htrans_o                     (u_i3c_dev.tgt1_ahbl_htrans_i),
       .ahbl_hwrite_o                     (u_i3c_dev.tgt1_ahbl_hwrite_i),
       .ahbl_hwdata_o                     (u_i3c_dev.tgt1_ahbl_hwdata_i)
      /*AUTOINST*/);
       initial begin
         tgt1_reg_intf_bfm.init;
       end
    `endif

    `RUN_SAMPLE_TEST
  end // gen_bfm_2
endgenerate

endmodule //--tb_top--
`endif // __RTL_MODULE__TB_TOP__


`include "i3c_device_inst.v"
`include "tb_models.v"

module mst_bfm_lmmi
(

 input                         clk_i                // clock
,input                         rst_n_i              // active low reset

,input                         lmmi_ready_i         // target is ready to start new transaction
,input                         lmmi_rdata_valid_i   // read transaction is complete
,input                         lmmi_error_i         // error indicator
,input       [7:0]             lmmi_rdata_i         // read data

,output reg                    lmmi_request_o       // start transaction
,output reg                    lmmi_wr_rdn_o        // write 1 / read 0
,output reg  [7:0]             lmmi_offset_o        // address/offset
,output reg  [7:0]             lmmi_wdata_o         // write data

,input                         int_i
);


task init;
begin
  lmmi_request_o = 1'd0;
  lmmi_wr_rdn_o  = 1'd0;
  lmmi_offset_o  = 8'd0;
  lmmi_wdata_o   = 8'd0;
end
endtask

task memw;
input   [7:0]   addr;
input   [7:0]   data;
reg             ready;
begin
    // request
    lmmi_request_o <= 1'b1;
    lmmi_wr_rdn_o  <= 1'b1;
    lmmi_offset_o  <= addr;
    lmmi_wdata_o   <= data;
    @(posedge clk_i)

    // wait until PREADY is asserted
    //@(negedge clk_i);
    ready = lmmi_ready_i;
    while(!ready) begin
      @(posedge clk_i);
      ready = lmmi_ready_i;
    end
    //wait (lmmi_ready_i);

    //@(posedge clk_i);
    //@(posedge clk_i) begin
        lmmi_request_o <= 1'b0;
        lmmi_wr_rdn_o  <= 1'b0;
        lmmi_wdata_o   <= 8'h0;
    //end

    $display("%12d: [Write] addr %8x data %8x",$stime, addr, data);
end
endtask

task memr;
input   [7:0]   addr;
input   [7:0]   chk;
input           verify;
output [7:0]    rdata;
reg             ready;
begin
    // SETUP phase
    //@(posedge clk_i) begin
        lmmi_request_o <= 1'b1;
        lmmi_wr_rdn_o  <= 1'b0;
        lmmi_offset_o  <= addr;
    //end
    @(posedge clk_i)

    // extended until PREADY is asserted
    //@(negedge clk_i);
    //wait (lmmi_ready_i);
    ready = lmmi_ready_i;
    while(!ready) begin
      @(posedge clk_i);
      ready = lmmi_ready_i;
    end

    //@(posedge clk_i) begin
        lmmi_request_o <= 1'b0;
    //end

    @(negedge clk_i);
    wait (lmmi_rdata_valid_i);
    rdata = lmmi_rdata_i;

    if (verify && lmmi_rdata_i != chk)
        $display("%12d: [ERROR] addr %8x data %8x != exp %8x",$stime, addr, lmmi_rdata_i, chk);
    else
        $display("%12d: [Read] addr %8x data %8x",$stime, addr, lmmi_rdata_i);
end
endtask

task wait_int;
  begin
    wait(int_i);
  end
endtask

endmodule

module mst_bfm_apb #
(
 parameter        TB_APB_AWID = 32
,parameter        TB_APB_DWID = 32
)
(
    PCLK,
    PRST_N,
    PENABLE,
    PSEL,
    PWRITE,
    PADDR,
    PWDATA,
    PREADY,
    PSLVERR,
    PRDATA,
    INTR
);

input                       PCLK;
input                       PRST_N;
output                      PENABLE;
output                      PSEL;
output                      PWRITE;
output  [TB_APB_AWID-1:0]   PADDR;
output  [TB_APB_DWID-1:0]   PWDATA;
input                       PREADY;
input                       PSLVERR;
input   [TB_APB_DWID-1:0]   PRDATA;
input                       INTR;

reg                         PENABLE;
reg                         PSEL;
reg                         PWRITE;
reg     [TB_APB_AWID-1:0]   PADDR;
reg     [TB_APB_DWID-1:0]   PWDATA;

task init;
begin
    PENABLE = 1'b0;
    PSEL = 1'b0;
    PWRITE = 1'b0;
    PADDR = {TB_APB_AWID{1'b0}};
    PWDATA = 8'd0;
end
endtask

task memw;
input   [TB_APB_AWID-1:0]   addr;
input   [TB_APB_DWID-1:0]   data;
begin
    // SETUP phase
    @(posedge PCLK) begin
        PADDR = addr;
        PWRITE = 1'b1;
        PSEL = 1'b1;
        PWDATA = data;
    end

    // ACCESS phase
    @(posedge PCLK) begin
        PENABLE = 1'b1;
    end

    // extended until PREADY is asserted
    @(negedge PCLK);
    wait (PREADY);

    @(posedge PCLK) begin
        PSEL = 1'b0;
        PENABLE = 1'b0;
        PWDATA = 8'h0;
    end

    $display("%12d: [Write] addr %8x data %8x",$stime, addr, data);
end
endtask

task memr;
input   [TB_APB_AWID-1:0]   addr;
input   [TB_APB_DWID-1:0]   chk;
input                       verify;
output [TB_APB_DWID-1:0]    rdata;
begin
    // SETUP phase
    @(posedge PCLK) begin
        PADDR = addr;
        PWRITE = 1'b0;
        PSEL = 1'b1;
    end

    // ACCESS phase
    @(posedge PCLK) begin
        PENABLE = 1'b1;
    end

    // extended until PREADY is asserted
    @(negedge PCLK);
    wait (PREADY);

    @(posedge PCLK) begin
        PSEL = 1'b0;
        PENABLE = 1'b0;
    end

    rdata = PRDATA;

    if (verify && PRDATA != chk)
        $display("%12d: [ERROR] addr %8x data %8x != exp %8x",$stime, addr, PRDATA, chk);
    else
        $display("%12d: [Read] addr %8x data %8x",$stime, addr, PRDATA);
end
endtask

task wait_int;
  begin
    wait(INTR);
  end
endtask

endmodule

module mst_bfm_ahbl #
(
 parameter                              TB_AHBL_AWID = 32
,parameter                              TB_AHBL_DWID = 32
)
(

 input                                  clk_i                // clock
,input                                  rst_n_i              // active low reset

,output reg                             ahbl_hsel_o
,output reg   [TB_AHBL_AWID-1:0]        ahbl_haddr_o
,output reg   [2:0]                     ahbl_hburst_o
,output reg   [2:0]                     ahbl_hsize_o
,output reg                             ahbl_hmastlock_o
,output reg   [3:0]                     ahbl_hprot_o
,output reg   [1:0]                     ahbl_htrans_o
,output reg                             ahbl_hwrite_o
,output reg   [TB_AHBL_DWID-1:0]        ahbl_hwdata_o

,input                                  ahbl_hready_i
,input                                  ahbl_hresp_i
,input        [TB_AHBL_DWID-1:0]        ahbl_hrdata_i

,input                                  int_i
);


reg           [TB_AHBL_DWID-1:0]        ahbl_nxt_data;

task init;
begin
  ahbl_hsel_o      = {1{1'b0}};
  ahbl_htrans_o    = {2{1'b0}};
  ahbl_hwrite_o    = {1{1'b0}};
  ahbl_haddr_o     = {TB_AHBL_AWID{1'b0}};
  ahbl_hwdata_o    = {TB_AHBL_DWID{1'b0}};
  ahbl_hburst_o    = {3{1'b0}};
  ahbl_hsize_o     = {3{1'b0}};
  ahbl_hmastlock_o = {1{1'b0}};
  ahbl_hprot_o     = {4{1'b0}};
end
endtask

task memw;
input   [TB_AHBL_AWID-1:0] addr;
input   [TB_AHBL_DWID-1:0] data;
reg                        ready,resp;
begin
    // request
    ahbl_hsel_o    <= 1'b1;
    ahbl_htrans_o  <= 2'd2;
    ahbl_hwrite_o  <= 1'b1;
    ahbl_haddr_o   <= addr;
    ahbl_nxt_data  <= data;
    @(posedge clk_i)

    ready = ahbl_hready_i;
    resp  = ahbl_hresp_i;
    while(!ready) begin
      @(posedge clk_i);
      ready = ahbl_hready_i;
      resp  = ahbl_hresp_i;
    end

    ahbl_hsel_o    <= 1'b0;
    ahbl_htrans_o  <= 2'd0;
    ahbl_hwrite_o  <= 1'b0;

    $display("%12d: [Write] addr %8x data %8x",$stime, addr, data);
end
endtask

always @(posedge clk_i or negedge rst_n_i) begin
  if(~rst_n_i) begin
    ahbl_hwdata_o  <= {TB_AHBL_DWID{1'b0}};
    /*AUTORESET*/
  end
  else begin
    if(ahbl_hsel_o & ahbl_htrans_o[1] & ahbl_hwrite_o & ahbl_hready_i) begin
      ahbl_hwdata_o <= ahbl_nxt_data;
    end
  end
end //--always @(posedge clk_i or negedge rst_n_i)--

task memr;
input   [TB_AHBL_AWID-1:0]   addr;
input   [TB_AHBL_DWID-1:0]   chk;
input                        verify;
output  [TB_AHBL_DWID-1:0]   rdata;
reg                          ready,resp;
begin
    ahbl_hsel_o    <= 1'b1;
    ahbl_htrans_o  <= 2'd2;
    ahbl_hwrite_o  <= 1'b0;
    ahbl_haddr_o   <= addr;
    @(posedge clk_i)

    ready = ahbl_hready_i;
    resp  = ahbl_hresp_i;
    while(!ready) begin
      @(posedge clk_i);
      ready = ahbl_hready_i;
      resp  = ahbl_hresp_i;
    end

    ahbl_hsel_o    <= 1'b0;
    ahbl_htrans_o  <= 2'd0;

    @(negedge clk_i);
    wait (ahbl_hready_i);
    rdata = ahbl_hrdata_i;

    if (verify && rdata != chk)
        $display("%12d: [ERROR] addr %8x data %8x != exp %8x",$stime, addr, rdata, chk);
    else
        $display("%12d: [Read] addr %8x data %8x",$stime, addr, rdata);
end
endtask

task wait_int;
  begin
    wait(int_i);
  end
endtask

endmodule

module mst_bfm_stream #
(
 parameter        TXDWID = 8
,parameter        RXDWID = 8
)
(

 input                          clk_i                // clock
,input                          rst_n_i              // active low reset

// Tx FIFO
,output reg   [(TXDWID/8)-1:0]  tx_valid_i
,output reg   [TXDWID-1:0]      tx_data_i

,input                          tx_ready_o

// Rx FIFO
,output reg                     rx_ready_i

,input        [(RXDWID/8)-1:0]  rx_valid_o
,input        [RXDWID-1:0]      rx_data_o

);


task init;
begin
  tx_valid_i = {(TXDWID/8){1'b0}};
  tx_data_i  = {TXDWID{1'b0}};
  rx_ready_i = 1'b0;
end
endtask

task memw;
input   [TXDWID-1:0] data;
reg                  ready;
begin
    // request
    tx_valid_i[0]   <= 1'b1;
    tx_data_i[7:0] <= data;
    @(posedge clk_i)

    // wait until READY is asserted
    ready = tx_ready_o;
    while(!ready) begin
      @(posedge clk_i);
      ready = tx_ready_o;
    end

    tx_valid_i[0]  <= 1'b0;
    tx_data_i[7:0] <= {TXDWID{1'b0}};

    $display("%12d: [Write] Tx data %8x",$stime, data);
end
endtask

task memr;
input   [RXDWID-1:0]  chk;
input                 verify;
output [RXDWID-1:0]   rdata;
reg                   ready;
begin
    rx_ready_i <= 1'b1;
    @(posedge clk_i)

    ready = rx_valid_o;
    rdata = rx_data_o;
    while(!ready) begin
      @(posedge clk_i);
      ready = rx_valid_o;
      rdata = rx_data_o;
    end

    rx_ready_i <= 1'b0;
    if (verify && rdata != chk)
        $display("%12d: [ERROR] Rx data %8x != exp %8x",$stime, rdata, chk);
    else
        $display("%12d: [Read] Rx data %8x",$stime, rdata);
end
endtask

endmodule

