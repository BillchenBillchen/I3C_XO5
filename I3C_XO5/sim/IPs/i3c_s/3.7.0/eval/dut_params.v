localparam FAMILY = "LFMXO5";
localparam INTERFACE = "APB";
localparam REG_MAPPING = 1;
localparam MEM_IMPL = "EBR";
localparam FIFO_SIZE = 512;
localparam EN_FIFOINTF = 0;
localparam TXDWID = 8;
localparam RXDWID = 8;
localparam EN_IO_PRIM = 1;
localparam HDR_CAPABLE = 0;
localparam IBI_CAPABLE = 1;
localparam IBI_DATA_PAY = 1;
localparam HOTJOIN_CAPABLE = 1;
localparam MAX_D_SPEED_LIMIT = 1;
localparam DCR = 0;
localparam PID_MANUF = 414;
localparam PID_PART = 1;
localparam PID_INST = 1;
localparam PID_ADD = 0;
localparam STATIC_ADDR_EN = 0;
localparam STATIC_ADDR = 8;
localparam CLKI_FREQ = 25;
localparam CLKI_FREQ_BYTE = 50;
localparam MXDS_W = 0;
localparam MXDS_TSCO = 0;
localparam MXDS_R = 0;
localparam MXDS_RD_TURN = 0;
`define jd5f00
`define LFMXO5
`define LFMXO5_25
`define EN_FIFOINTF_M False
`define DUT_INST_NAME i3c_s
`define TGT_BFM_PATH tb_top.gen_bfm_1
`define SYSCLK_FREQ 25.0
