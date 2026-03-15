module i3c_bfm_lmmi
(
 input                         clk_i                // clock
,input                         rst_n_i              // active low reset

,input                         lmmi_ready_i         // slave is ready to start new transaction
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

    $display("%12d: [write] addr %2x data %2x",$stime, addr, data);
end
endtask

task memr;
input   [7:0]   addr;
input   [7:0]   chk;
input           verify;
output  [7:0]   rdata;
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
        $display("%12d: [Error] addr %2x data %2x != exp %2x",$stime, addr, lmmi_rdata_i, chk);
    else
        $display("%12d: [read] addr %2x data %2x",$stime, addr, lmmi_rdata_i);
end
endtask

endmodule // i3c_bfm_lmmi

module i3c_bfm_apb # (
 parameter                              TB_APB_AWID = 32
,parameter                              TB_APB_DWID = 32
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
    PADDR = {TB_APB_AWID{1'h0}};
    PWDATA = {TB_APB_DWID{1'h0}};
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
        PWDATA = {TB_APB_DWID{1'h0}};
    end

    $display("%12d: [write] addr %8x data %8x",$stime, addr, data);
end
endtask

task memr;
input   [TB_APB_AWID-1:0]  addr;
input   [TB_APB_DWID-1:0]  chk;
input                      verify;
output  [TB_APB_DWID-1:0]  rdata;
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
        $display("%12d: [Error] addr %8x data %8x != exp %8x",$stime, addr, PRDATA, chk);
    else
        $display("%12d: [read] addr %8x data %8x",$stime, addr, PRDATA);
end
endtask

endmodule // i3c_bfm_apb

module i3c_bfm_ahbl #
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


reg           [TB_AHBL_DWID-1:0]           ahbl_nxt_data;

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
reg                     ready,resp;
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

    $display("%12d: [write] addr %8x data %8x",$stime, addr, data);
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
input                     verify;
output  [TB_AHBL_DWID-1:0]   rdata;
reg                       ready,resp;
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
        $display("%12d: [Error] addr %8x data %8x != exp %8x",$stime, addr, rdata, chk);
    else
        $display("%12d: [read] addr %8x data %8x",$stime, addr, rdata);
end
endtask

endmodule // i3c_bfm_ahbl

module i3c_bfm_stream #
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

    $display("%12d: [Write] Tx data %2x",$stime, data);
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
        $display("%12d: [ERROR] Rx data %2x != exp %2x",$stime, rdata, chk);
    else
        $display("%12d: [Read] Rx data %2x",$stime, rdata);
end
endtask

endmodule // i3c_bfm_stream
