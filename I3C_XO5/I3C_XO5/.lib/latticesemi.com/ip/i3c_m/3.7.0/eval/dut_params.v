localparam DEVICE_ROLE = 1;
localparam FAMILY = "LFMXO5";
localparam ENABLE_SMI = 0;
localparam ENABLE_IBI = 1;
localparam ENABLE_HJI = 1;
localparam ENABLE_HDR_DDR = 0;
localparam SEL_INTF = "APB";
localparam REG_MAPPING = 1;
localparam MEM_IMPL = "EBR";
localparam FIFO_DEPTH = 512;
localparam EN_FIFOINTF = 0;
localparam TXDWID = 8;
localparam RXDWID = 8;
localparam CLKDOMAIN = "ASYNC";
localparam USE_INTCLKDIV = 1;
localparam TIMEOUT_100US = 2500;
localparam DEFAULT_RATE = 0;
localparam DEFAULT_ODTIMER = 3;
localparam EN_DYN_I2C_SWITCHING = 1;
localparam I2C_RATE = 12;
localparam ENABLE_IO_PRIMITIVE = 1;
localparam IBI_DATA_PAY = 1;
localparam MAX_D_SPEED_LIMIT = 1;
localparam DCR = 0;
localparam PID_MANUF = 414;
localparam PID_PART = 1;
localparam PID_INST = 1;
localparam PID_ADD = 0;
localparam STATIC_ADDR_EN = 1;
localparam STATIC_ADDR = 8;
localparam DYNAMIC_ADDR = 8;
localparam CLKI_FREQ = 25;
localparam MXDS_W = 0;
localparam MXDS_TSCO = 0;
localparam MXDS_R = 0;
localparam MXDS_RD_TURN = 0;
`define jd5f00
`define LFMXO5
`define LFMXO5_25
`define DUT_INST_NAME i3c_m
`define BFM_PATH tb_top.gen_bfm_1
`define EN_FIFOINTF_M False
`define SYSCLK_FREQ 25.0
`define CORECLK_FREQ 25.0
`define EXT_SCL_FREQ 12.5
