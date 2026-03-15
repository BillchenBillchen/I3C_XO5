# I3C Target Simulation Script for ModelSim
# ========================================

# 建立並對應 work library
if {![file exists work]} {
    vlib work
}
vmap work work

# 編譯 RTL 原始檔
# 請依據專案結構確認相對路徑 (目前設定為 ../rtl)
vlog -work work ../rtl/I3C_target_inst.v

# 編譯 Testbench 相關檔案
# tb_top.v 裡面包含了 `include 其他 tb_models.v, tb_bfm.v, dut_params.v 等
# 加上 +incdir+. 以及 +incdir+../eval 來指定標頭檔搜尋路徑
vlog -work work +incdir+. +incdir+../eval tb_top.v

# 啟動模擬環境 (vsim)
# LFMXO5 (MachXO5-NX) 需要 ovi_machxo5 與 pmi_work library
# 請確保您的 ModelSim 環境已經編譯好 Lattice 的 primitive libraries
vsim -L ovi_machxo5 -L pmi_work -voptargs=+acc work.tb_top

# 將 testbench 的最上層訊號全部加入波形視窗
add wave -group "TB Top" /tb_top/*

# 加入 I3C Master (i3c_m) 的所有訊號
# u_ctl_model 實現了 i3c_m.v 的邏輯
add wave -group "i3c_m Master" /tb_top/u_ctl_model/*
add wave -group "i3c_m Internal" -recursive /tb_top/u_ctl_model/*


# 執行所有模擬直到遇到 $stop
run -all
