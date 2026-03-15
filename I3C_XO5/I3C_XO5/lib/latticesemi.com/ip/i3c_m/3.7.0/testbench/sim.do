# ==============================================================================
# ModelSim / QuestaSim Simulation Script
# ==============================================================================

# 建立 work 函式庫
vlib work
vmap work work

# 編譯 RTL 原始檔 (I3C IP 的主程式)
vlog -work work ../rtl/i3c_m.v

# 編譯 Lattice MachXO5 基礎元件庫 (GSR, BB_I3C_A 等)
vlog -work work -sv C:/lscc/radiant/2025.2/cae_library/simulation/verilog/lfmxo5/*.v
vlog -work work -sv C:/lscc/radiant/2025.2/cae_library/simulation/verilog/pmi/*.v

# 編譯 Testbench 的相關檔案 (旁邊的 *.v 檔案)
# 注意: dut_params.v, dut_inst.v, i3c_device_inst.v, tb_models.v 都是由 tb_top.v 引入，因此不需要單獨編譯
vlog -work work tb_top.v

# 啟動模擬，載入 top testbench module (使用 +acc 確保能看到內部信號)
vsim -voptargs=+acc work.tb_top

# 將 tb_top 上的所有信號加入波形視窗
add wave -position insertpoint sim:/tb_top/*

# 如果需要看子模組的訊號，也可以手動在這裡加入，例如:
# add wave -position insertpoint sim:/tb_top/u_i3c_m/*

# 執行模擬
run -all
