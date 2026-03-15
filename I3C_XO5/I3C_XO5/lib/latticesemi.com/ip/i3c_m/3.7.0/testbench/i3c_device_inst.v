`ifndef __RTL_MODULE__I3C_DEVICE_INST__
`define __RTL_MODULE__I3C_DEVICE_INST__
//==========================================================================
// Module : i3c_device_inst
//==========================================================================
module i3c_device_inst #

( //--begin_param--
//----------------------------
// Parameters
//----------------------------
 parameter                      SIMULATION = 1
,parameter                      SYS_CLK_PERIOD = 100
,parameter                      TGT_LOOPBK_EN0 = 0
,parameter                      TGT_LOOPBK_EN1 = 0

) //--end_param--

( //--begin_ports--
 input                                  clk_i               // system clock
,input                                  rst_n_i             // main reset
,input                                  src_clk_scl_i       // optional SCL source clock

,inout wire                             scl_io
,inout wire                             sda_io
,inout wire                             sc0_scl_io
,inout wire                             sc0_sda_io
,inout wire                             tgt0_scl_io
,inout wire                             tgt0_sda_io
,inout wire                             tgt1_scl_io
,inout wire                             tgt1_sda_io
); //--end_ports--



//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
`include "dut_params.v"
`define EN_I3C_SC0
`define EN_I3C_TGT0
`define EN_I3C_TGT1

localparam                            LMMI_AWID        = 8;
localparam                            LMMI_DWID        = 8;
localparam                            APB_AWID         = LMMI_AWID+2*REG_MAPPING;
localparam                            APB_DWID         = LMMI_DWID;
localparam                            AHBL_AWID        = LMMI_AWID+2*REG_MAPPING;
localparam                            AHBL_DWID        = LMMI_DWID;
localparam                            INTERFACE        = SEL_INTF;
localparam                            BUS_WIDTH        = 32;

//--------------------------------------------------------------------------
//--- Combinational Wire/Reg ---
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------


wire        [(TXDWID/8)-1:0]          tx_valid_i;
wire        [TXDWID-1:0]              tx_data_i;
wire                                  tx_ready_o;
wire                                  rx_ready_i;
wire        [(RXDWID/8)-1:0]          rx_valid_o;
wire        [RXDWID-1:0]              rx_data_o;

wire                                  lmmi_request_i;
wire        [LMMI_AWID-1:0]           lmmi_offset_i;
wire                                  lmmi_wr_rdn_i;
wire        [LMMI_DWID-1:0]           lmmi_wdata_i;
wire                                  lmmi_ready_o;
wire                                  lmmi_rdata_valid_o;
wire        [LMMI_DWID-1:0]           lmmi_rdata_o;
wire                                  lmmi_error_o;
wire                                  apb_psel_i;
wire                                  apb_penable_i;
wire        [BUS_WIDTH-1:0]           apb_paddr_i;
wire                                  apb_pwrite_i;
wire        [BUS_WIDTH-1:0]           apb_pwdata_i;
wire                                  apb_pready_o;
wire        [BUS_WIDTH-1:0]           apb_prdata_o;
wire                                  apb_pslverr_o;
wire                                  ahbl_hsel_i;
wire                                  ahbl_hready_i;
wire        [BUS_WIDTH-1:0]           ahbl_haddr_i;
wire        [2:0]                     ahbl_hburst_i;
wire        [2:0]                     ahbl_hsize_i;
wire                                  ahbl_hmastlock_i;
wire        [3:0]                     ahbl_hprot_i;
wire        [1:0]                     ahbl_htrans_i;
wire                                  ahbl_hwrite_i;
wire        [BUS_WIDTH-1:0]           ahbl_hwdata_i;
wire                                  ahbl_hreadyout_o;
wire                                  ahbl_hresp_o;
wire        [BUS_WIDTH-1:0]           ahbl_hrdata_o;
wire                                  int_o;

wire                                  ext_io_scl_i;
wire                                  ext_io_sda_i;
wire                                  ext_io_scl_oe;
wire                                  ext_io_sda_oe;
wire                                  ext_io_scl_o;
wire                                  ext_io_sda_o;
wire                                  ext_io_sda_spu_n;
wire                                  ext_io_scl_spu_n;
wire                                  ext_io_sda_wpu_n;
wire                                  ext_io_scl_wpu_n;

//--------------------------------------------------------------------------
//--- Module Instantiation ---
//--------------------------------------------------------------------------
`include "dut_inst.v"

`define GATE_SIM

`ifndef GATE_SIM
`define DUT_HIER_PATH(ip_name)         u_``ip_name.lscc_i3c_controller_inst
defparam `DUT_HIER_PATH(`DUT_INST_NAME).SIMULATION = SIMULATION;
  wire          [44-1:0]                  debug_bus;

  assign debug_bus = {`DUT_HIER_PATH(`DUT_INST_NAME).gen_sim.debug_bus};
  // --------------------
  // Debug Signals
  // --------------------


  wire          [3:0]                     // auto enum state_1
                                          i3cbus_sm_cs;
  wire          [1:0]                     // auto enum state_2
                                          cleanup_sm_cs;
  wire          [3:0]                     // auto enum state_3
                                          i3c_sm_cs;

  wire                                    i3cbus_i2cfrm  ;
  wire                                    i3cbus_ibi_det ;
  wire                                    i3cbus_ready   ;
  wire                                    i3cbus_valid   ;
  wire          [1:0]                     i3cbus_sr_s    ;    // Start = 2'b01, Repeated Start = 2'b11
  wire          [1:0]                     i3cbus_dtype   ;    // data type: 2'b00 = address, 2'b01 = data/payload, 2'b10 = assigned address (DAA), 2'b11 = unique ID (DAA)
  wire          [7:0]                     i3cbus_data    ;    // if dtype = 2'bx0 Addr = data[7:1], RnW/PAR = data[0], else Data = data[7:0]
  wire          [7:0]                     i3cbus_rdata   ;
  wire                                    i3cbus_wlast   ;
  wire                                    i3cbus_rvalid  ;    // indicates valid rdata (after TBIT)
  wire                                    i3cbus_rlast   ;    // last rdata by target (as indicated by TBIT=0)
  wire                                    i3cbus_rsp_ack ;
  wire                                    i3cbus_rsp_nak ;
  wire                                    i3cbus_rdone   ;    // early indicator that 8b rdata was received (before TBIT)
  wire                                    i3cbus_rdpause ;    // hold scl low to temporarily stop read data
  wire                                    i3cbus_rdstop  ;    // controller terminates read data (according to expected length)
  wire                                    enter_daa_mode ;
  wire                                    target_rstact  ;

  assign {
           i3c_sm_cs      [3:0]
          // 8
          ,i3cbus_i2cfrm
          ,i3cbus_ibi_det
          ,i3cbus_ready
          ,i3cbus_valid
          ,i3cbus_sr_s    [1:0]      // Start = 2'b01, Repeated Start = 2'b11
          ,i3cbus_dtype   [1:0]      // data type: 2'b00 = address, 2'b01 = data/payload, 2'b10 = assigned address (DAA), 2'b11 = unique ID (DAA)
          // 8
          ,i3cbus_data    [7:0]      // if dtype = 2'bx0 Addr = data[7:1], RnW/PAR = data[0], else Data = data[7:0]
          // 8
          ,i3cbus_rdata   [7:0]
          // 8
          ,i3cbus_wlast
          ,i3cbus_rvalid             // indicates valid rdata (after TBIT)
          ,i3cbus_rlast              // last rdata by slave (as indicated by TBIT=0)
          ,i3cbus_rsp_ack
          ,i3cbus_rsp_nak
          ,i3cbus_rdone              // early indicator that 8b rdata was received (before TBIT)
          ,i3cbus_rdpause            // hold scl low to temporarily stop read data
          ,i3cbus_rdstop             // master terminates read data (according to expected length)
          // 8
          ,enter_daa_mode
          ,target_rstact
          ,cleanup_sm_cs  [1:0]
          ,i3cbus_sm_cs   [3:0]
          } = debug_bus;

  localparam                           // auto enum state_1
                                          ST_I3CBUS_IDLE      = 4'd0
                                         ,ST_I3CBUS_ADR7EW    = 4'd1
                                         ,ST_I3CBUS_ADR7ER    = 4'd2
                                         ,ST_I3CBUS_TGTDAA    = 4'd3
                                         ,ST_I3CBUS_ADRTGT    = 4'd4
                                         ,ST_I3CBUS_WDATA     = 4'd5
                                         ,ST_I3CBUS_RDATA     = 4'd6
                                         ,ST_I3CBUS_WAITRESP  = 4'd7
                                         ,ST_I3CBUS_RCVDNAK   = 4'd8
                                         ;

  localparam                           // auto enum state_2
                                          ST_CLEANUP_IDLE      = 2'd0
                                         ,ST_CLEANUP_PRV       = 2'd1
                                         ,ST_CLEANUP_CCC       = 2'd2
                                         ,ST_CLEANUP_DONE      = 2'd3
                                         ;

  localparam                           // auto enum state_3
                                          ST_I3C_IDLE       = 4'h0
                                         ,ST_I3C_IDL_START  = 4'h1
                                         ,ST_I3C_ADDR_S     = 4'h2
                                         ,ST_I3C_REP_START  = 4'h3
                                         ,ST_I3C_ADDR_SR    = 4'h4
                                         ,ST_I3C_T_ACKNAK   = 4'h5
                                         ,ST_I3C_WTBIT      = 4'h6
                                         ,ST_I3C_RTBIT      = 4'h7
                                         ,ST_I3C_SETWDATA   = 4'h8
                                         ,ST_I3C_GETRDATA   = 4'h9
                                         ,ST_I3C_C_ACKNAK   = 4'ha
                                         ,ST_I3C_WAITSTP    = 4'hb
                                         ,ST_I3C_IBIDET     = 4'hc
                                         ,ST_I3C_ENTDAA     = 4'hd
                                         ,ST_I3C_RSTACT     = 4'he
                                         ;

  ///*AUTOASCIIENUM("i3cbus_sm_cs", "_i3cbus_cs_", "ST_I3CBUS_")*/
  // Beginning of automatic ASCII enum decoding
  reg         [71:0]        _i3cbus_cs_;      // Decode of i3cbus_sm_cs
  always @(i3cbus_sm_cs) begin
     case ({i3cbus_sm_cs})
       ST_I3CBUS_IDLE:      _i3cbus_cs_ = "IDLE     ";
       ST_I3CBUS_ADR7EW:    _i3cbus_cs_ = "ADR7EW   ";
       ST_I3CBUS_ADR7ER:    _i3cbus_cs_ = "ADR7ER   ";
       ST_I3CBUS_TGTDAA:    _i3cbus_cs_ = "TGTDAA   ";
       ST_I3CBUS_ADRTGT:    _i3cbus_cs_ = "ADRTGT   ";
       ST_I3CBUS_WDATA:     _i3cbus_cs_ = "WDATA    ";
       ST_I3CBUS_RDATA:     _i3cbus_cs_ = "RDATA    ";
       ST_I3CBUS_WAITRESP:  _i3cbus_cs_ = "WAITRESP ";
       ST_I3CBUS_RCVDNAK:   _i3cbus_cs_ = "RCVDNAK  ";
       default:             _i3cbus_cs_ = "%ERROR   ";
     endcase
  end
  // End of automatics

  ///*AUTOASCIIENUM("cleanup_sm_cs", "_cleanup_cs_", "ST_CLEANUP_")*/
  // Beginning of automatic ASCII enum decoding
  reg         [31:0]        _cleanup_cs_;     // Decode of cleanup_sm_cs
  always @(cleanup_sm_cs) begin
     case ({cleanup_sm_cs})
       ST_CLEANUP_IDLE: _cleanup_cs_ = "IDLE";
       ST_CLEANUP_PRV:  _cleanup_cs_ = "PRV ";
       ST_CLEANUP_CCC:  _cleanup_cs_ = "CCC ";
       ST_CLEANUP_DONE: _cleanup_cs_ = "DONE";
       default:         _cleanup_cs_ = "%ERR";
     endcase
  end
  // End of automatics

  ///*AUTOASCIIENUM("i3c_sm_cs", "_i3c_cs_", "ST_I3C_")*/
  // Beginning of automatic ASCII enum decoding
  reg         [71:0]        _i3c_cs_;         // Decode of i3c_sm_cs
  always @(i3c_sm_cs) begin
     case ({i3c_sm_cs})
       ST_I3C_IDLE:      _i3c_cs_ = "IDLE     ";
       ST_I3C_IDL_START: _i3c_cs_ = "IDL_START";
       ST_I3C_ADDR_S:    _i3c_cs_ = "ADDR_S   ";
       ST_I3C_REP_START: _i3c_cs_ = "REP_START";
       ST_I3C_ADDR_SR:   _i3c_cs_ = "ADDR_SR  ";
       ST_I3C_T_ACKNAK:  _i3c_cs_ = "T_ACKNAK ";
       ST_I3C_WTBIT:     _i3c_cs_ = "WTBIT    ";
       ST_I3C_RTBIT:     _i3c_cs_ = "RTBIT    ";
       ST_I3C_SETWDATA:  _i3c_cs_ = "SETWDATA ";
       ST_I3C_GETRDATA:  _i3c_cs_ = "GETRDATA ";
       ST_I3C_C_ACKNAK:  _i3c_cs_ = "C_ACKNAK ";
       ST_I3C_WAITSTP:   _i3c_cs_ = "WAITSTP  ";
       ST_I3C_IBIDET:    _i3c_cs_ = "IBIDET   ";
       ST_I3C_ENTDAA:    _i3c_cs_ = "ENTDAA   ";
       ST_I3C_RSTACT:    _i3c_cs_ = "RSTACT   ";
       default:          _i3c_cs_ = "%ERROR   ";
     endcase
  end
  // End of automatics
`endif



/*tb_lscc_i3c_target AUTO_TEMPLATE
(
 .clk_i                                 (clk_i),
 .rst_n_i                               (rst_n_i),
 .scl_io                                (scl_io),
 .sda_io                                (sda_io),
 .\(.*\)                                (tgt@_\1[]),
);*/

`ifdef EN_I3C_TGT0
wire                                  tgt0_lmmi_request_i;
wire        [LMMI_AWID-1:0]           tgt0_lmmi_offset_i;
wire                                  tgt0_lmmi_wr_rdn_i;
wire        [LMMI_DWID-1:0]           tgt0_lmmi_wdata_i;
wire                                  tgt0_lmmi_ready_o;
wire                                  tgt0_lmmi_rdata_valid_o;
wire        [LMMI_DWID-1:0]           tgt0_lmmi_rdata_o;
wire                                  tgt0_lmmi_error_o;
wire                                  tgt0_apb_psel_i;
wire                                  tgt0_apb_penable_i;
wire        [BUS_WIDTH-1:0]           tgt0_apb_paddr_i;
wire                                  tgt0_apb_pwrite_i;
wire        [BUS_WIDTH-1:0]           tgt0_apb_pwdata_i;
wire                                  tgt0_apb_pready_o;
wire        [BUS_WIDTH-1:0]           tgt0_apb_prdata_o;
wire                                  tgt0_apb_pslverr_o;
wire                                  tgt0_ahbl_hsel_i;
wire                                  tgt0_ahbl_hready_i;
wire        [BUS_WIDTH-1:0]           tgt0_ahbl_haddr_i;
wire        [2:0]                     tgt0_ahbl_hburst_i;
wire        [2:0]                     tgt0_ahbl_hsize_i;
wire                                  tgt0_ahbl_hmastlock_i;
wire        [3:0]                     tgt0_ahbl_hprot_i;
wire        [1:0]                     tgt0_ahbl_htrans_i;
wire                                  tgt0_ahbl_hwrite_i;
wire        [BUS_WIDTH-1:0]           tgt0_ahbl_hwdata_i;
wire                                  tgt0_ahbl_hreadyout_o;
wire                                  tgt0_ahbl_hresp_o;
wire        [BUS_WIDTH-1:0]           tgt0_ahbl_hrdata_o;
wire                                  tgt0_int_o;
wire                                  tgt0_tgt_rst_o;

generate
  if(INTERFACE != "LMMI") begin
    assign tgt0_lmmi_request_i = 0;
    assign tgt0_lmmi_offset_i  = 0;
    assign tgt0_lmmi_wr_rdn_i  = 0;
    assign tgt0_lmmi_wdata_i   = 0;
  end
  if(INTERFACE != "APB") begin
    assign tgt0_apb_psel_i    = 0;
    assign tgt0_apb_penable_i = 0;
    assign tgt0_apb_paddr_i   = 0;
    assign tgt0_apb_pwrite_i  = 0;
    assign tgt0_apb_pwdata_i  = 0;
  end
  if(INTERFACE != "AHBL") begin
    assign tgt0_ahbl_hsel_i      = 0;
    assign tgt0_ahbl_hready_i    = 0;
    assign tgt0_ahbl_haddr_i     = 0;
    assign tgt0_ahbl_hburst_i    = 0;
    assign tgt0_ahbl_hsize_i     = 0;
    assign tgt0_ahbl_hmastlock_i = 0;
    assign tgt0_ahbl_hprot_i     = 0;
    assign tgt0_ahbl_htrans_i    = 0;
    assign tgt0_ahbl_hwrite_i    = 0;
    assign tgt0_ahbl_hwdata_i    = 0;
  end
endgenerate

tb_lscc_i3c_target #
(
 // Parameters
 .SIMULATION                            (SIMULATION),
 .FAMILY                                (FAMILY),
 .INTERFACE                             (INTERFACE),
 .REG_MAPPING                           (REG_MAPPING),
 .CLKI_FREQ                             (SYS_CLK_PERIOD),
 .FIFO_LOOPBACK_EN                      (TGT_LOOPBK_EN0),
 .HDR_CAPABLE                           ( 1    ) ,
 .IBI_CAPABLE                           ( 1    ) ,
 .IBI_DATA_PAY                          ( 0    ) ,
 .HOTJOIN_CAPABLE                       ( 1    ) ,
 .MAX_D_SPEED_LIMIT                     ( 1    ) ,
 .DCR                                   ( 0    ) ,
 .PID_MANUF                             ( 414  ) ,
 .PID_PART                              ( 1    ) ,
 .PID_INST                              ( 10   ) ,
 .PID_ADD                               ( 0    ) ,
 .STATIC_ADDR_EN                        ( 1    ) ,
 .STATIC_ADDR                           ( 10   ) ,
 .MXDS_W                                ( 0    ) ,
 .MXDS_R                                ( 0    ) ,
 .MXDS_RD_TURN                          ( 0.0  ))
u_tgt_model_0
(
 // Inputs
 .clk_i                                 (clk_i),
 .rst_n_i                               (rst_n_i),
 .lmmi_request_i                        (tgt0_lmmi_request_i),
 .lmmi_offset_i                         (tgt0_lmmi_offset_i),
 .lmmi_wr_rdn_i                         (tgt0_lmmi_wr_rdn_i),
 .lmmi_wdata_i                          (tgt0_lmmi_wdata_i),
 .apb_psel_i                            (tgt0_apb_psel_i),
 .apb_penable_i                         (tgt0_apb_penable_i),
 .apb_paddr_i                           (tgt0_apb_paddr_i),
 .apb_pwrite_i                          (tgt0_apb_pwrite_i),
 .apb_pwdata_i                          (tgt0_apb_pwdata_i),
 .ahbl_hsel_i                           (tgt0_ahbl_hsel_i),
 .ahbl_hready_i                         (tgt0_ahbl_hready_i),
 .ahbl_haddr_i                          (tgt0_ahbl_haddr_i),
 .ahbl_hburst_i                         (tgt0_ahbl_hburst_i[2:0]),
 .ahbl_hsize_i                          (tgt0_ahbl_hsize_i[2:0]),
 .ahbl_hmastlock_i                      (tgt0_ahbl_hmastlock_i),
 .ahbl_hprot_i                          (tgt0_ahbl_hprot_i[3:0]),
 .ahbl_htrans_i                         (tgt0_ahbl_htrans_i[1:0]),
 .ahbl_hwrite_i                         (tgt0_ahbl_hwrite_i),
 .ahbl_hwdata_i                         (tgt0_ahbl_hwdata_i),
 .tx_valid_i                            (1'd0),
 .tx_data_i                             (8'd0),
 .rx_ready_i                            (1'd0),
 .ext_scl_i                             (1'd1),
 .ext_sda_i                             (1'd1),
 // Inouts
 .scl_io                                (tgt0_scl_io),
 .sda_io                                (tgt0_sda_io),
 // Outputs
 .lmmi_ready_o                          (tgt0_lmmi_ready_o),
 .lmmi_rdata_valid_o                    (tgt0_lmmi_rdata_valid_o),
 .lmmi_rdata_o                          (tgt0_lmmi_rdata_o),
 .lmmi_error_o                          (tgt0_lmmi_error_o),
 .apb_pready_o                          (tgt0_apb_pready_o),
 .apb_prdata_o                          (tgt0_apb_prdata_o),
 .apb_pslverr_o                         (tgt0_apb_pslverr_o),
 .ahbl_hreadyout_o                      (tgt0_ahbl_hreadyout_o),
 .ahbl_hresp_o                          (tgt0_ahbl_hresp_o),
 .ahbl_hrdata_o                         (tgt0_ahbl_hrdata_o),
 .tx_ready_o                            (),
 .rx_valid_o                            (),
 .rx_data_o                             (),
 .ext_sda_o                             (),
 .ext_sda_oe                            (),
 .int_o                                 (tgt0_int_o),
 .tgt_rst_o                             (tgt0_tgt_rst_o));
`endif

`ifdef EN_I3C_TGT1
wire                                  tgt1_lmmi_request_i;
wire        [LMMI_AWID-1:0]           tgt1_lmmi_offset_i;
wire                                  tgt1_lmmi_wr_rdn_i;
wire        [LMMI_DWID-1:0]           tgt1_lmmi_wdata_i;
wire                                  tgt1_lmmi_ready_o;
wire                                  tgt1_lmmi_rdata_valid_o;
wire        [LMMI_DWID-1:0]           tgt1_lmmi_rdata_o;
wire                                  tgt1_lmmi_error_o;
wire                                  tgt1_apb_psel_i;
wire                                  tgt1_apb_penable_i;
wire        [BUS_WIDTH-1:0]           tgt1_apb_paddr_i;
wire                                  tgt1_apb_pwrite_i;
wire        [BUS_WIDTH-1:0]           tgt1_apb_pwdata_i;
wire                                  tgt1_apb_pready_o;
wire        [BUS_WIDTH-1:0]           tgt1_apb_prdata_o;
wire                                  tgt1_apb_pslverr_o;
wire                                  tgt1_ahbl_hsel_i;
wire                                  tgt1_ahbl_hready_i;
wire        [BUS_WIDTH-1:0]           tgt1_ahbl_haddr_i;
wire        [2:0]                     tgt1_ahbl_hburst_i;
wire        [2:0]                     tgt1_ahbl_hsize_i;
wire                                  tgt1_ahbl_hmastlock_i;
wire        [3:0]                     tgt1_ahbl_hprot_i;
wire        [1:0]                     tgt1_ahbl_htrans_i;
wire                                  tgt1_ahbl_hwrite_i;
wire        [BUS_WIDTH-1:0]           tgt1_ahbl_hwdata_i;
wire                                  tgt1_ahbl_hreadyout_o;
wire                                  tgt1_ahbl_hresp_o;
wire        [BUS_WIDTH-1:0]           tgt1_ahbl_hrdata_o;
wire                                  tgt1_int_o;
wire                                  tgt1_tgt_rst_o;

generate
  if(INTERFACE != "LMMI") begin
    assign tgt1_lmmi_request_i = 0;
    assign tgt1_lmmi_offset_i  = 0;
    assign tgt1_lmmi_wr_rdn_i  = 0;
    assign tgt1_lmmi_wdata_i   = 0;
  end
  if(INTERFACE != "APB") begin
    assign tgt1_apb_psel_i    = 0;
    assign tgt1_apb_penable_i = 0;
    assign tgt1_apb_paddr_i   = 0;
    assign tgt1_apb_pwrite_i  = 0;
    assign tgt1_apb_pwdata_i  = 0;
  end
  if(INTERFACE != "AHBL") begin
    assign tgt1_ahbl_hsel_i      = 0;
    assign tgt1_ahbl_hready_i    = 0;
    assign tgt1_ahbl_haddr_i     = 0;
    assign tgt1_ahbl_hburst_i    = 0;
    assign tgt1_ahbl_hsize_i     = 0;
    assign tgt1_ahbl_hmastlock_i = 0;
    assign tgt1_ahbl_hprot_i     = 0;
    assign tgt1_ahbl_htrans_i    = 0;
    assign tgt1_ahbl_hwrite_i    = 0;
    assign tgt1_ahbl_hwdata_i    = 0;
  end
endgenerate

tb_lscc_i3c_target #
(
 // Parameters
 .SIMULATION                            (SIMULATION),
 .FAMILY                                (FAMILY),
 .INTERFACE                             (INTERFACE),
 .REG_MAPPING                           (REG_MAPPING),
 .CLKI_FREQ                             (SYS_CLK_PERIOD),
 .FIFO_LOOPBACK_EN                      (TGT_LOOPBK_EN1),
 .HDR_CAPABLE                           ( 1    ) ,
 .IBI_CAPABLE                           ( 1    ) ,
 .IBI_DATA_PAY                          ( 255  ) ,
 .HOTJOIN_CAPABLE                       ( 1    ) ,
 .MAX_D_SPEED_LIMIT                     ( 1    ) ,
 .DCR                                   ( 0    ) ,
 .PID_MANUF                             ( 414  ) ,
 .PID_PART                              ( 1    ) ,
 .PID_INST                              ( 11   ) ,
 .PID_ADD                               ( 0    ) ,
 .STATIC_ADDR_EN                        ( 1    ) ,
 .STATIC_ADDR                           ( 11   ) ,
 .MXDS_W                                ( 0    ) ,
 .MXDS_R                                ( 0    ) ,
 .MXDS_RD_TURN                          ( 0.0  ))
u_tgt_model_1
(
 // Inputs
 .clk_i                                 (clk_i),
 .rst_n_i                               (rst_n_i),
 .lmmi_request_i                        (tgt1_lmmi_request_i),
 .lmmi_offset_i                         (tgt1_lmmi_offset_i),
 .lmmi_wr_rdn_i                         (tgt1_lmmi_wr_rdn_i),
 .lmmi_wdata_i                          (tgt1_lmmi_wdata_i),
 .apb_psel_i                            (tgt1_apb_psel_i),
 .apb_penable_i                         (tgt1_apb_penable_i),
 .apb_paddr_i                           (tgt1_apb_paddr_i),
 .apb_pwrite_i                          (tgt1_apb_pwrite_i),
 .apb_pwdata_i                          (tgt1_apb_pwdata_i),
 .ahbl_hsel_i                           (tgt1_ahbl_hsel_i),
 .ahbl_hready_i                         (tgt1_ahbl_hready_i),
 .ahbl_haddr_i                          (tgt1_ahbl_haddr_i),
 .ahbl_hburst_i                         (tgt1_ahbl_hburst_i[2:0]),
 .ahbl_hsize_i                          (tgt1_ahbl_hsize_i[2:0]),
 .ahbl_hmastlock_i                      (tgt1_ahbl_hmastlock_i),
 .ahbl_hprot_i                          (tgt1_ahbl_hprot_i[3:0]),
 .ahbl_htrans_i                         (tgt1_ahbl_htrans_i[1:0]),
 .ahbl_hwrite_i                         (tgt1_ahbl_hwrite_i),
 .ahbl_hwdata_i                         (tgt1_ahbl_hwdata_i),
 .tx_valid_i                            (1'd0),
 .tx_data_i                             (8'd0),
 .rx_ready_i                            (1'd0),
 .ext_scl_i                             (1'd1),
 .ext_sda_i                             (1'd1),
 // Inouts
 .scl_io                                (tgt1_scl_io),
 .sda_io                                (tgt1_sda_io),
 // Outputs
 .lmmi_ready_o                          (tgt1_lmmi_ready_o),
 .lmmi_rdata_valid_o                    (tgt1_lmmi_rdata_valid_o),
 .lmmi_rdata_o                          (tgt1_lmmi_rdata_o),
 .lmmi_error_o                          (tgt1_lmmi_error_o),
 .apb_pready_o                          (tgt1_apb_pready_o),
 .apb_prdata_o                          (tgt1_apb_prdata_o),
 .apb_pslverr_o                         (tgt1_apb_pslverr_o),
 .ahbl_hreadyout_o                      (tgt1_ahbl_hreadyout_o),
 .ahbl_hresp_o                          (tgt1_ahbl_hresp_o),
 .ahbl_hrdata_o                         (tgt1_ahbl_hrdata_o),
 .tx_ready_o                            (),
 .rx_valid_o                            (),
 .rx_data_o                             (),
 .ext_sda_o                             (),
 .ext_sda_oe                            (),
 .int_o                                 (tgt1_int_o),
 .tgt_rst_o                             (tgt1_tgt_rst_o));
`endif


`ifdef EN_I3C_SC0
wire                                  sc0_lmmi_request_i;
wire        [LMMI_AWID-1:0]           sc0_lmmi_offset_i;
wire                                  sc0_lmmi_wr_rdn_i;
wire        [LMMI_DWID-1:0]           sc0_lmmi_wdata_i;
wire                                  sc0_lmmi_ready_o;
wire                                  sc0_lmmi_rdata_valid_o;
wire        [LMMI_DWID-1:0]           sc0_lmmi_rdata_o;
wire                                  sc0_lmmi_error_o;
wire                                  sc0_apb_psel_i;
wire                                  sc0_apb_penable_i;
wire        [BUS_WIDTH-1:0]           sc0_apb_paddr_i;
wire                                  sc0_apb_pwrite_i;
wire        [BUS_WIDTH-1:0]           sc0_apb_pwdata_i;
wire                                  sc0_apb_pready_o;
wire        [BUS_WIDTH-1:0]           sc0_apb_prdata_o;
wire                                  sc0_apb_pslverr_o;
wire                                  sc0_ahbl_hsel_i;
wire                                  sc0_ahbl_hready_i;
wire        [BUS_WIDTH-1:0]           sc0_ahbl_haddr_i;
wire        [2:0]                     sc0_ahbl_hburst_i;
wire        [2:0]                     sc0_ahbl_hsize_i;
wire                                  sc0_ahbl_hmastlock_i;
wire        [3:0]                     sc0_ahbl_hprot_i;
wire        [1:0]                     sc0_ahbl_htrans_i;
wire                                  sc0_ahbl_hwrite_i;
wire        [BUS_WIDTH-1:0]           sc0_ahbl_hwdata_i;
wire                                  sc0_ahbl_hreadyout_o;
wire                                  sc0_ahbl_hresp_o;
wire        [BUS_WIDTH-1:0]           sc0_ahbl_hrdata_o;
wire                                  sc0_int_o;
wire                                  sc0_sc_rst_o;

generate
  if(INTERFACE != "LMMI") begin
    assign sc0_lmmi_request_i = 0;
    assign sc0_lmmi_offset_i  = 0;
    assign sc0_lmmi_wr_rdn_i  = 0;
    assign sc0_lmmi_wdata_i   = 0;
  end
  if(INTERFACE != "APB") begin
    assign sc0_apb_psel_i    = 0;
    assign sc0_apb_penable_i = 0;
    assign sc0_apb_paddr_i   = 0;
    assign sc0_apb_pwrite_i  = 0;
    assign sc0_apb_pwdata_i  = 0;
  end
  if(INTERFACE != "AHBL") begin
    assign sc0_ahbl_hsel_i      = 0;
    assign sc0_ahbl_hready_i    = 0;
    assign sc0_ahbl_haddr_i     = 0;
    assign sc0_ahbl_hburst_i    = 0;
    assign sc0_ahbl_hsize_i     = 0;
    assign sc0_ahbl_hmastlock_i = 0;
    assign sc0_ahbl_hprot_i     = 0;
    assign sc0_ahbl_htrans_i    = 0;
    assign sc0_ahbl_hwrite_i    = 0;
    assign sc0_ahbl_hwdata_i    = 0;
  end
endgenerate

/*tb_c_lscc_i3c_controller AUTO_TEMPLATE
(
 .SIMULATION                            (SIMULATION),
 .FAMILY                                (FAMILY),
 .DEVICE_ROLE                           (0),
 .ENABLE_SMI                            (1),
 .ENABLE_IBI                            (1),
 .ENABLE_HJI                            (1),
 .ENABLE_HDR_DDR                        (1),
 .SEL_INTF                              (SEL_INTF),
 .REG_MAPPING                           (REG_MAPPING),
 .EN_FIFOINTF                           (0),
 .TXDWID                                (8),
 .RXDWID                                (8),
 .CLKDOMAIN                             (CLKDOMAIN),
 .USE_INTCLKDIV                         (USE_INTCLKDIV),
 .TIMEOUT_100US                         (TIMEOUT_100US),
 .DEFAULT_RATE                          (DEFAULT_RATE),
 .DEFAULT_ODTIMER                       (DEFAULT_ODTIMER),
 .EN_DYN_I2C_SWITCHING                  (EN_DYN_I2C_SWITCHING),
 .I2C_RATE                              (I2C_RATE),
 .IBI_DATA_PAY                          (255),
 .MAX_D_SPEED_LIMIT                     (0),
 .DCR                                   (0),
 .PID_MANUF                             (414),
 .PID_PART                              (1),
 .PID_INST                              (9),
 .PID_ADD                               (0),
 .STATIC_ADDR_EN                        (1),
 .STATIC_ADDR                           (9),
 .CLKI_FREQ                             (SYS_CLK_PERIOD),
 .MXDS_W                                (0),
 .MXDS_R                                (0),
 .MXDS_TSCO                             (0),
 .MXDS_RD_TURN                          (0),
 .clk_i                                 (clk_i),
 .src_clk_scl_i                         (src_clk_scl_i),
 .rst_n_i                               (rst_n_i),
 .scl_io                                (sc0_scl_io),
 .sda_io                                (sc0_sda_io),
 .tx_valid_i                            (1'd0),
 .tx_data_i                             (8'd0),
 .rx_ready_i                            (1'd0),
 .tx_ready_o                            (),
 .rx_valid_o                            (),
 .rx_data_o                             (),
 .\(.*\)                                (sc@_\1[]),
);*/


tb_c_lscc_i3c_controller #
(
 // Parameters
 .SIMULATION                            (SIMULATION),
 .FAMILY                                (FAMILY),
 .DEVICE_ROLE                           (~DEVICE_ROLE[0]),
 .ENABLE_SMI                            (1),
 .ENABLE_IBI                            (1),
 .ENABLE_HJI                            (1),
 .ENABLE_HDR_DDR                        (1),
 .SEL_INTF                              (SEL_INTF),
 .REG_MAPPING                           (REG_MAPPING),
 .CLKDOMAIN                             (CLKDOMAIN),
 .USE_INTCLKDIV                         (USE_INTCLKDIV),
 .DEFAULT_RATE                          (DEFAULT_RATE),
 .I2C_RATE                              (I2C_RATE),
 .DEFAULT_ODTIMER                       (DEFAULT_ODTIMER),
 .EN_DYN_I2C_SWITCHING                  (EN_DYN_I2C_SWITCHING),
 .EN_FIFOINTF                           (0),
 .TXDWID                                (8),
 .RXDWID                                (8),
 .TIMEOUT_100US                         (TIMEOUT_100US),
 .IBI_DATA_PAY                          (255),
 .MAX_D_SPEED_LIMIT                     (0),
 .DCR                                   (0),
 .PID_MANUF                             (414),
 .PID_PART                              (1),
 .PID_INST                              (9),
 .PID_ADD                               (0),
 .STATIC_ADDR_EN                        (1),
 .STATIC_ADDR                           (9),
 .CLKI_FREQ                             (SYS_CLK_PERIOD),
 .MXDS_W                                (0),
 .MXDS_TSCO                             (0),
 .MXDS_R                                (0),
 .MXDS_RD_TURN                          (0))
u_sc_model_0
(
 // Inputs
 .clk_i                                 (clk_i),
 .rst_n_i                               (rst_n_i),
 .src_clk_scl_i                         (src_clk_scl_i),
 .tx_valid_i                            (1'd0),
 .tx_data_i                             (8'd0),
 .rx_ready_i                            (1'd0),
 .lmmi_request_i                        (sc0_lmmi_request_i),
 .lmmi_offset_i                         (sc0_lmmi_offset_i),
 .lmmi_wr_rdn_i                         (sc0_lmmi_wr_rdn_i),
 .lmmi_wdata_i                          (sc0_lmmi_wdata_i),
 .apb_psel_i                            (sc0_apb_psel_i),
 .apb_penable_i                         (sc0_apb_penable_i),
 .apb_paddr_i                           (sc0_apb_paddr_i),
 .apb_pwrite_i                          (sc0_apb_pwrite_i),
 .apb_pwdata_i                          (sc0_apb_pwdata_i),
 .ahbl_hsel_i                           (sc0_ahbl_hsel_i),
 .ahbl_hready_i                         (sc0_ahbl_hready_i),
 .ahbl_haddr_i                          (sc0_ahbl_haddr_i),
 .ahbl_hburst_i                         (sc0_ahbl_hburst_i[2:0]),
 .ahbl_hsize_i                          (sc0_ahbl_hsize_i[2:0]),
 .ahbl_hmastlock_i                      (sc0_ahbl_hmastlock_i),
 .ahbl_hprot_i                          (sc0_ahbl_hprot_i[3:0]),
 .ahbl_htrans_i                         (sc0_ahbl_htrans_i[1:0]),
 .ahbl_hwrite_i                         (sc0_ahbl_hwrite_i),
 .ahbl_hwdata_i                         (sc0_ahbl_hwdata_i),
 .ext_io_scl_i                          (1'b1),
 .ext_io_sda_i                          (1'b1),
 // Inouts
 .scl_io                                (sc0_scl_io),
 .sda_io                                (sc0_sda_io),
 // Outputs
 .tx_ready_o                            (),
 .rx_valid_o                            (),
 .rx_data_o                             (),
 .lmmi_ready_o                          (sc0_lmmi_ready_o),
 .lmmi_rdata_valid_o                    (sc0_lmmi_rdata_valid_o),
 .lmmi_rdata_o                          (sc0_lmmi_rdata_o),
 .lmmi_error_o                          (sc0_lmmi_error_o),
 .apb_pready_o                          (sc0_apb_pready_o),
 .apb_prdata_o                          (sc0_apb_prdata_o),
 .apb_pslverr_o                         (sc0_apb_pslverr_o),
 .ahbl_hreadyout_o                      (sc0_ahbl_hreadyout_o),
 .ahbl_hresp_o                          (sc0_ahbl_hresp_o),
 .ahbl_hrdata_o                         (sc0_ahbl_hrdata_o),
 .int_o                                 (sc0_int_o),
 .sc_rst_o                              (sc0_sc_rst_o),
 .ext_io_scl_oe                         (),
 .ext_io_sda_oe                         (),
 .ext_io_scl_o                          (),
 .ext_io_sda_o                          (),
 .ext_io_sda_spu_n                      (),
 .ext_io_scl_spu_n                      (),
 .ext_io_sda_wpu_n                      (),
 .ext_io_scl_wpu_n                      ()
 );

`endif

generate
  if(ENABLE_IO_PRIMITIVE == 0) begin : gen_no_prim
    assign ext_io_scl_i = scl_io;
    assign ext_io_sda_i = sda_io;
    assign scl_io       = (ext_io_scl_oe)? ext_io_scl_o : ((~ext_io_scl_spu_n | ~ext_io_scl_wpu_n)? 1'b1 : 1'bz);
    assign sda_io       = (ext_io_sda_oe)? ext_io_sda_o : ((~ext_io_sda_spu_n | ~ext_io_sda_wpu_n)? 1'b1 : 1'bz);
  end // gen_no_prim
endgenerate

endmodule //--i3c_device_inst--
`endif // __RTL_MODULE__I3C_DEVICE_INST__
//--------------------------------------------------------------------------
// Local Variables:
// verilog-library-directories: (".")
// verilog-library-files: ("./tb_models.v")
// End:
//--------------------------------------------------------------------------
