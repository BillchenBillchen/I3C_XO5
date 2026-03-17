# I3C XO5 專案觸發與腳位調試經驗總結 (Inheritance Manual)

這是為了讓後續接手的 AI 助手能夠快速理解目前專案進度、已解決問題及剩餘挑戰的紀錄文檔。

## 1. 專案背景與目標
- **硬體平台**: Lattice Radiant XO5 FPGA.
- **目標**: 實作 I3C Master 與 Slave 的內部 Loopback 通訊。
- **當前問題**: 模擬 (VCD) 流程完美，但硬體 DAA (Dynamic Address Assignment) 階段失敗，Master 發出的信號異常且 Slave 無 ACK。

## 2. 關鍵技術發現

### 2.1 硬體波形異常分析 (Deadly Differences)
- **異常位址**: 硬體截圖顯示 Master 送出的是 `0xF2` (11110010)，而正標標準應為 `0xFC` (`0x7E` + W)。
- **驅動模式**: 在廣播階段應為 **Open-Drain (OD)** 模式，但硬體觀察到 Master 強行驅動 SDA (`sda_oe` = 1)，屬於錯誤的 Push-Pull 行為。
- **sda_spu (Strong Pull-Up)**: 發現 `sda_spu` 信號在 DAA 期間跳變，此信號為 Active-Low（0 代表開啟）。

### 2.2 韌體 (C Code) 陷阱
- **Target 被註解**: 發現 [sw_I3C_XO5\gpi_i3c_led\src\main.c](file:///C:/Users/billzhang/Desktop/I3C_XO5/sw_I3C_XO5/gpi_i3c_led/src/main.c) 核心的 `i3c_target_init()` 程式碼被註解。
- **結論**: Target IP 必須由 CPU 透過暫存器「喚醒」與「使能」，否則硬體會處於無視狀態，導致 Master 讀不到 ACK。

### 2.3 核心差異對比 (XO5 vs CPNX)
- **RISC-V 版本**: XO5 使用的是 `riscv_mc` 2.8.1 (有完整的 .ipx)；CPNX 參考專案則是以黑盒子 (Black-box) 形式引用，版本可能存在時序 (Bus Timing) 上的細微差異。

## 3. 自動化除錯工具鏈 (Automation Scripts)

我們建立了一套在 Windows PowerShell 環境下運作的自動化編譯流程，用於快速測試不同腳位 (Pin Sweep) 的可行性。

### 3.1 核心腳本清單
- **[pin_sweep_map.tcl](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/pin_sweep_map.tcl) / [_par.tcl](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/pin_sweep_par.tcl) / [_bit.tcl](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/impl_1/pin_sweep_bit.tcl)**: 
  - **重要**: 必須拆分為三個獨立行程執行。若放在同一個 TCL session 中連跑，`radiantc` 會發生 UDB 檔案占用或讀取錯誤版本 (Map 讀到 Syn) 的 Bug。
- **[pin_custom_tests.ps1](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/pin_custom_tests.ps1)**:
  - **跨版本穩化寫法**: 由於不同環境的 PowerShell 對巢狀雜湊表語法容忍度不同，必須使用 `New-Object System.Collections.ArrayList` 和 `PSObject` 的原始寫法，以避免 `Unexpected token` 或 `Item has already been added` 錯誤。

## 4. 後續執行建議
1. **執行 [pin_custom_tests.ps1](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/pin_custom_tests.ps1)**: 驗證「原版」、「D3 版」與「對調版」的硬體表現。
2. **Reveal Analyzer 監控方向**:
   - 抓取 Master 的 **FSM 狀態機信號** (`tx_state`)。
   - 監控 **APB Bus**，確認 CPU 寫入暫存器的 `0x7E` 指令是否正確到達 Master 控制器，還是被中間的 Bus 邏輯扭曲成 `0xF2`。
   - 檢查 `sda_i` (Input) 是否受雜訊影響導致 Master 誤判仲裁失敗 (Lost Arbitration)。

---
**AI 繼承提示**: 
所有的 bitstream 輸出均位於 `C:\Users\billzhang\Desktop\I3C_XO5\I3C_XO5\output\`。
調試重點應聚焦於：為什麼硬體發出的 bit pattern 與韌體下的指令不一致？
