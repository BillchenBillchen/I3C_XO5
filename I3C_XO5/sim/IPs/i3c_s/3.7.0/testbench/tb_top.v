`ifndef __I3C_TGT__TB_TOP__
`define __I3C_TGT__TB_TOP__

`timescale 1ns / 1ps

//----------------------------------------------------------------
// Include Files
//----------------------------------------------------------------
`include "tb_models.v"
`include "tb_bfm.v"
`include "tb_registers.v"
`include "tb_defines.v"

module tb_top ();
parameter SIMULATION = 0;

//----------------------------------------------------------------
// Local Parameters/Defines
//----------------------------------------------------------------
`include "dut_params.v"

`ifdef SYSCLK_FREQ
localparam  SYS_CLK_PERIOD   = 1000/`SYSCLK_FREQ;
`else
localparam  SYS_CLK_PERIOD   = 1000/25;
`endif
localparam  SCL_FREQ         = 12.5; // MHz
localparam  SCL_CLK_PERIOD   = 1000/SCL_FREQ;

localparam  LMMI_AWID        = 8;
localparam  LMMI_DWID        = 8;
localparam  APB_AWID         = LMMI_AWID + 2*REG_MAPPING;
localparam  APB_DWID         = LMMI_DWID;
localparam  AHBL_AWID        = LMMI_AWID + 2*REG_MAPPING;
localparam  AHBL_DWID        = LMMI_DWID;
localparam  TB_APB_AWID      = 32;
localparam  TB_APB_DWID      = 32;
localparam  TB_AHBL_AWID     = 32;
localparam  TB_AHBL_DWID     = 32;

localparam  DYN_ADDR         = 7'h34;
localparam  MAX_IBI_RETRY    = SIMULATION ? 8'h2 : 8'h8;

//----------------------------------------------------------------
// Register and Wire Declarations
//----------------------------------------------------------------
reg                       rst_n_i;
reg                       clk_i;
reg                       scl_src_i;

tri1                      sda_io;
tri1                      scl_io;

wire                      int_o;
wire                      tgt_int_o;
wire                      ctl_int_o;
wire                      ctl_sc_rst_o;

wire                      ctl_lmmi_request_i;
wire  [LMMI_AWID-1:0]     ctl_lmmi_offset_i;
wire                      ctl_lmmi_wr_rdn_i;
wire  [LMMI_DWID-1:0]     ctl_lmmi_wdata_i;
wire                      ctl_lmmi_ready_o;
wire                      ctl_lmmi_rdata_valid_o;
wire  [LMMI_DWID-1:0]     ctl_lmmi_rdata_o;
wire                      ctl_lmmi_error_o;

wire                      lmmi_request_i;
wire  [LMMI_AWID-1:0]     lmmi_offset_i;
wire                      lmmi_wr_rdn_i;
wire  [LMMI_DWID-1:0]     lmmi_wdata_i;
wire                      lmmi_ready_o;
wire                      lmmi_rdata_valid_o;
wire  [LMMI_DWID-1:0]     lmmi_rdata_o;
wire                      lmmi_error_o;

wire  [TB_APB_AWID-1:0]   ctl_apb_paddr_i;
wire                      ctl_apb_psel_i;
wire                      ctl_apb_penable_i;
wire                      ctl_apb_pwrite_i;
wire  [TB_APB_DWID-1:0]   ctl_apb_pwdata_i;
wire                      ctl_apb_pready_o;
wire  [TB_APB_DWID-1:0]   ctl_apb_prdata_o;
wire                      ctl_apb_pslverr_o;

wire  [TB_APB_AWID-1:0]   apb_paddr_i;
wire                      apb_penable_i;
wire                      apb_psel_i;
wire  [TB_APB_DWID-1:0]   apb_pwdata_i;
wire                      apb_pwrite_i;

wire  [TB_APB_DWID-1:0]   apb_prdata_o;
wire                      apb_pready_o;
wire                      apb_pslverr_o;

wire                      ctl_ahbl_hsel_i;
wire                      ctl_ahbl_hready_i;
wire  [TB_AHBL_AWID-1:0]  ctl_ahbl_haddr_i;
wire  [2:0]               ctl_ahbl_hburst_i;
wire  [2:0]               ctl_ahbl_hsize_i;
wire                      ctl_ahbl_hmastlock_i;
wire  [3:0]               ctl_ahbl_hprot_i;
wire  [1:0]               ctl_ahbl_htrans_i;
wire                      ctl_ahbl_hwrite_i;
wire  [TB_AHBL_DWID-1:0]  ctl_ahbl_hwdata_i;
wire                      ctl_ahbl_hreadyout_o;
wire                      ctl_ahbl_hresp_o;
wire  [TB_AHBL_DWID-1:0]  ctl_ahbl_hrdata_o;

wire                      ahbl_hsel_i;
wire                      ahbl_hready_i;
wire  [TB_AHBL_AWID-1:0]  ahbl_haddr_i;
wire  [2:0]               ahbl_hburst_i;
wire  [2:0]               ahbl_hsize_i;
wire                      ahbl_hmastlock_i;
wire  [3:0]               ahbl_hprot_i;
wire  [1:0]               ahbl_htrans_i;
wire                      ahbl_hwrite_i;
wire  [TB_AHBL_DWID-1:0]  ahbl_hwdata_i;
wire                      ahbl_hreadyout_o;
wire                      ahbl_hresp_o;
wire  [TB_AHBL_DWID-1:0]  ahbl_hrdata_o;

wire                      ctl_tx_valid_i;
wire  [7:0]               ctl_tx_data_i;
wire                      ctl_rx_ready_i;
wire                      ctl_tx_ready_o;
wire                      ctl_rx_valid_o;
wire  [7:0]               ctl_rx_data_o;

wire                      tx_valid_i;
wire  [7:0]               tx_data_i;
wire                      rx_ready_i;
wire                      tx_ready_o;
wire                      rx_valid_o;
wire  [7:0]               rx_data_o;

reg   [6:0]               dyn_addr;
reg   [6:0]               stat_addr;
reg   [7:0]               ibi_data_pay;
reg   [7:0]               tgt_int_status3;
reg   [7:0]               csr_rdata_act;

reg   [7:0]               wdata_mem[255:0];
integer                   wdata_mem_start;
integer                   wdata_mem_end;
integer                   wdata_mem_index;
integer                   data_err_cnt;
integer                   da_err_cnt;
reg                       test_error;
reg   [511:0]             testname;

//----------------------------------------------------------------
// Clock generation
//----------------------------------------------------------------
initial begin
  clk_i = 1'b0;
  forever begin
    clk_i = #(SYS_CLK_PERIOD/2) ~clk_i;
  end
end

// SCL 12.5 MHz
initial begin
  scl_src_i = 1'b0;
  forever begin
    scl_src_i = #(SCL_CLK_PERIOD/2) ~scl_src_i;
  end
end

//----------------------------------------------------------------
// Maximum Simulation Time
//----------------------------------------------------------------
`ifndef MAX_SIM_TIME
  `define MAX_SIM_TIME 50
`endif
initial begin
  #(`MAX_SIM_TIME*1e6); // End simulation after 50ms (default)
  $display("%12d: ERROR: Maximum simulation time reached!", $stime);
  $stop;
end

//----------------------------------------------------------------
// Test Sequence
//----------------------------------------------------------------
`define RUN_SAMPLE_TEST \
        initial begin                                     \
          #1;                                             \
          rst_n_i = 1'b1;                                 \
          repeat(20) @(posedge clk_i);                    \
          rst_n_i = 1'b0;                                 \
          repeat(20) @(posedge clk_i);                    \
          rst_n_i = 1'b1;                                 \
          repeat(10) @(posedge clk_i);                    \
          initialize_tb;                                  \
          initialize_tb_mem;                              \
          initialize_i3c_controller;                      \
          initialize_i3c_target;                          \
          repeat(100) @(posedge clk_i);                   \
          i2c_test(8'h0F);                                \
          repeat(100) @(posedge clk_i);                   \
          hotjoin_test;                                   \
          repeat(500) @(posedge clk_i);                   \
          send_ccc_broadcast_setaasa;                     \
          send_ccc_broadcast_rstdaa;                      \
          send_ccc_broadcast_entdaa;                      \
          send_ccc_direct_disec(1, 1);                    \
          send_ccc_direct_enec(1, 1, 1);                  \
          send_ccc_broadcast_disec(1, 1);                 \
          send_ccc_broadcast_enec(1, 1, 1);               \
          repeat(1500) @(posedge clk_i);                  \
          i3c_test(8'hFD);                                \
          i3c_test(8'hFD);                                \
          repeat(1200) @(posedge clk_i);                  \
          ibi_test(ibi_data_pay, 8'hAA);                  \
          i3c_test(8'h0F);                                \
          repeat(500) @(posedge clk_i);                   \
          send_ccc_broadcast_rstdaa;                      \
          send_ccc_direct_setdasa(stat_addr);             \
          send_ccc_broadcast_entasx(3'h2);                \
          send_ccc_broadcast_entasx(3'h3);                \
          send_ccc_broadcast_entasx(3'h4);                \
          send_ccc_broadcast_entasx(3'h5);                \
          send_ccc_direct_entasx(3'h2, dyn_addr);         \
          send_ccc_direct_entasx(3'h2, dyn_addr + 2);     \
          send_ccc_direct_entasx(3'h3, dyn_addr);         \
          send_ccc_direct_entasx(3'h4, dyn_addr);         \
          send_ccc_direct_entasx(3'h5, dyn_addr);         \
          send_ccc_getmxds(0, 8'h00);                     \
          send_ccc_getmxds(1, 8'h91);                     \
          send_ccc_getmxds(1, 8'h00);                     \
          send_ccc_getmxds(1, 8'h08);                     \
          send_ccc_direct_getmwl;                         \
          send_ccc_direct_setmwl(8'h15, 8'h00);           \
          send_ccc_direct_getmwl;                         \
          send_ccc_broadcast_setmwl(8'h10, 8'h10);        \
          send_ccc_direct_getmwl;                         \
          send_ccc_direct_getmrl(1'b1);                   \
          send_ccc_direct_setmrl(8'h15, 8'h00);           \
          send_ccc_direct_getmrl(1'b1);                   \
          send_ccc_direct_setnewda(dyn_addr + 8);         \
          send_ccc_broadcast_setmrl(8'h15, 8'h00);        \
          send_ccc_direct_getmrl(1'b1);                   \
          send_ccc_direct_getpid;                         \
          send_ccc_direct_getbcr;                         \
          send_ccc_direct_getdcr;                         \
          send_ccc_direct_getstatus(0, 8'h00);            \
          send_ccc_direct_getstatus(1, 8'h91);            \
          send_ccc_direct_getstatus(1, 8'h00);            \
          send_ccc_direct_getstatus(1, 8'h3F);            \
          send_ccc_direct_getcaps(0, 8'h00);              \
          send_ccc_direct_getcaps(1, 8'h91);              \
          send_ccc_direct_getcaps(1, 8'h00);              \
          send_ccc_direct_getcaps(1, 8'h12);              \
          send_ccc_broadcast_rstact(8'h1);                \
          send_ccc_direct_rstact(8'h2, 0);                \
          send_ccc_broadcast_rstact(8'h0);                \
          send_ccc_direct_rstact(8'h1, 1);                \
          send_ccc_broadcast_rstact(8'h2);                \
          send_ccc_direct_rstact(8'h0, 1);                \
          send_ccc_broadcast_rstact(8'h5);                \
          send_ccc_broadcast_rstact(8'h4);                \
          // secondary_controller_test;                      \
          // send_ccc_broadcast_deftgts;                     \
          send_ccc_direct_getacccr(1);                    \
          send_ccc_direct_getacccr(0);                    \
          soft_reset_chk(5'b0_0_0_0_1);                   \
          initialize_i3c_target;                          \
          i2c_test(8'h8);                                 \
          soft_reset_chk(5'b0_0_1_0_0);                   \
          send_ccc_broadcast_entdaa;                      \
          send_ccc_broadcast_setxtime(8'hDF);             \
          send_ccc_direct_setxtime(8'hDF);                \
          send_ccc_broadcast_setxtime(8'hFF);             \
          send_ccc_direct_setxtime(8'hFF);                \
          send_ccc_broadcast_setxtime(8'h00);             \
          send_ccc_direct_setxtime(8'h0F);                \
          repeat(1000) @(posedge clk_i);                  \
          send_ccc_direct_setxtime(8'hDF);                \
          // ibi_test(ibi_data_pay, 8'h80);                  \
          send_ccc_direct_setxtime(8'hFF);                \
          // ibi_test(ibi_data_pay, 8'h81);                  \
          send_ccc_direct_setxtime(8'hDF);                \
          send_ccc_direct_getxtime;                       \
          send_ccc_direct_setxtime(8'hFF);                \
          send_ccc_direct_getxtime;                       \
          repeat(1000) @(posedge clk_i);                  \
          hdr_ddr_test;                                   \
          repeat(5000) @(posedge clk_i);                  \
          chk_error;                                      \
          $stop;                                          \
        end                                               \

//----------------------------------------------------------------
// Tasks
//----------------------------------------------------------------
task initialize_tb;
  begin
    stat_addr       = STATIC_ADDR;
    dyn_addr        = DYN_ADDR;
    wdata_mem_start = 0;
    wdata_mem_end   = 0;
    wdata_mem_index = 0;
    data_err_cnt    = 0;
    da_err_cnt      = 0;
    test_error      = 0;
    testname        = "Initialize TB";
    ibi_data_pay    = IBI_DATA_PAY;
    tgt_int_status3 = 8'h0;
  end
endtask

task initialize_tb_mem;
  reg [8:0] mem_addr;
  begin
    testname        = "Initialize TB Memory";
    for(mem_addr=0; mem_addr<256; mem_addr=mem_addr + 1) begin
      wdata_mem[mem_addr] = $random;
    end
  end
endtask // initialize_tb_mem

task initialize_i3c_target;
  begin
    $display("%12d: ==== I3C TARGET INITIALIZATION", $stime);
    testname        = "Initialize I3c Target";
    // Enable interrupts
    `TGT_BFM_MEMW(`TGT_ADR_STAT1_INT_EN, 8'hEF)
    `TGT_BFM_MEMW(`TGT_ADR_STAT2_INT_EN, 8'hCF)
    `TGT_BFM_MEMW(`TGT_ADR_STAT3_INT_EN, 8'hF8)
  end
endtask // initialize_i3c_target

task initialize_i3c_controller;
  begin
    testname        = "Initialize I3C Controller";
    $display("%12d: ==== I3C CONTROLLER INITIALIZATION", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_MSTCFG0, 8'h14)  // controller config 0
                                 // ignore_cmd_done, ignore NAK
    `CTL_BFM_MEMW(`CTL_ADR_HDRCFG0, {5'd0,3'd3})
    `CTL_BFM_MEMW(`CTL_ADR_INTENA0, 8'hDF)  // interrupt enable 0
    `CTL_BFM_MEMW(`CTL_ADR_INTENA1, 8'h07)  // interrupt enable 1
  end
endtask // initialize_i3c_controller

task hotjoin_test;
  reg   [7:0]   ctl_int_status0;
  reg   [7:0]   tgt_int_status1;
  reg   [7:0]   tgt_int_status2;
  reg   [7:0]   rxfifo_rdata;
  reg           hj_done;
  integer       hj_retry;

  begin
    testname        = "Hot-Join Test";
    if (HOTJOIN_CAPABLE) begin
      $display("%12d: ==== Start Hot-Join Test", $stime);
      repeat(100) @(posedge clk_i);
      target_isr_generic;

      $display("%12d: ==== Generate Hot-Join request", $stime);
      `TGT_BFM_MEMW(`TGT_ADR_HJ_IBI_REQ, 8'h08)
      wait (tgt_int_o);

      // HotJoin Timeout
      for (hj_retry = 0 ; hj_retry <= MAX_IBI_RETRY ; hj_retry = hj_retry + 1) begin
        // read interrupt status
        `TGT_BFM_MEMR(`TGT_ADR_STAT1_INT, 8'h00, 0, tgt_int_status1)  // get int status
        `TGT_BFM_MEMR(`TGT_ADR_STAT2_INT, 8'h00, 0, tgt_int_status2)  // get int status

        while (|tgt_int_status1) begin
          if (tgt_int_status1[7]) begin
            $display("%12d: [DEBUG] Hot-Join request generated",$stime);
            if (hj_retry == MAX_IBI_RETRY) begin
              `CTL_BFM_MEMW(`CTL_ADR_IBIRESP, {7'h0, 1'h0}) // ACK the Hot Join
            end else begin
              `CTL_BFM_MEMW(`CTL_ADR_IBIRESP, {7'h0, 1'h1}) // NACK the Hot Join
            end
          end

          while (~(tgt_int_status1[5] ^ tgt_int_status1[6])) begin
            `TGT_BFM_MEMR(`TGT_ADR_STAT1_INT, 8'h00, 0, tgt_int_status1)  // get int status
            if (tgt_int_status1[5]) begin
              $display("%12d: [DEBUG] Hot-Join is NACKEd",$stime);
            end
            if (tgt_int_status1[6]) begin
              $display("%12d: [DEBUG] Hot-Join is DONE",$stime);
              hj_done = 1'b1;
            end
          end

          `TGT_BFM_MEMW(`TGT_ADR_STAT1_INT, tgt_int_status1)  // get int status
          `TGT_BFM_MEMR(`TGT_ADR_STAT1_INT, 8'h00, 0, tgt_int_status1)  // get int status
        end

        if (hj_done) begin
          $display("%12d: ==== Hot-Join is finished", $stime);
        end else begin
          $display("%12d: ==== Hot-Join is nACKed, retrying... (%0d)", $stime, hj_retry+1);
          `TGT_BFM_MEMW(`TGT_ADR_HJ_IBI_REQ, 8'h08)
          wait (tgt_int_o);
        end
      end
    end else begin
      $display("%12d: ==== [Skip Test] Hot-Join Capability is not enabled in device", $stime);
    end
  end
endtask // hotjoin_test

task ibi_test;
  input [7:0]   ibi_payload;
  input [7:0]   ibi_mdb;

  reg           ibi_done;
  reg   [7:0]   ctl_int_status;
  reg   [7:0]   tgt_int_status1;
  reg   [7:0]   ctl_rdata;
  reg   [7:0]   wdata_mem_index;
  integer       data_cntr;
  integer       ibi_retry;

  begin
    testname        = "IBI Test";
    if (IBI_CAPABLE) begin
      $display("%12d: ==== Start IBI Test", $stime);
      repeat(100) @(posedge clk_i);
      target_isr_generic;

      wdata_mem_index = wdata_mem_start;

      if (wdata_mem_start + ibi_payload > 255) begin
        wdata_mem_end = wdata_mem_start + ibi_payload - 255;
      end else begin
        wdata_mem_end = wdata_mem_start + ibi_payload;
      end

      // repeat (50) @(posedge clk_i);
      // soft_reset_chk(5'b0_0_1_0_0);

      $display("%12d: ==== Write IBI payload to Target Tx FIFO", $stime);
      `TGT_BFM_MEMW(`TGT_ADR_TX_FIFO, ibi_mdb)
      for (data_cntr = 0; data_cntr < ibi_payload; data_cntr = data_cntr + 1) begin
        `TGT_BFM_MEMW(`TGT_ADR_TX_FIFO, wdata_mem[wdata_mem_index])
        if (wdata_mem_index == 255) begin
          wdata_mem_index = 0 ;
        end else begin
          wdata_mem_index = wdata_mem_index + 1;
        end
      end
      repeat (50) @(posedge clk_i);

      wdata_mem_start = (wdata_mem_end == 255) ? 8'h0 : wdata_mem_end + 1;

      $display("%12d: ==== Send IBI request", $stime);
      `TGT_BFM_MEMW(`TGT_ADR_HJ_IBI_REQ, 8'h01)
      wait (tgt_int_o);

      for (ibi_retry = 0 ; ibi_retry <= MAX_IBI_RETRY ; ibi_retry = ibi_retry + 1) begin
        // read interrupt status
        `TGT_BFM_MEMR(`TGT_ADR_STAT1_INT, 8'h00, 0, tgt_int_status1)  // get int status

        while (|tgt_int_status1) begin
          if (tgt_int_status1[3]) begin
            $display("%12d: [DEBUG] IBI is generated",$stime);
            if (ibi_retry == MAX_IBI_RETRY) begin
              `CTL_BFM_MEMW(`CTL_ADR_IBIRCNT, ibi_payload) // IBI Read Count
              `CTL_BFM_MEMW(`CTL_ADR_IBIRESP, {7'h0, 1'h0}) // ACK the Hot Join
            end else begin
              `CTL_BFM_MEMW(`CTL_ADR_IBIRESP, {7'h0, 1'h1}) // NACK the Hot Join
            end
          end

          while (~(tgt_int_status1[1] ^ tgt_int_status1[2])) begin
            `TGT_BFM_MEMR(`TGT_ADR_STAT1_INT, 8'h00, 0, tgt_int_status1)  // get int status
            if (tgt_int_status1[1]) begin
              $display("%12d: [DEBUG] IBI is nacked",$stime);
            end
            if (tgt_int_status1[2]) begin
              if (ibi_payload > 0) begin
              $display("%12d: [DEBUG] IBI is ACKed and payload is read",$stime);
              end else begin
                $display("%12d: [DEBUG] IBI is ACKed",$stime);
              end
              ibi_done = 1'b1;
            end
          end

          `TGT_BFM_MEMW(`TGT_ADR_STAT1_INT, tgt_int_status1)  // clear int status
          `TGT_BFM_MEMR(`TGT_ADR_STAT1_INT, 8'h00, 0, tgt_int_status1)  // get int status
        end
      
        if (ibi_done) begin
          $display("%12d: ==== IBI is finished", $stime);
        end else begin
          $display("%12d: ==== IBI is nACKed, retrying... (%0d)", $stime, ibi_retry+1);
          `TGT_BFM_MEMW(`TGT_ADR_HJ_IBI_REQ, 8'h01)
          wait (tgt_int_o);
        end
      end
    end else begin
      $display("%12d: ==== [Skip Test] Hot-Join Capability is not enabled in device", $stime);
    end
  end
endtask // ibi_test

task secondary_controller_test;
  reg   [7:0]   ctl_int_status0;
  reg   [7:0]   tgt_int_status1;
  reg   [7:0]   rdata;
  integer       hotjoin_retry;

  begin
    testname        = "Secondary Controller Test ";

    $display("%12d: ==== Start Secondary Controller Test", $stime);
    repeat(100) @(posedge clk_i);

    $display("%12d: ==== I3C Private Write", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h06) // Control
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h45,1'b0})  // {7b target address,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // length (number of bytes) of data read
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    $display("%12d: ==== Generate Controller request", $stime);
    wait (~scl_io);
    `TGT_BFM_MEMW(`TGT_ADR_HJ_IBI_REQ, 8'h02)

    repeat(500) @(posedge clk_i);
    `CTL_BFM_MEMW(`CTL_ADR_IBIRESP, 8'h01)

    repeat(200) @(posedge clk_i);

    $display("%12d: ==== Regenerate Controller request", $stime);
    `TGT_BFM_MEMW(`TGT_ADR_HJ_IBI_REQ, 8'h02)

    repeat(800) @(posedge clk_i);
    `CTL_BFM_MEMW(`CTL_ADR_IBIRESP, 8'h00)

    repeat(200) @(posedge clk_i);
  end
endtask // secondary_controller_test

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
  integer         priv_w_idx;
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

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, control) // Control
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {tgt_addr,1'b0})  // {7b target address,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, length)  // length (number of bytes) of data read
    for(priv_w_idx = 0 ; priv_w_idx < length; priv_w_idx = priv_w_idx + 1) begin
      mem_addr = mem_start_addr + priv_w_idx;
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, wdata_mem[mem_addr])  // write data
    end
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
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
  reg    [7:0]    ctl_rdata;
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
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, control) // Control
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {tgt_addr,1'b1})  // {7b target address,R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, length)  // length (number of bytes) of data read
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    // Read from Controller TxFIFO
    wait (ctl_int_o);
    while (ctl_int_o) begin
      // read interrupt status
      `CTL_BFM_MEMR(`CTL_ADR_INTSTAT0, 8'h00, 0, ctl_rdata)  // get int status
      $display("%12d: [DEBUG] ctl_int_status2 = %0h",$stime,ctl_rdata);

      if (ctl_rdata[1]) begin
        `CTL_BFM_MEMR(`CTL_ADR_RXFIFO, 8'h00, 0, ctl_rdata)
      end

      // clear interrupt status
      `CTL_BFM_MEMW(`CTL_ADR_INTSTAT0, 8'hFF)
      `CTL_BFM_MEMW(`CTL_ADR_INTSTAT1, 8'hFF)
    end
  end
endtask // send_private_read

task send_hdr_ddr_write_read;
  integer       data_cntr;

  begin
    testname        = "HDR-DDR Write-Read";

    wdata_mem_index = wdata_mem_start;

    if (wdata_mem_start + 128 > 255) begin
      wdata_mem_end = wdata_mem_start + 128 - 255;
    end
    else begin
      wdata_mem_end = wdata_mem_start + 128;
    end

    $display("%12d: ==== Write data to Target Tx FIFO", $stime);
    for (data_cntr = 0; data_cntr < 128; data_cntr = data_cntr + 1) begin
      `TGT_BFM_MEMW(`TGT_ADR_TX_FIFO, wdata_mem[wdata_mem_index])
      if (wdata_mem_index == 255) begin
        wdata_mem_index = 0 ;
      end
      else begin
        wdata_mem_index = wdata_mem_index + 1;
      end
    end

    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> not repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND HDR-DDR Write NACK", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h82)  // Control
                                // [0] = 0 -> CCC1_PRIV0
                                // [1] = 1 -> repeated start
                                // [2] = 0 -> Stop
                                // [3] = 0 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr + 1,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h05)  // Length = 0x5
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h1F)  //
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h2E)  //
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h3D)  //
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h4C)  //
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h5B)  //

    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> not repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND HDR-DDR Write", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h82)  // Control
                                // [0] = 0 -> CCC1_PRIV0
                                // [1] = 1 -> repeated start
                                // [2] = 0 -> Stop
                                // [3] = 0 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h05)  // Length = 0x5
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h1F)  //
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h2E)  //
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h3D)  //
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h4C)  //
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h5B)  //

    repeat(100) @(posedge clk_i);

    $display("%12d: ==== SEND HDR-DDR READ", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h82)  // Control
                                // [0] = 0 -> CCC1_PRIV0
                                // [1] = 1 -> repeated start
                                // [2] = 0 -> Stop
                                // [3] = 0 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b1, 7'h14})  // Read Command

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h82)  // Control
                                // [0] = 0 -> CCC1_PRIV0
                                // [1] = 1 -> not repeated start
                                // [2] = 0 -> Stop
                                // [3] = 0 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h64)  // Length = 0x4


    $display("%12d: ==== SEND HDR-DDR READ", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h82)  // Control
                                // [0] = 0 -> CCC1_PRIV0
                                // [1] = 1 -> repeated start
                                // [2] = 0 -> Stop
                                // [3] = 0 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b1, 7'h14})  // Read Command

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h86)  // Control
                                // [0] = 0 -> CCC1_PRIV0
                                // [1] = 1 -> not repeated start
                                // [2] = 0 -> Stop
                                // [3] = 0 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'd64)  // Length = 'd64


    repeat(100) @(posedge clk_i);
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    wdata_mem_start = (wdata_mem_end == 255) ? 8'h0 : wdata_mem_end + 1;
  end
endtask // send_hdr_ddr_write_read

task send_ccc_broadcast_entdaa;
  begin
    testname        = "CCC_B_ENTDAA";
    dyn_addr = DYN_ADDR;

    $display("%12d: ==== SEND BROADCAST ENTDAA", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // CCC Code - ENTDAA CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,~^dyn_addr})  // {Dynamic Address assigned to target,Parity bit}
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    repeat(1000) @(posedge clk_i);
    chk_assigned_da(0);
  end
endtask // send_ccc_broadcast_entdaa

task send_ccc_broadcast_setaasa;
  begin
    testname        = "CCC_B_SETAASA";
    if (STATIC_ADDR_EN) begin
      $display("%12d: ==== SEND BROADCAST SETAASA", $stime);
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                  // [0] = 1 -> CCC1_PRIV0
                                  // [1] = 0 -> repeated start
                                  // [2] = 1 -> Stop
                                  // [3] = 1 -> CCC_start
                                  // [7:4] = 0 -> rsvd
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // {7b target current address, W}
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h29)

      `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

      dyn_addr = stat_addr;
      chk_assigned_da(0);

      i3c_test(8'h0F);
      end
    else begin
      $display("%12d: ==== [SETAASA] Device does not have Static Address!", $stime);
    end
  end
endtask // send_ccc_broadcast_setaasa

task send_ccc_direct_setdasa;
  input   [6:0]   stat_addr;
  begin
    testname        = "CCC_D_SETDASA";
    if (STATIC_ADDR_EN) begin
      $display("%12d: ==== SEND DIRECT SETDASA", $stime);
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                  // [0] = 1 -> CCC1_PRIV0
                                  // [1] = 0 -> repeated start
                                  // [2] = 0 -> Stop
                                  // [3] = 1 -> CCC_start
                                  // [7:4] = 0 -> rsvd
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // {7b target current address, W}
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h87)

      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                  // [0] = 1 -> CCC1_PRIV0
                                  // [1] = 1 -> repeated start
                                  // [2] = 1 -> Stop
                                  // [3] = 0 -> CCC_start
                                  // [7:4] = 0 -> rsvd
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {stat_addr,1'b0})
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {stat_addr,1'b0})

      `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

      dyn_addr = stat_addr;
      chk_assigned_da(0);
    end
    else begin
      $display("%12d: ==== [SETDASA] Device does not have Static Address!", $stime);
      send_ccc_broadcast_entdaa;
    end
  end
endtask // send_ccc_direct_setdasa

task send_ccc_direct_setnewda;
  input   [6:0]   new_tgt_da;
  begin
    testname        = "CCC_D_SETNEWDA";

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // {7b target current address, W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h88)

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {new_tgt_da,1'b0})

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    dyn_addr = new_tgt_da;
    chk_assigned_da(0);
  end
endtask // send_ccc_direct_setnewda

task send_ccc_broadcast_rstdaa;
  begin
    testname        = "CCC_B_RSTDAA";

    $display("%12d: ==== SEND BROADCAST RSTDAA", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h06)  // CCC Code - RSTDAA CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    dyn_addr = 8'h0; // reset daa

    chk_assigned_da(1);
  end
endtask // send_ccc_broadcast_rstdaa

task chk_assigned_da;
  input           rstdaa;
  reg   [7:0]     assigned_da;
  reg   [7:0]     tgt_int_status3;

  begin
    repeat(200) @(posedge clk_i);
    `TGT_BFM_MEMW(8'h36, 8'hFF) // clear int status
    `TGT_BFM_MEMW(`TGT_ADR_STAT3_INT_EN, 8'hFB) // Enable bus_idle interrupt
    // clear interrupt status

    `TGT_BFM_MEMR(8'h36, 8'h00, 0, tgt_int_status3)  // get int status
    $display("%12d: [DEBUG] tgt_int_status3 = %0h",$stime,tgt_int_status3);

    wait(tgt_int_o);
    while (~tgt_int_status3[1]) begin
      `TGT_BFM_MEMR(8'h36, 8'h00, 0, tgt_int_status3)  // get int status
      $display("%12d: [DEBUG] tgt_int_status3 = %0h",$stime,tgt_int_status3);
    end

    wait(tgt_int_status3[1]);
    if(tgt_int_status3[1]) begin
      `TGT_BFM_MEMR(8'h02, {~rstdaa, dyn_addr}, 0, assigned_da)
      $display("%12d: [DEBUG] Dynamic Address set to %0h",$stime,assigned_da);
        if ({~rstdaa, dyn_addr} != assigned_da) begin
          da_err_cnt = da_err_cnt + 1;
          $display("%12d: [ERROR] Dynamic Address set to %0h (actual) vs %0h (expected)",$stime,assigned_da,{~rstdaa, dyn_addr});
        end

      // clear interrupt status
      `TGT_BFM_MEMW(8'h36, (tgt_int_status3 & 8'hFF)) // clear int status
    end

    `TGT_BFM_MEMW(`TGT_ADR_STAT3_INT_EN, 8'hF8) // Disable bus_idle interrupt
  end
endtask

task send_ccc_entasx;
  input           broadcast;
  input  [2:0]    ccc_code;
  input  [6:0]    tgt_addr;
  begin
    if(broadcast)
      $display("%12d: ==== SEND BROADCAST ENTAS %0d ", $stime,ccc_code);
    else
      $display("%12d: ==== SEND DIRECT ENTAS %0d ", $stime,ccc_code);

      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'd1,broadcast,2'd1})  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 0 -> not repeated start
                                   // [2] = 0 -> Stop
                                   // [3] = 1 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {~broadcast,4'd0,ccc_code})  // CCC Code - ENTASx CCC

    if(~broadcast) begin // direct
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'd0,1'b1,2'd3})  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 1 -> repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 0 -> not CCC_start
                                   // [7:4] = 0 -> rsvd
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {tgt_addr,1'b0})  // {7b target DA,W}
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // Length = 0x0
    end
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    target_isr_generic;
    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_entasx

task send_ccc_broadcast_entasx;
  input  [2:0]    ccc_code;
  begin
    testname        = "CCC_B_ENTAS";
    send_ccc_entasx(1'b1,ccc_code,7'd0);
  end
endtask // send_ccc_broadcast_entasx

task send_ccc_direct_entasx;
  input  [2:0]    ccc_code;
  input  [6:0]    tgt_addr;
  begin
    testname        = "CCC_D_ENTAS";
    send_ccc_entasx(1'b0,ccc_code,tgt_addr);
    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_entasx

task send_ccc_getmxds;
  input         defbyte;
  input [7:0]   getmxds_defbyte;
  begin
    testname        = "CCC_D_GETMXDS";

    $display("%12d: ==== Write to MXDS registers", $stime);
    `TGT_BFM_MEMW(8'h0C, 8'hF1) // maxWr
    `TGT_BFM_MEMW(8'h0D, 8'hC9) // maxRd
    `TGT_BFM_MEMW(8'h0E, 8'h11) // MaxRdTurn
    `TGT_BFM_MEMW(8'h0F, 8'h22) // MaxRdTurn
    `TGT_BFM_MEMW(8'h10, 8'h89) // MaxRdTurn
    `TGT_BFM_MEMW(8'h43, 8'h06) // CRHDLY

    $display("%12d: ==== SEND DIRECT GETMXDS", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}

    if(defbyte) begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x1
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h94)  // CCC Code - GETMXDS CCC
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, getmxds_defbyte)  // CCC Code - GETMXDS CCC

      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 1 -> repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 0 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}

      if (getmxds_defbyte == 8'h91) begin
        `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
      end
      else begin
        `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h05)  // Length = 0x5
      end
      `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
    end
    else begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h94)  // CCC Code - GETMXDS CCC

      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 1 -> repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 0 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h05)  // Length = 0x5

      `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
    end
    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_getmxds

task send_ccc_broadcast_disec;
  input   disable_hotjoin;
  input   disable_ibi;

  begin
    testname        = "CCC_B_DISEC";

    $display("%12d: ==== SEND BROADCAST DISEC", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // CCC Code - DISEC CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {4'h0, disable_hotjoin, 2'h0, disable_ibi})
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
    repeat(200) @(posedge clk_i);

    target_isr_generic;
  end
endtask // send_ccc_broadcast_disec

task send_ccc_direct_disec;
  input   disable_hotjoin;
  input   disable_ibi;

  begin
    testname        = "CCC_D_DISEC";

    $display("%12d: ==== SEND DIRECT DISEC", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h81)  // CCC Code - DISEC CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {4'h0, disable_hotjoin, 2'h0, disable_ibi})

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
    repeat(200) @(posedge clk_i);

    target_isr_generic;
  end
endtask // send_ccc_direct_disec

task send_ccc_broadcast_enec;
  input   enable_hotjoin;
  input   enable_cr_req;
  input   enable_ibi;

  begin
    testname        = "CCC_B_ENEC";

    $display("%12d: ==== SEND BROADCAST ENEC", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // CCC Code - ENEC CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {4'h0, enable_hotjoin, 1'h0, enable_cr_req, enable_ibi})

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
    repeat(200) @(posedge clk_i);

    target_isr_generic;
  end
endtask // send_ccc_broadcast_enec

task send_ccc_direct_enec;
  input   enable_hotjoin;
  input   enable_cr_req;
  input   enable_ibi;

  begin
    testname        = "CCC_D_ENEC";

    $display("%12d: ==== SEND DIRECT ENEC", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h80)  // CCC Code - ENEC CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {4'h0, ~enable_hotjoin, 1'h0, ~enable_cr_req, ~enable_ibi})


    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {4'h0, enable_hotjoin, 1'h0, enable_cr_req, enable_ibi})

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
    repeat(200) @(posedge clk_i);

    target_isr_generic;

    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_enec

task send_ccc_direct_getmwl;
  begin
    testname        = "CCC_D_GETMWL";

    $display("%12d: ==== SEND DIRECT GETMWL", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // CCC Code - GETMWL CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_getmwl

task send_ccc_direct_setmwl;
  input [7:0]   setmwl_msb;
  input [7:0]   setmwl_lsb;

  begin
    testname        = "CCC_D_SETMWL";

    $display("%12d: ==== SEND DIRECT SETMWL", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h89)  // CCC Code - SETMWL CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmwl_msb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmwl_lsb)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
     repeat(200) @(posedge clk_i);

    // Check csr
    `TGT_BFM_MEMR(8'h07, setmwl_msb, 1'b1, csr_rdata_act)
    $display("%12d: [DEBUG] setmwl_msb = %0h",$stime,setmwl_msb);
    if (setmwl_msb != csr_rdata_act) begin
      data_err_cnt = data_err_cnt + 1;
    end

    `TGT_BFM_MEMR(8'h08, setmwl_lsb, 1'b1, csr_rdata_act)
    $display("%12d: [DEBUG] setmwl_lsb = %0h",$stime,setmwl_lsb);
    if (setmwl_lsb != csr_rdata_act) begin
      data_err_cnt = data_err_cnt + 1;
    end
  end
endtask // send_ccc_direct_setmwl

task send_ccc_broadcast_setmwl;
  input [7:0]   b_setmwl_msb;
  input [7:0]   b_setmwl_lsb;

  begin
    testname        = "CCC_B_SETMWL";

    $display("%12d: ==== SEND BROADCAST SETMWL", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Length = 0x3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // CCC Code - SETMWL CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, b_setmwl_msb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, b_setmwl_lsb)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
     repeat(200) @(posedge clk_i);

    // Check csr
    `TGT_BFM_MEMR(8'h07, b_setmwl_msb, 1'b1, csr_rdata_act)
    $display("%12d: [DEBUG] setmwl_msb = %0h",$stime,b_setmwl_msb);
    if (b_setmwl_msb != csr_rdata_act) begin
      data_err_cnt = data_err_cnt + 1;
    end

    `TGT_BFM_MEMR(8'h08, b_setmwl_lsb, 1'b1, csr_rdata_act)
    $display("%12d: [DEBUG] setmwl_lsb = %0h",$stime,b_setmwl_lsb);
    if (b_setmwl_lsb != csr_rdata_act) begin
      data_err_cnt = data_err_cnt + 1;
    end
  end
endtask // send_ccc_broadcast_setmwl

task send_ccc_direct_getmrl;
  input   ibi_payload;
  begin
    testname        = "CCC_D_GETMRL";

    $display("%12d: ==== SEND DIRECT GETMRL", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8C)  // CCC Code - GETMRL CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}

    if (ibi_payload) begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Length = 0x2
    end
    else begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    end
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_getmrl

task send_ccc_direct_setmrl;
  input [7:0]   setmrl_msb;
  input [7:0]   setmrl_lsb;

  begin
    testname        = "CCC_D_GETMRL";

    $display("%12d: ==== SEND DIRECT SETMRL", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8A)  // CCC Code - SETMRL CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmrl_msb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmrl_lsb)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_setmrl

task send_ccc_broadcast_setmrl;
  input [7:0]   b_setmrl_msb;
  input [7:0]   b_setmrl_lsb;

  begin
    testname        = "CCC_B_SETMRL";

    $display("%12d: ==== SEND BROADCAST SETMRL", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Length = 0x3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0A)  // CCC Code - SETMRL CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, b_setmrl_msb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, b_setmrl_lsb)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_broadcast_setmrl

task send_ccc_direct_getpid;
  begin
    testname        = "CCC_D_GETPID";

    $display("%12d: ==== SEND DIRECT GETPID", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // CCC Code - GETPID CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h06)  // Length = 0x6
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_getpid

task send_ccc_direct_getbcr;
  begin
    testname        = "CCC_D_GETBCR";

    $display("%12d: ==== SEND DIRECT GETBCR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8E)  // CCC Code - GETBCR CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_getbcr

task send_ccc_direct_getdcr;
  begin
    testname        = "CCC_D_GETDCR";

    $display("%12d: ==== SEND DIRECT GETDCR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8F)  // CCC Code - GETDCR CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_getdcr

task send_ccc_direct_getstatus;
  input       defbyte;
  input [7:0] getstatus_defbyte;

  begin
    testname        = "CCC_D_GETSTATUS";

    $display("%12d: ==== Write to GETSTATUS registers", $stime);
    `TGT_BFM_MEMW(8'h2A, 8'hA5) // MSB
    `TGT_BFM_MEMW(8'h2B, 8'h87) // LSB

    $display("%12d: ==== SEND DIRECT GETSTATUS", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}

    if (defbyte) begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h90)  // CCC Code - GETSTATUS CCC
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, getstatus_defbyte)  // Defining Byte - GETSTATUS CCC
    end
    else begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h90)  // CCC Code - GETSTATUS CCC
    end

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_getstatus

task send_ccc_direct_getcaps;
  input         defbyte;
  input [7:0]   getcaps_defbyte;
  begin
    testname        = "CCC_D_GETCAPS";

    $display("%12d: ==== SEND DIRECT GETCAPS", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}

    if (defbyte) begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h95)  // CCC Code - GETCAPS CCC
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, getcaps_defbyte)  // Defining Byte - GETCAPS CCC
    end
    else begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h95)  // CCC Code - GETCAPS CCC
    end

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)  // Length = 0x4
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_getcaps

task send_ccc_broadcast_deftgts;
  reg   [7:0] deftgts_rdata;
  integer     data_cntr;

  begin
    testname        = "CCC_B_DEFTGTS";

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // {7b target current address, W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0E)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h08)  // CCC Code - DEFTGTS
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h08)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h05)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0A)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h06)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h08)

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'hA5)  //
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    repeat(500) @ (posedge clk_i);
    for (data_cntr = 0 ; data_cntr < 8'hF ; data_cntr = data_cntr + 1) begin
      `TGT_BFM_MEMR(8'h41, 8'h00, 0, deftgts_rdata)  // get int status
      $display("%12d: [DEBUG] deftgts_rxfifo_start = %0h",$stime,deftgts_rdata);
    end

    repeat(500) @ (posedge clk_i);

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0F)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // {7b target current address, W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0E)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h08)  // CCC Code - DEFTGTS
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h08)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h05)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0A)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h06)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h08)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    repeat(500) @ (posedge clk_i);
    for (data_cntr = 0 ; data_cntr < 8'hC ; data_cntr = data_cntr + 1) begin
      `TGT_BFM_MEMR(8'h41, 8'h00, 0, deftgts_rdata)  // read deftgts_rxfifo_start
      $display("%12d: [DEBUG] deftgts_rxfifo_start = %0h",$stime,deftgts_rdata);
      `TGT_BFM_MEMR(8'h42, 8'h00, 0, deftgts_rdata)  // read deftgts_rxfifo_count
      $display("%12d: [DEBUG] deftgts_rxfifo_count = %0h",$stime,deftgts_rdata);
      `TGT_BFM_MEMR(`TGT_ADR_RX_FIFO, 8'h00, 0, deftgts_rdata)  // read rxfifo
      $display("%12d: [DEBUG] deftgts_rdata = %0h",$stime,deftgts_rdata);
    end

    for (data_cntr = 0 ; data_cntr < 8'hC ; data_cntr = data_cntr + 1) begin
      `TGT_BFM_MEMR(8'h41, 8'h00, 0, deftgts_rdata)  // read deftgts_rxfifo_start
      $display("%12d: [DEBUG] deftgts_rxfifo_start = %0h",$stime,deftgts_rdata);
      `TGT_BFM_MEMR(8'h42, 8'h00, 0, deftgts_rdata)  // read deftgts_rxfifo_count
      $display("%12d: [DEBUG] deftgts_rxfifo_count = %0h",$stime,deftgts_rdata);
      `TGT_BFM_MEMR(`TGT_ADR_RX_FIFO, 8'h00, 0, deftgts_rdata)  // read rxfifo
      $display("%12d: [DEBUG] deftgts_rdata = %0h",$stime,deftgts_rdata);
    end

  end
endtask // send_ccc_broadcast_deftgts

task send_ccc_direct_getacccr;
  input     getacccr_ack_nack;

  begin
    testname        = "CCC_D_GETACCCR";

    $display("%12d: ==== Set Target GETACCCR Auto-response", $stime);
    `TGT_BFM_MEMW(8'h43, {getacccr_ack_nack, 7'h0})

    $display("%12d: ==== SEND DIRECT GETACCCR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h91)  // CCC Code - GETACCCR CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
     repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_getacccr

task send_ccc_direct_rstact;
  input   [7:0]   rstact;
  input           direct_set1_get0;
  reg     [7:0]   tgt_int_status3;
  begin
    testname        = "CCC_D_RSTACT";

    $display("%12d: ==== SEND DIRECT RSTACT", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h9A)  // CCC Code - RSTACT CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, rstact) //

    if (direct_set1_get0) begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 1 -> repeated start
                                   // [2] = 1 -> Stop
                                   // [3] = 0 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address  - {dyn_addr, R}
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // Length = 0x0

      `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
       repeat(200) @(posedge clk_i);

      if ((rstact == 8'h0) | (rstact == 8'h1) | (rstact == 8'h2)) begin
        wait (tgt_int_o);
        while (tgt_int_o) begin
        // read interrupt status
        `TGT_BFM_MEMR(8'h36, 8'h00, 0, tgt_int_status3)  // get int status
        $display("%12d: [DEBUG] tgt_int_status3 = %0h",$stime,tgt_int_status3);

        if (tgt_int_status3[5]) begin
          `TGT_BFM_MEMR(8'h2D, rstact, 1'b1, csr_rdata_act)
          if (rstact != csr_rdata_act) begin
            data_err_cnt = data_err_cnt + 1;
          end
        end

        // clear interrupt status
        `TGT_BFM_MEMW(8'h36, tgt_int_status3)
        end
      end
    end
    else begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Control
                                   // [0] = 1 -> CCC1_PRIV0
                                   // [1] = 1 -> repeated start
                                   // [2] = 0 -> Stop
                                   // [3] = 0 -> CCC_start
                                   // [7:4] = 0 -> rsvd
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1

      `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
      repeat(200) @(posedge clk_i);

      // clear interrupt status
      `TGT_BFM_MEMW(8'h36, 8'hFF)
    end
    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_rstact

task send_ccc_broadcast_rstact;
  input   [7:0]   rstact;
  reg     [7:0]   tgt_int_status3;
  begin
    testname        = "CCC_B_RSTACT";

    $display("%12d: ==== SEND BROADCAST RSTACT", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h2A)  // CCC Code - RSTACT CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, rstact) // Defining byte - RSTACT CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
     repeat(200) @(posedge clk_i);

    if ((rstact == 8'h0) | (rstact == 8'h1) | (rstact == 8'h2)) begin
      wait (tgt_int_o);
      while (tgt_int_o) begin
      // read interrupt status
      `TGT_BFM_MEMR(8'h36, 8'h00, 0, tgt_int_status3)  // get int status
      $display("%12d: [DEBUG] tgt_int_status3 = %0h",$stime,tgt_int_status3);

      if (tgt_int_status3[5]) begin
        `TGT_BFM_MEMR(8'h2D, rstact, 1'b1, csr_rdata_act)
        if (rstact != csr_rdata_act) begin
          data_err_cnt = data_err_cnt + 1;
        end
      end

      // clear interrupt status
      `TGT_BFM_MEMW(8'h36, tgt_int_status3)
      end
    end
  end
endtask // send_ccc_broadcast_rstact

task send_ccc_broadcast_enthdr;
  input   [2:0]   hdr_mode;
  begin
    testname        = "CCC_B_ENTHDR";

    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, hdr_mode})  // CCC Code - ENTHDRx CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_ccc_broadcast_enthdr

task send_ccc_broadcast_setxtime;
  input   [7:0]   setxtime_subcmd_byte;
  begin
    testname        = "CCC_B_SETXTIME";

    $display("%12d: ==== SEND BROADCAST SETXTIME", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h28)  // CCC Code - SETXTIME CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setxtime_subcmd_byte)  // SETXTIME Defining Byte
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_broadcast_setxtime

task send_ccc_direct_setxtime;
  input   [7:0]   setxtime_subcmd_byte;
  begin
    testname        = "CCC_D_SETXTIME";

    $display("%12d: ==== SEND DIRECT SETXTIME", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h98)  // CCC Code - SETXTIME CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setxtime_subcmd_byte)  // SETXTIME Defining Byte
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_setxtime

task send_ccc_direct_getxtime;
  begin
    testname        = "CCC_D_GETXTIME";

    $display("%12d: ==== SEND DIRECT GETXTIME", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h99)  // CCC Code - SETXTIME CCC

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_setxtime

task send_ccc_broadcast_endxfer;
  input   [7:0]   endxfer_defining_byte;
  input   [7:0]   endxfer_data;
  begin
    testname        = "CCC_B_ENDXFER";

    $display("%12d: ==== SEND BROADCAST ENDXFER", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Length = 0x3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h12)  // CCC Code - ENDXFER CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, endxfer_defining_byte)  // ENDXFER Defining Byte
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, endxfer_data)  // ENDXFER Defining Byte

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start

    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_broadcast_endxfer

task send_ccc_direct_endxfer;
  input           direct_set0_get1;
  input   [7:0]   endxfer_defining_byte;
  input   [7:0]   endxfer_data;
  begin
    testname        = "CCC_D_ENDXFER";

    $display("%12d: ==== SEND DIRECT ENDXFER", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h92)  // CCC Code - ENDXFER CCC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, endxfer_defining_byte)  // ENDXFER Defining Byte

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h07)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [7:4] = 0 -> rsvd

    if (direct_set0_get1) begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address  - {dyn_addr, R}
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    end
    else begin
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address  - {dyn_addr, R}
      `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, endxfer_data)  // ENDXFER Data
    end

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
    repeat(200) @(posedge clk_i);
  end
endtask // send_ccc_direct_setxtime

task send_hdr_ddr_ccc_broadcast_enec;
  input   enable_hotjoin;
  input   enable_cr_req;
  input   enable_ibi;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> not repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND BROADCAST ENEC", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> repeated start
                                // [2] = 1 -> Stop
                                // [3] = 1 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)  // Length = 0x3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // CCC Code - ENEC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // CCC Optional Defining Byte
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {4'h0, enable_hotjoin, 1'h0, enable_cr_req, enable_ibi})

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_broadcast_enec

task send_hdr_ddr_ccc_direct_enec;
  input   enable_hotjoin;
  input   enable_cr_req;
  input   enable_ibi;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> not repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT ENEC", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h89)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h80)  // CCC Code - ENEC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // CCC Optional Defining Byte

    $display("%12d: ==== SEND DIRECT ENEC Data", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> repeated start
                                // [2] = 1 -> Stop
                                // [3] = 1 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {4'h0, enable_hotjoin, 1'h0, enable_cr_req, enable_ibi})

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_enec

task send_hdr_ddr_ccc_broadcast_disec;
  input   disable_hotjoin;
  input   disable_cr_req;
  input   disable_ibi;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> not repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND BROADCAST DISEC", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> repeated start
                                // [2] = 1 -> Stop
                                // [3] = 1 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)  // Length = 0x3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // CCC Code - DISEC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // CCC Optional Defining Byte
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {4'h0, disable_hotjoin, 1'h0, disable_cr_req, disable_ibi})

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_broadcast_disec

task send_hdr_ddr_ccc_direct_disec;
  input   disable_hotjoin;
  input   disable_cr_req;
  input   disable_ibi;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> not repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT DISEC", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h89)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h81)  // CCC Code - DISEC
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // CCC Optional Defining Byte

    $display("%12d: ==== SEND DIRECT DISEC Data", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> repeated start
                                // [2] = 1 -> Stop
                                // [3] = 1 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {4'h0, disable_hotjoin, 1'h0, disable_cr_req, disable_ibi})

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_disec

task send_hdr_ddr_ccc_broadcast_entas;
  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND BROADCAST ENTAS0", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // CCC Code - ENTAS0

    $display("%12d: ==== SEND BROADCAST ENTAS1", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // CCC Code - ENTAS1

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_broadcast_entas

task send_hdr_ddr_ccc_direct_entas;
  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT ENTAS0", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h89)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h82)  // CCC Code - ENTAS0

    $display("%12d: ==== SEND DIRECT ENTAS0 Data", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)  // CCC Code - Reserved

    $display("%12d: ==== SEND DIRECT ENTAS3", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h85)  // CCC Code - ENTAS0

    $display("%12d: ==== SEND DIRECT ENTAS3 Data", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h11)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h22)  // CCC Code - Reserved


    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_entas

task send_hdr_ddr_ccc_broadcast_setmwl;
  input [6:0]   hdr_ddr_cmd_code;
  input [7:0]   setmwl_msb;
  input [7:0]   setmwl_lsb;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND BROADCAST SETMWL", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h05)             // Length = 0x5
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h09)             // CCC Code - SETMWL
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)             // Defining byte - 0x0 (unused)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmwl_msb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmwl_lsb)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_broadcast_setmwl


task send_hdr_ddr_ccc_direct_setmwl;
  input [6:0]   hdr_ddr_cmd_code;
  input [7:0]   setmwl_msb;
  input [7:0]   setmwl_lsb;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT SETMWL (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)             // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h89)             // CCC Code - SETMWL

    $display("%12d: ==== SEND DIRECT SETMWL (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmwl_msb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmwl_lsb)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_setmwl

task send_hdr_ddr_ccc_direct_getmwl;
  input [6:0]   hdr_ddr_cmd_code;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT SETMWL (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)             // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)             // CCC Code - SETMWL

    $display("%12d: ==== SEND DIRECT GETMWL (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b1, hdr_ddr_cmd_code})

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_getmwl

task send_hdr_ddr_ccc_broadcast_setmrl;
  input [6:0]   hdr_ddr_cmd_code;
  input [7:0]   setmrl_msb;
  input [7:0]   setmrl_lsb;
  input [7:0]   setmrl_ibi;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND BROADCAST SETMRL", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h06)             // Length = 0x5
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0A)             // CCC Code - SETMRL
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)             // Defining byte - 0x0 (unused)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmrl_msb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmrl_lsb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmrl_ibi)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_broadcast_setmrl

task send_hdr_ddr_ccc_direct_setmrl;
  input [6:0]   hdr_ddr_cmd_code;
  input [7:0]   setmrl_msb;
  input [7:0]   setmrl_lsb;
  input [7:0]   setmrl_ibi;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT SETMRL (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)             // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8A)             // CCC Code - SETMRL

    $display("%12d: ==== SEND DIRECT SETMRL (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmrl_msb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmrl_lsb)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setmrl_ibi)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_setmrl

task send_hdr_ddr_ccc_direct_getmrl;
  input [6:0]   hdr_ddr_cmd_code;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT SETMRL (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)             // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8C)             // CCC Code - GETMRL

    $display("%12d: ==== SEND DIRECT GETMRL (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b1, hdr_ddr_cmd_code})

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)  // Length = 0x2

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_getmrl

task send_hdr_ddr_ccc_direct_getbcr;
  input [6:0]   hdr_ddr_cmd_code;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT SETBCR (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)             // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8E)             // CCC Code - GETBCR

    $display("%12d: ==== SEND DIRECT GETBCR (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b1, hdr_ddr_cmd_code})

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_getbcr

task send_hdr_ddr_ccc_direct_getdcr;
  input [6:0]   hdr_ddr_cmd_code;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT SETDCR (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)             // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8F)             // CCC Code - GETDCR

    $display("%12d: ==== SEND DIRECT GETDCR (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b1, hdr_ddr_cmd_code})

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_getdcr

task send_hdr_ddr_ccc_direct_getstatus;
  input [6:0]   hdr_ddr_cmd_code;
  input [7:0]   ccc_defbyte;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT GETSTATUS (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)             // Length = 0x2=3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h90)             // CCC Code - GETSTATUS
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, ccc_defbyte)       // CCC Defining Byte

    $display("%12d: ==== SEND DIRECT GETSTATUS (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b1, hdr_ddr_cmd_code})

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_getstatus

task send_hdr_ddr_ccc_broadcast_setxtime;
  input [6:0]   hdr_ddr_cmd_code;
  input [7:0]   setxtime_subbyte;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND BROADCAST SETXTIME", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)             // Length = 0x4
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h28)             // CCC Code - SETXTIME
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h00)             // Defining byte - 0x0 (unused)
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setxtime_subbyte)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_broadcast_setxtime

task send_hdr_ddr_ccc_direct_setxtime;
  input [6:0]   hdr_ddr_cmd_code;
  input [7:0]   setxtime_subbyte;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT SETXTIME (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)             // Length = 0x2=3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h98)             // CCC Code - SETXTIME

    $display("%12d: ==== SEND DIRECT SETXTIME (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x2
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, setxtime_subbyte)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_setxtime

task send_hdr_ddr_ccc_direct_getxtime;
  input [6:0]   hdr_ddr_cmd_code;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT GETXTIME (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)             // Length = 0x2=3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h99)             // CCC Code - GETXTIME

    $display("%12d: ==== SEND DIRECT GETXTIME (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b1, hdr_ddr_cmd_code})

    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b1})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)  // Length = 0x2

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_getxtime

task send_hdr_ddr_ccc_broadcast_endxfer;
  input [7:0]   ccc_defbyte;
  input [3:0]   endxfer_data;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> not repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND BROADCAST ENDXFER", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h89)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> repeated start
                                // [2] = 0 -> Stop
                                // [3] = 1 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)  // Length = 0x4
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h12)  // CCC Code - ENDXFER
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, ccc_defbyte)  // CCC Optional Defining Byte
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {endxfer_data ,4'h0})

    $display("%12d: ==== SEND BROADCAST ENDXFER", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8D)  // Control
                                // [0] = 1 -> CCC1_PRIV0
                                // [1] = 0 -> repeated start
                                // [2] = 1 -> Stop
                                // [3] = 1 -> CCC_start
                                // [6:4] = 0 -> rsvd
                                // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h04)  // Length = 0x4
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h7F)  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h12)  // CCC Code - ENDXFER
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'hAA)  // CCC Optional Defining Byte
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'hAA)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_broadcast_endxfer

task send_hdr_ddr_ccc_direct_endxfer;
  input [7:0]   ccc_defbyte;
  input [3:0]   endxfer_data;
  input [6:0]   hdr_ddr_cmd_code;

  begin
    $display("%12d: ==== SEND BROADCAST ENTHDR", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h0D)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> not repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [7:4] = 0 -> rsvd
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})  // Address  - {7'h7E,W}
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h01)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {5'h04, 3'h0})  // CCC Code - ENTHDRx CCC

    $display("%12d: ==== SEND DIRECT ENDXFER (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)             // Length = 0x2=3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h92)             // CCC Code - ENDXFER
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, ccc_defbyte)       // CCC Defining Byte

    $display("%12d: ==== SEND DIRECT ENDXFER (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h8B)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 1 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {endxfer_data, 4'h0})

    $display("%12d: ==== SEND DIRECT ENDXFER (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h83)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)             // Length = 0x2=3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h92)             // CCC Code - ENDXFER
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'hAA)       // CCC Defining Byte

    $display("%12d: ==== SEND DIRECT ENDXFER (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h83)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h55)


    $display("%12d: ==== SEND DIRECT ENDXFER (COMMAND)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h83)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 1 -> repeated start
                                 // [2] = 0 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {7'h7E,1'b0})      // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h03)             // Length = 0x2=3
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})  // CCC Code - Reserved
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h92)             // CCC Code - ENDXFER
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'hAA)       // CCC Defining Byte

    $display("%12d: ==== SEND DIRECT ENDXFER (DATA)", $stime);
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h85)  // Control
                                 // [0] = 1 -> CCC1_PRIV0
                                 // [1] = 0 -> repeated start
                                 // [2] = 1 -> Stop
                                 // [3] = 0 -> CCC_start
                                 // [6:4] = 0 -> rsvd
                                 // [7] = 1 -> HDR Mode
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {dyn_addr,1'b0})  // Address
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'h02)  // Length = 0x1
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, {1'b0, hdr_ddr_cmd_code})
    `CTL_BFM_MEMW(`CTL_ADR_TXFIFO, 8'hAA)

    `CTL_BFM_MEMW(`CTL_ADR_TXSTART, 8'h01)  // start
  end
endtask // send_hdr_ddr_ccc_direct_endxfer

task i3c_test;
  input [7:0]   length;
  reg   [7:0]   rxfifo_rdata;
  reg   [7:0]   tgt_int_status2;
  integer       data_cntr;

  reg    [7:0]    ctl_rdata;


  begin
    testname = "I3C Test";

    target_isr_generic;
    wdata_mem_index = wdata_mem_start;

    if (wdata_mem_start + length > 255) begin
      wdata_mem_end = wdata_mem_start + length - 255;
    end
    else begin
      wdata_mem_end = wdata_mem_start + length;
    end

    $display("%12d: ==== Write data to Target Tx FIFO", $stime);
    for (data_cntr = 0; data_cntr < (length); data_cntr = data_cntr + 1) begin
      `TGT_BFM_MEMW(`TGT_ADR_TX_FIFO, wdata_mem[wdata_mem_index])
      if (wdata_mem_index == 255) begin
        wdata_mem_index = 0 ;
      end
      else begin
        wdata_mem_index = wdata_mem_index + 1;
      end
    end

    send_private_read(dyn_addr + 1
                      ,length
                      ,1'b0
                      ,1'b0
                      ,1'b0
                      ,1'b0);

    send_private_read(dyn_addr
                      ,length
                      ,1'b1
                      ,1'b1
                      ,1'b0
                      ,1'b0);

    repeat(length*50) @(posedge clk_i);

    send_private_write(dyn_addr
                      ,32
                      ,wdata_mem_start
                      ,1'b0
                      ,1'b1
                      ,1'b0
                      ,1'b0);

    repeat(542*30) @(posedge clk_i);

    wdata_mem_index = wdata_mem_start;
    wait (tgt_int_o);
    while (tgt_int_o) begin
      // read interrupt status
      `TGT_BFM_MEMR(`TGT_ADR_STAT2_INT, 8'h00, 0, tgt_int_status2)  // get int status
      $display("%12d: [DEBUG] tgt_int_status2 = %0h",$stime,tgt_int_status2);

      if (tgt_int_status2[6]) begin
        `TGT_BFM_MEMR(`TGT_ADR_RX_FIFO, wdata_mem[wdata_mem_index], 1'b1, rxfifo_rdata)  // get rxfifo data
        if (wdata_mem[wdata_mem_index] != rxfifo_rdata) begin
          data_err_cnt = data_err_cnt + 1;
        end
        wdata_mem_index = wdata_mem_index + 1;
      end

      // clear interrupt status
      `TGT_BFM_MEMW(`TGT_ADR_STAT2_INT, (tgt_int_status2 & 8'hFF)) // clear int status
    end

    wdata_mem_start = (wdata_mem_end == 255) ? 8'h0 : wdata_mem_end + 1;

    repeat(length*30) @(posedge clk_i);

        // Read from Controller TxFIFO
    wait (ctl_int_o);
    while (ctl_int_o) begin
      // read interrupt status
      `CTL_BFM_MEMR(`CTL_ADR_INTSTAT0, 8'h00, 0, ctl_rdata)  // get int status
      $display("%12d: [DEBUG] ctl_int_status2 = %0h",$stime,ctl_rdata);

      if (ctl_rdata[1]) begin
        `CTL_BFM_MEMR(`CTL_ADR_RXFIFO, 8'h00, 0, ctl_rdata)
      end

      // clear interrupt status
      `CTL_BFM_MEMW(`CTL_ADR_INTSTAT0, 8'hFF)
      `CTL_BFM_MEMW(`CTL_ADR_INTSTAT1, 8'hFF)
    end

  end
endtask // i3c_test

task i2c_test;
  input [7:0]   length;
  reg   [7:0]   rdata;
  reg   [7:0]   rxfifo_rdata;
  reg   [7:0]   tgt_int_status2;
  integer       data_cntr;

  begin
    if (STATIC_ADDR_EN) begin
      target_isr_generic;

      $display("%12d: ==== I2C Test", $stime);
      testname = "I2C Test";

      // allow I2C frames
      `CTL_BFM_MEMR(`CTL_ADR_MSTCFG0, 8'h00, 0, rdata)  // read config register
      `CTL_BFM_MEMW(`CTL_ADR_MSTCFG0, (rdata | 8'h08))  // modify then write config

      testname = "Tx FIFO Empty I2C Read Test";
      send_private_read(stat_addr
                        ,length
                        ,1'b0
                        ,1'b1
                        ,1'b0
                        ,1'b1);

      repeat(length*30) @(posedge clk_i);

      wdata_mem_index = wdata_mem_start;

      if (wdata_mem_start + length > 255) begin
        wdata_mem_end = wdata_mem_start + length - 255;
      end
      else begin
        wdata_mem_end = wdata_mem_start + length;
      end

      $display("%12d: ==== Write data to Target Tx FIFO", $stime);
      for (data_cntr = 0; data_cntr < length; data_cntr = data_cntr + 1) begin
        `TGT_BFM_MEMW(`TGT_ADR_TX_FIFO, wdata_mem[wdata_mem_index])
        if (wdata_mem_index == 255) begin
          wdata_mem_index = 0 ;
        end
        else begin
          wdata_mem_index = wdata_mem_index + 1;
        end
      end

      testname = "I2C Read Test";
      send_private_read(stat_addr
                        ,length
                        ,1'b0
                        ,1'b1
                        ,1'b0
                        ,1'b1);

      repeat(length*30) @(posedge clk_i);

      testname = "I2C Write Test";
      send_private_write(stat_addr
                        ,length
                        ,wdata_mem_start
                        ,1'b0
                        ,1'b1
                        ,1'b0
                        ,1'b1);

      repeat(length*30) @(posedge clk_i);

      wdata_mem_index = wdata_mem_start;
      wait (tgt_int_o);
      while (tgt_int_o) begin
      testname = "Read from RxFIFO ";
        // read interrupt status
        `TGT_BFM_MEMR(`TGT_ADR_STAT2_INT, 8'h00, 0, tgt_int_status2)  // get int status
        $display("%12d: [DEBUG] tgt_int_status2 = %0h",$stime,tgt_int_status2);

        if (tgt_int_status2[6]) begin
          `TGT_BFM_MEMR(`TGT_ADR_RX_FIFO, wdata_mem[wdata_mem_index], 1'b1, rxfifo_rdata)  // get rxfifo data
          if (wdata_mem[wdata_mem_index] != rxfifo_rdata) begin
            data_err_cnt = data_err_cnt + 1;
          end
          wdata_mem_index = wdata_mem_index + 1;
        end

        // clear interrupt status
        `TGT_BFM_MEMW(`TGT_ADR_STAT2_INT, (tgt_int_status2 & 8'hFF)) // clear int status
      end

      wdata_mem_start = (wdata_mem_end == 8'hFF) ? 8'h0 : wdata_mem_end + 1;

      testname = " ";

      // clear interrupt status
      `TGT_BFM_MEMW(8'h36, 8'hFF) // clear int status
      // read interrupt status
      `TGT_BFM_MEMR(8'h36, 8'h00, 0, tgt_int_status3)  // get int status
      $display("%12d: [DEBUG] tgt_int_status3 = %0h",$stime,tgt_int_status3);

      while (~tgt_int_status3[0]) begin
        // read interrupt status
        `TGT_BFM_MEMR(8'h36, 8'h00, 0, tgt_int_status3)  // get int status
        $display("%12d: [DEBUG] tgt_int_status3 = %0h",$stime,tgt_int_status3);

        // clear interrupt status
        repeat(5) @(posedge clk_i);
        `TGT_BFM_MEMW(8'h36, (tgt_int_status3 & 8'hFF)) // clear int status
        // repeat(5) @(posedge clk_i);
        // `TGT_BFM_MEMR(8'h36, 8'h00, 0, tgt_int_status3)  // get int status
        // $display("%12d: [DEBUG] tgt_int_status3 = %0h",$stime,tgt_int_status3);
      end
    end
    else begin
        $display("%12d: ==== [I2C TEST] Device does not have Static Address", $stime);
    end

    target_isr_generic;
  end
endtask // i2c_test

task hdr_ddr_test;
  begin
    testname = "HDR-DDR Test";

    if (HDR_CAPABLE) begin
      send_ccc_broadcast_endxfer(8'hF7, 8'hF1);
      send_ccc_direct_endxfer(1, 8'hF7, 8'hF1);
      send_ccc_broadcast_endxfer(8'hAA, 8'hAA);
      send_ccc_direct_endxfer(1, 8'hAA, 8'h99);
      send_ccc_direct_endxfer(0, 8'hF7, 8'h52);
      send_ccc_direct_endxfer(1, 8'hF7, 8'h52);
      send_ccc_direct_endxfer(0, 8'hAA, 8'h52);
      send_ccc_direct_endxfer(0, 8'hAA, 8'hAA);
      send_ccc_direct_endxfer(1, 8'h01, 8'h5A);
      send_ccc_direct_endxfer(1, 8'hAA, 8'hAA);
      send_hdr_ddr_write_read;
      send_hdr_ddr_ccc_broadcast_entas;
      send_hdr_ddr_ccc_broadcast_disec(1, 1, 1);
      send_hdr_ddr_ccc_broadcast_enec(1, 1, 1);
      send_hdr_ddr_ccc_direct_disec(1, 1, 1);
      send_hdr_ddr_ccc_direct_enec(1, 1, 1);
      send_hdr_ddr_ccc_direct_entas;
      send_hdr_ddr_ccc_broadcast_setmwl(7'h7F, 8'hAA, 8'h55);
      send_hdr_ddr_ccc_direct_setmwl(7'h7F, 8'h55, 8'hAA);
      send_hdr_ddr_ccc_direct_getmwl(7'h01);
      send_hdr_ddr_ccc_broadcast_setmrl(7'h40, 8'h02, 8'h04, 8'h08);
      send_hdr_ddr_ccc_direct_setmrl(7'h40, 8'hAB, 8'hCD, 8'hEF);
      send_hdr_ddr_ccc_direct_getmrl(7'h00);
      send_hdr_ddr_ccc_direct_getbcr(7'h16);
      send_hdr_ddr_ccc_direct_getdcr(7'h23);
      send_hdr_ddr_ccc_direct_getstatus(7'h0, 8'h4);
      send_hdr_ddr_ccc_direct_getxtime(7'h44);
      send_hdr_ddr_ccc_broadcast_setxtime(7'h44, 8'hDF);
      send_hdr_ddr_ccc_broadcast_setxtime(7'h44, 8'h0F);
      send_hdr_ddr_ccc_direct_setxtime(7'h44, 8'hDF);
      send_hdr_ddr_ccc_direct_setxtime(7'h44, 8'hDF);
      send_hdr_ddr_ccc_direct_setxtime(7'h44, 8'hFF);
      send_hdr_ddr_ccc_broadcast_endxfer(8'hF7, 4'hF);
      send_hdr_ddr_ccc_broadcast_endxfer(8'hF6, 4'hF);
      send_hdr_ddr_ccc_direct_endxfer(8'hF7, 4'h4, 7'h34);
    end
    else begin
      $display("%12d: ==== Skipping HDR-DDR Tests...", $stime);
      $display("%12d: ==== HDR-DDR Capability is not enabled in device", $stime);
    end
  end

endtask // hdr_ddr_test

task target_isr_generic;
  reg [7:0]     tgt_int_status1;
  reg [7:0]     tgt_int_status2;
  reg [7:0]     tgt_int_status3;
  reg [7:0]     rdata;
  begin
    // wait(tgt_int_o);
    if(tgt_int_o) begin
      // read interrupt status
      `TGT_BFM_MEMR(`TGT_ADR_STAT1_INT, 8'h00, 0, tgt_int_status1)  // get int status
      $display("%12d: [DEBUG] tgt_int_status1 = %0h",$stime,tgt_int_status1);
      `TGT_BFM_MEMR(`TGT_ADR_STAT2_INT, 8'h00, 0, tgt_int_status2)  // get int status
      $display("%12d: [DEBUG] tgt_int_status2 = %0h",$stime,tgt_int_status2);
      `TGT_BFM_MEMR(8'h36, 8'h00, 0, tgt_int_status3)  // get int status
      $display("%12d: [DEBUG] tgt_int_status3 = %0h",$stime,tgt_int_status3);

      if(tgt_int_status1) begin
        // clear interrupt status
        repeat(5) @(posedge clk_i);
        `TGT_BFM_MEMW(`TGT_ADR_STAT1_INT, (tgt_int_status1 & 8'hFF)) // clear int status
      end
      if(tgt_int_status2) begin
        // clear interrupt status
        `TGT_BFM_MEMW(`TGT_ADR_STAT2_INT, (tgt_int_status2 & 8'hFF)) // clear int status
      end
      if(tgt_int_status3) begin
        // clear interrupt status
        `TGT_BFM_MEMW(8'h36, (tgt_int_status3 & 8'hFF)) // clear int status
      end
    end // tgt_int_o

    @(posedge clk_i);
    // read interrupt status
    `TGT_BFM_MEMR(`TGT_ADR_STAT1_INT, 8'h00, 0, tgt_int_status1)  // get int status
    $display("%12d: [DEBUG] tgt_int_status1 = %0h",$stime,tgt_int_status1);
    `TGT_BFM_MEMR(`TGT_ADR_STAT2_INT, 8'h00, 0, tgt_int_status2)  // get int status
    $display("%12d: [DEBUG] tgt_int_status2 = %0h",$stime,tgt_int_status2);
    `TGT_BFM_MEMR(8'h36, 8'h00, 0, tgt_int_status3)  // get int status
    $display("%12d: [DEBUG] tgt_int_status3 = %0h",$stime,tgt_int_status3);
  end
endtask // target_isr_generic

task register_test;
  reg   [7:0]   reg_addr;
  reg   [7:0]   reg_data;

  begin
    $display("%12d: ==== Register values at reset", $stime);

    for (reg_addr = 0 ; reg_addr <= 8'h40 ; reg_addr = reg_addr + 1) begin
      if (reg_addr != 8'h20 & reg_addr !=8'h22) begin
      `TGT_BFM_MEMR(reg_addr, 8'h00, 0, reg_data)  // read_data
      end
    end

    $display("%12d: ==== Write-read all 1s to registers", $stime);
    for (reg_addr = 0 ; reg_addr <= 8'h40 ; reg_addr = reg_addr + 1) begin
      if (reg_addr != 8'h20 & reg_addr != 8'h22 & reg_addr !=8'h28) begin
      `TGT_BFM_MEMW(reg_addr, 8'hFF)
      end
    end

    for (reg_addr = 0 ; reg_addr <= 8'h40 ; reg_addr = reg_addr + 1) begin
      if (reg_addr != 8'h20 & reg_addr !=8'h22) begin
      `TGT_BFM_MEMR(reg_addr, 8'h00, 0, reg_data)  // read_data
      end
    end

    $display("%12d: ==== Write-read all 0s to registers", $stime);
    for (reg_addr = 0 ; reg_addr <= 8'h40 ; reg_addr = reg_addr + 1) begin
      if (reg_addr != 8'h20 & reg_addr != 8'h22 & reg_addr !=8'h28) begin
      `TGT_BFM_MEMW(reg_addr, 8'h00)
      end
    end

    for (reg_addr = 0 ; reg_addr <= 8'h40 ; reg_addr = reg_addr + 1) begin
      if (reg_addr != 8'h20 & reg_addr !=8'h22) begin
      `TGT_BFM_MEMR(reg_addr, 8'h00, 0, reg_data)  // read_data
      end
    end
  end
endtask

task dev_addr_chk;
  reg   [6:0] dev_addr;
  begin
    for (dev_addr = 0 ; dev_addr <= 7'h7F ; dev_addr = dev_addr + 7'h1) begin
        send_private_write(dev_addr
                          ,8'h1
                          ,8'h0
                          ,1'b0
                          ,1'b1
                          ,1'b0
                          ,1'b0);
    end
  end
endtask // dev_addr_chk

task soft_reset_chk;
  input [4:0]   soft_reset_bit;
  begin
    $display("%12d: ==== IP Main Reset", $stime);
    `TGT_BFM_MEMW(8'h28, {3'h0, soft_reset_bit}) // ip_main_rst

    repeat (100) @ (posedge clk_i);
  end
endtask // soft_reset_chk

task chk_error;
  begin
    if ((data_err_cnt > 0) | (da_err_cnt > 0)) begin
      test_error = 1'b1;
    end

    $display("-----------------------------------------------------");
    $display("%12d: Dynamic Address error count = %0h",$stime,da_err_cnt);
    $display("%12d: Data error count = %0h",$stime,data_err_cnt);

    if (test_error) begin
      $display("-----------------------------------------------------");
      $display("----------------- SIMULATION FAILED -----------------");
      $display("-----------------------------------------------------");
    end
    else begin
      $display("-----------------------------------------------------");
      $display("----------------- SIMULATION PASSED -----------------");
      $display("-----------------------------------------------------");
    end

  end
endtask

//----------------------------------------------------------------
// Module Instantiations
//----------------------------------------------------------------
`include "dut_inst.v"
assign    tgt_int_o = int_o;

`ifndef iCE40UP
  `ifdef LAV_AT
    GSRA GSR_INST (.GSR_N  (rst_n_i));
  `else
    GSR  GSR_INST (.CLK(clk_i) ,.GSR_N  (rst_n_i));
  `endif
`endif

//----------------------------------------------------------------
// Controller Model
//----------------------------------------------------------------
tb_lscc_i3c_controller #(
 .FAMILY                (FAMILY         )
,.SIMULATION            (SIMULATION     )
,.ENABLE_IBI            (IBI_CAPABLE    )
,.ENABLE_HJI            (HOTJOIN_CAPABLE)
,.ENABLE_SMI            (0              )
,.ENABLE_HDR_DDR        (HDR_CAPABLE    )
,.SEL_INTF              (INTERFACE      )
,.FIFO_IMPL             ("PMI"          )
,.REG_MAPPING           (REG_MAPPING    )
,.LMMI_AWID             (LMMI_AWID      )
,.LMMI_DWID             (LMMI_DWID      )
,.APB_AWID              (APB_AWID       )
,.APB_DWID              (APB_DWID       )
,.AHBL_AWID             (AHBL_AWID      )
,.AHBL_DWID             (AHBL_DWID      )
,.EN_FIFOINTF           (EN_FIFOINTF    )
,.TXDWID                (TXDWID         )
,.RXDWID                (RXDWID         )
,.CLKDOMAIN             ("ASYNC"        )
,.USE_INTCLKDIV         (1              )
,.DEFAULT_RATE          (0              )
,.DEFAULT_ODTIMER       (2              )
,.EN_DYN_I2C_SWITCHING  (0              )
,.I2C_RATE              (1              )
)
u_ctl_model (
 .clk_i                 (clk_i                  )
,.src_clk_scl_i         (scl_src_i              )
,.rst_n_i               (rst_n_i                )
,.scl_io                (scl_io                 )
,.sda_io                (sda_io                 )
,.lmmi_request_i        (ctl_lmmi_request_i     )
,.lmmi_wr_rdn_i         (ctl_lmmi_wr_rdn_i      )
,.lmmi_offset_i         (ctl_lmmi_offset_i      )
,.lmmi_wdata_i          (ctl_lmmi_wdata_i       )
,.lmmi_rdata_o          (ctl_lmmi_rdata_o       )
,.lmmi_rdata_valid_o    (ctl_lmmi_rdata_valid_o )
,.lmmi_ready_o          (ctl_lmmi_ready_o       )
,.lmmi_error_o          (ctl_lmmi_error_o       )
,.int_o                 (ctl_int_o              )
,.sc_rst_o              (ctl_sc_rst_o           )
,.apb_penable_i         (ctl_apb_penable_i      )
,.apb_psel_i            (ctl_apb_psel_i         )
,.apb_pwrite_i          (ctl_apb_pwrite_i       )
,.apb_paddr_i           (ctl_apb_paddr_i        )
,.apb_pwdata_i          (ctl_apb_pwdata_i       )
,.apb_pready_o          (ctl_apb_pready_o       )
,.apb_pslverr_o         (ctl_apb_pslverr_o      )
,.apb_prdata_o          (ctl_apb_prdata_o       )
,.ahbl_hsel_i           (ctl_ahbl_hsel_i        )
,.ahbl_hready_i         (ctl_ahbl_hready_i      )
,.ahbl_haddr_i          (ctl_ahbl_haddr_i       )
,.ahbl_hburst_i         (ctl_ahbl_hburst_i      )
,.ahbl_hsize_i          (ctl_ahbl_hsize_i       )
,.ahbl_hmastlock_i      (ctl_ahbl_hmastlock_i   )
,.ahbl_hprot_i          (ctl_ahbl_hprot_i       )
,.ahbl_htrans_i         (ctl_ahbl_htrans_i      )
,.ahbl_hwrite_i         (ctl_ahbl_hwrite_i      )
,.ahbl_hwdata_i         (ctl_ahbl_hwdata_i      )
,.ahbl_hreadyout_o      (ctl_ahbl_hreadyout_o   )
,.ahbl_hresp_o          (ctl_ahbl_hresp_o       )
,.ahbl_hrdata_o         (ctl_ahbl_hrdata_o      )
,.tx_valid_i            (ctl_tx_valid_i         )
,.tx_data_i             (ctl_tx_data_i          )
,.rx_ready_i            (ctl_rx_ready_i         )
,.tx_ready_o            (ctl_tx_ready_o         )
,.rx_valid_o            (ctl_rx_valid_o         )
,.rx_data_o             (ctl_rx_data_o          )
,.ext_io_scl_i          (1'b0                   )
,.ext_io_sda_i          (1'b0                   )

,.ext_io_scl_oe         (                       )
,.ext_io_sda_oe         (                       )

,.ext_io_scl_o          (                       )
,.ext_io_sda_o          (                       )

,.ext_io_sda_spu_n      (                       )
,.ext_io_scl_spu_n      (                       )
,.ext_io_sda_wpu_n      (                       )
,.ext_io_scl_wpu_n      (                       )
);

//----------------------------------------------------------------
// Direct FIFO Interface
//----------------------------------------------------------------
i3c_bfm_stream #(.TXDWID(TXDWID), .RXDWID(RXDWID)) ctl_fifo_intf_bfm
(
    // Inputs
    .clk_i                                 (clk_i),
    .rst_n_i                               (rst_n_i),
    .tx_ready_o                            (ctl_tx_ready_o),
    .rx_valid_o                            (ctl_rx_valid_o),
    .rx_data_o                             (ctl_rx_data_o),
    // Outputs
    .tx_valid_i                            (ctl_tx_valid_i),
    .tx_data_i                             (ctl_tx_data_i),
    .rx_ready_i                            (ctl_rx_ready_i)
/*AUTOINST*/);

initial begin
  ctl_fifo_intf_bfm.init;
end

i3c_bfm_stream #(.TXDWID(TXDWID), .RXDWID(RXDWID)) tgt_fifo_intf_bfm
(
    // Inputs
    .clk_i                                 (clk_i),
    .rst_n_i                               (rst_n_i),
    .tx_ready_o                            (tx_ready_o),
    .rx_valid_o                            (rx_valid_o),
    .rx_data_o                             (rx_data_o),
    // Outputs
    .tx_valid_i                            (tx_valid_i),
    .tx_data_i                             (tx_data_i),
    .rx_ready_i                            (rx_ready_i)
/*AUTOINST*/);

initial begin
  tgt_fifo_intf_bfm.init;
end

generate
  if(INTERFACE != "LMMI") begin : gen_ctl_not_lmmi
    assign ctl_lmmi_request_i = 0;
    assign ctl_lmmi_offset_i  = 0;
    assign ctl_lmmi_wr_rdn_i  = 0;
    assign ctl_lmmi_wdata_i   = 0;
  end
  if(INTERFACE != "APB") begin : gen_ctl_not_apb
    assign ctl_apb_psel_i    = 0;
    assign ctl_apb_penable_i = 0;
    assign ctl_apb_paddr_i   = 0;
    assign ctl_apb_pwrite_i  = 0;
    assign ctl_apb_pwdata_i  = 0;
  end
  if(INTERFACE != "AHBL") begin : gen_ctl_not_ahbl
    assign ctl_ahbl_hsel_i      = 0;
    assign ctl_ahbl_hready_i    = 0;
    assign ctl_ahbl_haddr_i     = 0;
    assign ctl_ahbl_hburst_i    = 0;
    assign ctl_ahbl_hsize_i     = 0;
    assign ctl_ahbl_hmastlock_i = 0;
    assign ctl_ahbl_hprot_i     = 0;
    assign ctl_ahbl_htrans_i    = 0;
    assign ctl_ahbl_hwrite_i    = 0;
    assign ctl_ahbl_hwdata_i    = 0;
  end
  if(EN_FIFOINTF==1'b0) begin : gen_ctl_not_en_fifoint
    assign ctl_tx_valid_i   = 0;
    assign ctl_tx_data_i    = 0;
    assign ctl_rx_ready_i   = 0;
    assign ctl_tx_ready_o   = 0;
    assign ctl_rx_valid_o   = 0;
    assign ctl_rx_data_o    = 0;
  end

  if(INTERFACE == "LMMI") begin : gen_bfm_0
    i3c_bfm_lmmi ctl_reg_intf_bfm
    (
    // Inputs
     .clk_i                                 (clk_i)
    ,.rst_n_i                               (rst_n_i)
    ,.lmmi_ready_i                          (ctl_lmmi_ready_o      )
    ,.lmmi_rdata_valid_i                    (ctl_lmmi_rdata_valid_o)
    ,.lmmi_error_i                          (ctl_lmmi_error_o      )
    ,.lmmi_rdata_i                          (ctl_lmmi_rdata_o      )
    ,.int_i                                 (ctl_int_o             )
    // Outputs
    ,.lmmi_request_o                        (ctl_lmmi_request_i    )
    ,.lmmi_wr_rdn_o                         (ctl_lmmi_wr_rdn_i     )
    ,.lmmi_offset_o                         (ctl_lmmi_offset_i     )
    ,.lmmi_wdata_o                          (ctl_lmmi_wdata_i      )
    /*AUTOINST*/);
     initial begin
       ctl_reg_intf_bfm.init;
     end

    i3c_bfm_lmmi tgt_reg_intf_bfm
    (
    // Inputs
     .clk_i                                 (clk_i)
    ,.rst_n_i                               (rst_n_i)
    ,.lmmi_ready_i                          (lmmi_ready_o      )
    ,.lmmi_rdata_valid_i                    (lmmi_rdata_valid_o)
    ,.lmmi_error_i                          (lmmi_error_o      )
    ,.lmmi_rdata_i                          (lmmi_rdata_o      )
    ,.int_i                                 (int_o             )
    // Outputs
    ,.lmmi_request_o                        (lmmi_request_i    )
    ,.lmmi_wr_rdn_o                         (lmmi_wr_rdn_i     )
    ,.lmmi_offset_o                         (lmmi_offset_i     )
    ,.lmmi_wdata_o                          (lmmi_wdata_i      )
    /*AUTOINST*/);
     initial begin
       tgt_reg_intf_bfm.init;
     end

    `ifndef GATE_SIM
      defparam `DUT_HIER_PATH(`DUT_INST_NAME).SIMULATION = SIMULATION;
    `endif

    `RUN_SAMPLE_TEST
  end // gen_bfm_0

  if(INTERFACE == "APB") begin : gen_bfm_1
    wire  [TB_APB_AWID-1:0]   apb_paddr_w;
    wire  [TB_APB_AWID-1:0]   ctl_apb_paddr_w;

    assign apb_paddr_i = (REG_MAPPING) ? {apb_paddr_w,2'd0} : apb_paddr_w;
    assign ctl_apb_paddr_i = (REG_MAPPING) ? {ctl_apb_paddr_w,2'd0} : ctl_apb_paddr_w;

    i3c_bfm_apb ctl_reg_intf_bfm
    (
     .PCLK                                  (clk_i)
    ,.PRST_N                                (rst_n_i)
    ,.PENABLE                               (ctl_apb_penable_i)
    ,.PSEL                                  (ctl_apb_psel_i   )
    ,.PWRITE                                (ctl_apb_pwrite_i )
    ,.PADDR                                 (ctl_apb_paddr_w  )
    ,.PWDATA                                (ctl_apb_pwdata_i )
    ,.PREADY                                (ctl_apb_pready_o )
    ,.PSLVERR                               (ctl_apb_pslverr_o)
    ,.PRDATA                                (ctl_apb_prdata_o )
    ,.INTR                                  (ctl_int_o        )
    /*AUTOINST*/);
     initial begin
       ctl_reg_intf_bfm.init;
     end

    i3c_bfm_apb tgt_reg_intf_bfm
    (
     .PCLK                                  (clk_i)
    ,.PRST_N                                (rst_n_i)
    ,.PENABLE                               (apb_penable_i)
    ,.PSEL                                  (apb_psel_i   )
    ,.PWRITE                                (apb_pwrite_i )
    ,.PADDR                                 (apb_paddr_w  )
    ,.PWDATA                                (apb_pwdata_i )
    ,.PREADY                                (apb_pready_o )
    ,.PSLVERR                               (apb_pslverr_o)
    ,.PRDATA                                (apb_prdata_o )
    ,.INTR                                  (int_o        )
    /*AUTOINST*/);
     initial begin
       tgt_reg_intf_bfm.init;
     end

    `ifndef GATE_SIM
      defparam `DUT_HIER_PATH(`DUT_INST_NAME).SIMULATION = SIMULATION;
    `endif

    `RUN_SAMPLE_TEST
  end // gen_bfm_1

  if(INTERFACE == "AHBL") begin : gen_bfm_2
    wire  [TB_AHBL_AWID-1:0]  ahbl_haddr_w;
    wire  [TB_AHBL_AWID-1:0]  ctl_ahbl_haddr_w;

    assign ahbl_hready_i = 1'b1;
    assign ahbl_haddr_i  = (REG_MAPPING)? {ahbl_haddr_w,2'd0} : ahbl_haddr_w;

    assign ctl_ahbl_hready_i = 1'b1;
    assign ctl_ahbl_haddr_i  = (REG_MAPPING)? {ctl_ahbl_haddr_w,2'd0} : ctl_ahbl_haddr_w;

    i3c_bfm_ahbl #
    (
     .TB_AHBL_DWID                      (TB_AHBL_DWID)
    ,.TB_AHBL_AWID                      (TB_AHBL_DWID)
    )
    ctl_reg_intf_bfm
    (
     // Inputs
     .clk_i                             (clk_i),
     .rst_n_i                           (rst_n_i),
     .ahbl_hready_i                     (ctl_ahbl_hreadyout_o),
     .ahbl_hresp_i                      (ctl_ahbl_hresp_o),
     .ahbl_hrdata_i                     (ctl_ahbl_hrdata_o),
     .int_i                             (ctl_int_o),
     // Outputs
     .ahbl_hsel_o                       (ctl_ahbl_hsel_i),
     .ahbl_haddr_o                      (ctl_ahbl_haddr_w),
     .ahbl_hburst_o                     (ctl_ahbl_hburst_i[2:0]),
     .ahbl_hsize_o                      (ctl_ahbl_hsize_i[2:0]),
     .ahbl_hmastlock_o                  (ctl_ahbl_hmastlock_i),
     .ahbl_hprot_o                      (ctl_ahbl_hprot_i[3:0]),
     .ahbl_htrans_o                     (ctl_ahbl_htrans_i[1:0]),
     .ahbl_hwrite_o                     (ctl_ahbl_hwrite_i),
     .ahbl_hwdata_o                     (ctl_ahbl_hwdata_i)
    /*AUTOINST*/);
     initial begin
       ctl_reg_intf_bfm.init;
     end

    i3c_bfm_ahbl #
    (
     .TB_AHBL_DWID                      (TB_AHBL_DWID)
    ,.TB_AHBL_AWID                      (TB_AHBL_DWID)
    )
    tgt_reg_intf_bfm
    (
     // Inputs
     .clk_i                             (clk_i),
     .rst_n_i                           (rst_n_i),
     .ahbl_hready_i                     (ahbl_hreadyout_o),
     .ahbl_hresp_i                      (ahbl_hresp_o),
     .ahbl_hrdata_i                     (ahbl_hrdata_o),
     .int_i                             (tgt_int_o),
     // Outputs
     .ahbl_hsel_o                       (ahbl_hsel_i),
     .ahbl_haddr_o                      (ahbl_haddr_w),
     .ahbl_hburst_o                     (ahbl_hburst_i[2:0]),
     .ahbl_hsize_o                      (ahbl_hsize_i[2:0]),
     .ahbl_hmastlock_o                  (ahbl_hmastlock_i),
     .ahbl_hprot_o                      (ahbl_hprot_i[3:0]),
     .ahbl_htrans_o                     (ahbl_htrans_i[1:0]),
     .ahbl_hwrite_o                     (ahbl_hwrite_i),
     .ahbl_hwdata_o                     (ahbl_hwdata_i)
    /*AUTOINST*/);
     initial begin
       tgt_reg_intf_bfm.init;
     end

    `ifndef GATE_SIM
      defparam `DUT_HIER_PATH(`DUT_INST_NAME).SIMULATION = SIMULATION;
    `endif

    `RUN_SAMPLE_TEST
  end // gen_bfm_2

endgenerate

endmodule // tb_top

`endif //  `ifndef __I3C_TGT__TB_TOP__