`define GATE_SIM

`define CTL_BFM_INST                                 `TGT_BFM_PATH.ctl_reg_intf_bfm
`define TGT_BFM_INST                                 `TGT_BFM_PATH.tgt_reg_intf_bfm

`define CTL_BFM_FFW(WDATA)                           tb_top.ctl_fifo_intf_bfm.memw(WDATA);
`define CTL_BFM_FFR(EXPDATA,VERIFY,RDATA)            tb_top.ctl_fifo_intf_bfm.memr(EXPDATA,VERIFY,RDATA);

`define TGT_BFM_FFW(WDATA)                           tb_top.tgt_fifo_intf_bfm.memw(WDATA);
`define TGT_BFM_FFR(EXPDATA,VERIFY,RDATA)            tb_top.tgt_fifo_intf_bfm.memr(EXPDATA,VERIFY,RDATA);

`define CTL_BFM_INIT                                  `CTL_BFM_INST.init
`define CTL_BFM_MEMW(ADDR,WDATA)                      if(EN_FIFOINTF) begin \
                                                        if(ADDR == `CTL_ADR_TXFIFO) \
                                                          `CTL_BFM_FFW(WDATA) \
                                                        else if(ADDR == `CTL_ADR_TXSTART) \
                                                          @(posedge clk_i); \
                                                        else \
                                                          `CTL_BFM_INST.memw(ADDR,WDATA); \
                                                      end \
                                                      else begin \
                                                        `CTL_BFM_INST.memw(ADDR,WDATA); \
                                                      end
`define CTL_BFM_MEMR(ADDR,EXPDATA,VERIFY,RDATA)       if(EN_FIFOINTF) begin \
                                                        if(ADDR == `CTL_ADR_RXFIFO) \
                                                          `CTL_BFM_FFR(EXPDATA,VERIFY,RDATA) \
                                                        else \
                                                          `CTL_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                      end \
                                                      else begin \
                                                        `CTL_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                      end

`define TGT_BFM_INIT                                  `TGT_BFM_INST.init

`define TGT_BFM_MEMW(ADDR,WDATA)                      if(EN_FIFOINTF) begin \
                                                        if(ADDR==`TGT_ADR_TX_FIFO) \
                                                          `TGT_BFM_FFW(WDATA) \
                                                        else \
                                                          `TGT_BFM_INST.memw(ADDR,WDATA); \
                                                      end \
                                                      else begin \
                                                        `TGT_BFM_INST.memw(ADDR,WDATA); \
                                                      end

`define TGT_BFM_MEMR(ADDR,EXPDATA,VERIFY,RDATA)       if(EN_FIFOINTF) begin \
                                                        if(ADDR==`TGT_ADR_RX_FIFO) \
                                                          `TGT_BFM_FFR(EXPDATA,VERIFY,RDATA) \
                                                        else \
                                                          `TGT_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                      end \
                                                      else begin \
                                                        `TGT_BFM_INST.memr(ADDR,EXPDATA,VERIFY,RDATA); \
                                                      end

`define DUT_HIER_PATH(ip_name)         u_``ip_name.lscc_i3c_target_inst