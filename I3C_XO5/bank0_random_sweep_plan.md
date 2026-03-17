# Bank 0 隨機腳位組合測試計畫 (Random Pin Sweep)

## 1. 目標
從 MachXO5-NX 開發板 Bank 0 且有引出至 Header 的腳位中，隨機抽取組合進行 I3C 通訊測試。這可以用於過濾出哪些腳位在硬體上確實連通且訊號品質最穩定。

## 2. Bank 0 腳位池 (Pin Pool)
根據手冊與腳位表篩選出的可用清單：

*   **PMOD2 (J16)**: `C1`, `E4`, `B2`, `B1`, `E3`, `D3`, `F4`, `G4`
*   **Versa Header (J9)**: `D1`, `A2`, `A6`, `B6`, `C6`, `D6`, `A5`, `B5`, `C5`, `D5`, `A4`, `B4`, `C4`, `D4`, `A3`, `B3`, `C3`
*   **I3C Origin**: `G9`, `G8`, `G7`, `H8`

**總計 29 個候選腳位。**

## 3. 執行策略 (給後續 AI)

### A. 隨機生成邏輯
1. 從腳位池中不重複隨機選取 4 個腳：
   - `$M0_SCL`, `$M0_SDA`, `$S0_SCL`, `$S0_SDA`
2. 使用 [pin_custom_tests.ps1](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/pin_custom_tests.ps1) 的底層模板，自動將位址填入 PDC 檔案。
3. 批次產生 $N$ 套 (建議 $N=10$) 不同的 Bitstream。

### B. 自動化腳本規範 (`pin_random_sweep.ps1`)
腳本應具備：
- **洗牌機制 (Shuffle)**：確保每次隨機性。
- **防止衝突**：同一組配置中，四個埠不能使用相同腳位。
- **命名規則**：日誌需記錄每個版本對應的隨機腳位，以利燒錄後對照。

## 4. 驗證細節
- 每個版本需保留 PAR 與 Timing 報告。
- 使用者燒錄後觀察 LED。若 LED 進度推向 LED1 (DAA 成功)，則該組合為「聖杯組合」。

## 5. 檔案結構建議
- `output/Random_Tests/`
  - `v1_SCL_D3_SDA_E4.../`
  - `v2_.../`
  - `random_run_map.log` (標註各版本腳位)
