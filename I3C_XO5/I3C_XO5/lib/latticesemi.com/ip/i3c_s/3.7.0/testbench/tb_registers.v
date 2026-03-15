`define SEC_CTL_CAPABLE 1'b0

`define TGT_ADR_BCR               {`SEC_CTL_CAPABLE, 7'h00}
`define TGT_ADR_DCR               {`SEC_CTL_CAPABLE, 7'h01}
`define TGT_ADR_DYN_ADDR          {`SEC_CTL_CAPABLE, 7'h02}
`define TGT_ADR_HJ_IBI_EN         {`SEC_CTL_CAPABLE, 7'h03}
`define TGT_ADR_HJ_IBI_CAP        {`SEC_CTL_CAPABLE, 7'h04}
`define TGT_ADR_HJ_IBI_REQ        {`SEC_CTL_CAPABLE, 7'h05}
`define TGT_ADR_HJ_IBI_RETRY      {`SEC_CTL_CAPABLE, 7'h06}
`define TGT_ADR_MWL_MSB           {`SEC_CTL_CAPABLE, 7'h07}
`define TGT_ADR_MWL_LSB           {`SEC_CTL_CAPABLE, 7'h08}
`define TGT_ADR_MRL_MSB           {`SEC_CTL_CAPABLE, 7'h09}
`define TGT_ADR_MRL_LSB           {`SEC_CTL_CAPABLE, 7'h0A}
`define TGT_ADR_MAX_IBI_PAYLD     {`SEC_CTL_CAPABLE, 7'h0B}
`define TGT_ADR_MXDS2_W           {`SEC_CTL_CAPABLE, 7'h0C}
`define TGT_ADR_MXDS2_R           {`SEC_CTL_CAPABLE, 7'h0D}
`define TGT_ADR_MAX_RDTURN_B2     {`SEC_CTL_CAPABLE, 7'h0E}
`define TGT_ADR_MAX_RDTURN_B1     {`SEC_CTL_CAPABLE, 7'h0F}
`define TGT_ADR_MAX_RDTURN_B0     {`SEC_CTL_CAPABLE, 7'h10}
`define TGT_ADR_PID5              {`SEC_CTL_CAPABLE, 7'h11}
`define TGT_ADR_PID4              {`SEC_CTL_CAPABLE, 7'h12}
`define TGT_ADR_PID3              {`SEC_CTL_CAPABLE, 7'h13}
`define TGT_ADR_PID2              {`SEC_CTL_CAPABLE, 7'h14}
`define TGT_ADR_PID1              {`SEC_CTL_CAPABLE, 7'h15}
`define TGT_ADR_PID0              {`SEC_CTL_CAPABLE, 7'h16}
`define TGT_ADR_STAT_ADDR         {`SEC_CTL_CAPABLE, 7'h17}
`define TGT_ADR_GETCAPS_B1        {`SEC_CTL_CAPABLE, 7'h18}
`define TGT_ADR_GETCAPS_B2        {`SEC_CTL_CAPABLE, 7'h19}
`define TGT_ADR_GETCAPS_B3        {`SEC_CTL_CAPABLE, 7'h1A}
`define TGT_ADR_OSC_INACCURACY    {`SEC_CTL_CAPABLE, 7'h1C}
`define TGT_ADR_RX_FIFO           {`SEC_CTL_CAPABLE, 7'h20}
`define TGT_ADR_TX_FIFO           {`SEC_CTL_CAPABLE, 7'h22}
`define TGT_ADR_SOFT_RESET        {`SEC_CTL_CAPABLE, 7'h28}
`define TGT_ADR_TGT_ACKNAK        {`SEC_CTL_CAPABLE, 7'h29}
`define TGT_ADR_GETSTATUS_MSB     {`SEC_CTL_CAPABLE, 7'h2A}
`define TGT_ADR_GETSTATUS_LSB     {`SEC_CTL_CAPABLE, 7'h2B}
`define TGT_ADR_BUS_ACT_STATE     {`SEC_CTL_CAPABLE, 7'h2C}
`define TGT_ADR_TGT_RST_ACT0      {`SEC_CTL_CAPABLE, 7'h2D}
`define TGT_ADR_TGT_RST_ACT1      {`SEC_CTL_CAPABLE, 7'h2E}
`define TGT_ADR_TGT_RST_ACT2      {`SEC_CTL_CAPABLE, 7'h2F}
`define TGT_ADR_STAT1_INT         {`SEC_CTL_CAPABLE, 7'h30}
`define TGT_ADR_STAT1_INT_EN      {`SEC_CTL_CAPABLE, 7'h31}
`define TGT_ADR_STAT1_INT_SET     {`SEC_CTL_CAPABLE, 7'h32}
`define TGT_ADR_STAT2_INT         {`SEC_CTL_CAPABLE, 7'h33}
`define TGT_ADR_STAT2_INT_EN      {`SEC_CTL_CAPABLE, 7'h34}
`define TGT_ADR_STAT2_INT_SET     {`SEC_CTL_CAPABLE, 7'h35}
`define TGT_ADR_STAT3_INT         {`SEC_CTL_CAPABLE, 7'h36}
`define TGT_ADR_STAT3_INT_EN      {`SEC_CTL_CAPABLE, 7'h37}
`define TGT_ADR_STAT3_INT_SET     {`SEC_CTL_CAPABLE, 7'h38}
`define TGT_ADR_STAT4_INT         {`SEC_CTL_CAPABLE, 7'h39}
`define TGT_ADR_STAT4_INT_EN      {`SEC_CTL_CAPABLE, 7'h3A}
`define TGT_ADR_STAT4_INT_SET     {`SEC_CTL_CAPABLE, 7'h3B}
`define TGT_ADR_STAT5_INT         {`SEC_CTL_CAPABLE, 7'h3C}
`define TGT_ADR_STAT5_INT_EN      {`SEC_CTL_CAPABLE, 7'h3D}
`define TGT_ADR_STAT5_INT_SET     {`SEC_CTL_CAPABLE, 7'h3E}
`define TGT_ADR_DEFTGTS_COUNT     {`SEC_CTL_CAPABLE, 7'h40}
`define TGT_ADR_DEFTGTS_RXFIFO_S  {`SEC_CTL_CAPABLE, 7'h41}
`define TGT_ADR_DEFTGTS_RXFIFO_C  {`SEC_CTL_CAPABLE, 7'h42}
`define TGT_ADR_CTL_HANDOFF       {`SEC_CTL_CAPABLE, 7'h43}
`define TGT_ADR_GETMXDS_CRHDLY    {`SEC_CTL_CAPABLE, 7'h44}
`define TGT_ADR_GETSTATUS_PRECR   {`SEC_CTL_CAPABLE, 7'h45}
`define TGT_ADR_GETCAPS_CRCAP1    {`SEC_CTL_CAPABLE, 7'h46}
`define TGT_ADR_GETCAPS_CRCAP2    {`SEC_CTL_CAPABLE, 7'h47}
`define TGT_ADR_DEVICE_ROLE       {`SEC_CTL_CAPABLE, 7'h48}
`define TGT_ADR_BUS_MODE          {`SEC_CTL_CAPABLE, 7'h50}
`define TGT_ADR_HDR_DDR_CONFIG    {`SEC_CTL_CAPABLE, 7'h51}
`define TGT_ADR_HDR_DDR_ABORT     {`SEC_CTL_CAPABLE, 7'h54}

`define CTL_ADR_CLKDIV            8'h01
`define CTL_ADR_MSTCFG0           8'h02
`define CTL_ADR_ODTIMER           8'h03
`define CTL_ADR_I2C_DIV           8'h04
`define CTL_ADR_SPUWPU            8'h05
`define CTL_ADR_HDRCFG0           8'h06
`define CTL_ADR_SOFTRST           8'h08
`define CTL_ADR_MSTADDR           8'h10
`define CTL_ADR_TXSTART           8'h11
`define CTL_ADR_DDRV_CTRL         8'h12
`define CTL_ADR_DDRV_RSDA         8'h13 // read only
`define CTL_ADR_DDRV_RSCL         8'h14 // read only
`define CTL_ADR_SC_STAT           8'h15 // read only
`define CTL_ADR_SC_ROLE           8'h16
`define CTL_ADR_SC_TIMER0         8'h17
`define CTL_ADR_SC_TIMER1         8'h18
`define CTL_ADR_SC_TIMER2         8'h19
`define CTL_ADR_DONE_CNT0         8'h1A // status - rwc1
`define CTL_ADR_DONE_CNT1         8'h1B // status - rwc1
`define CTL_ADR_DA_ACKED          8'h1C // status - rwc1
`define CTL_ADR_IBIRCNT           8'h1D
`define CTL_ADR_IBIRESP           8'h1E
`define CTL_ADR_IBIADDR           8'h1F // read only
`define CTL_ADR_INTSTAT0          8'h20
`define CTL_ADR_INTSET0           8'h21 // write only, dummy register
`define CTL_ADR_INTENA0           8'h22
`define CTL_ADR_NAKINFO           8'h23 // status info - rwc1
`define CTL_ADR_INTSTAT1          8'h24
`define CTL_ADR_INTSET1           8'h25 // write only, dummy register
`define CTL_ADR_INTENA1           8'h26
`define CTL_ADR_INTSTAT2          8'h2C
`define CTL_ADR_INTSET2           8'h2D // write only, dummy register
`define CTL_ADR_INTENA2           8'h2E
`define CTL_ADR_BUSCOND           8'h28 // read only
`define CTL_ADR_LASTNAKADR        8'h29
`define CTL_ADR_LASTACKADR        8'h2A
`define CTL_ADR_TXFIFO            8'h30 // read only - empty status
`define CTL_ADR_RXFIFO            8'h40
