# I3C Target IP Simulation Setup Plan

This plan outlines the steps to create a simulation environment for the I3C Target (Slave) IP, following the methodology used for the I3C Master IP.

## Proposed Changes

### Simulation Setup
Create a new simulation workspace for the I3C Target IP.

#### [NEW] [sim_target.f](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/sim_target/sim_target.f)
- Define library mappings (`-L work`, `-reflib pmi_work`, `-reflib ovi_lfmxo5`).
- Set SystemVerilog mode (`-sv`).
- Add include path: `sim/IPs/i3c_s/3.7.0/testbench`.
- List RTL source: `sim/IPs/i3c_s/3.7.0/rtl/i3c_s.v`.
- List Testbench sources:
    - `sim/IPs/i3c_s/3.7.0/testbench/dut_params.v`
    - `sim/IPs/i3c_s/3.7.0/testbench/tb_models.v`
    - `sim/IPs/i3c_s/3.7.0/testbench/tb_top.v`
- Set simulation options (suppress warnings, GUI mode, top module `tb_top`).
- Add initial run commands (view wave, add wave, run).

#### [NEW] [sim_target.vdo](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/sim_target/sim_target.vdo)
- Launch script to run `qrun` with `sim_target.f`.

## Verification Plan

### Automated Tests
- Run the simulation using the created `.vdo` script.
- Verify that the simulation initializes correctly (I3C Target Initialization, etc.).
- Check for "ERROR" or "FAILURE" messages in the simulation transcript.

### Manual Verification
- Open the waveform viewer and confirm that the I3C bus signals (`scl_io`, `sda_io`) are toggling.
- Confirm that the I3C Target responds to the Controller's commands (e.g., ENTDAA).

---

## 硬體調試紀錄 (2026-03-16)

### 問題現象
- 模擬 (vsim.wlf / transcript) 流程完全正確，DAA 可在 `t=1,947,460 ns ~ t=2,007,580 ns` 完成，Dynamic Address 成功分配為 `0xB4`。
- 燒錄至 XO5 硬體後，DAA 階段失敗，LED 停在 **LED2 閃爍**（DAA 不斷重試，無法成功）。

### 軟體面排查結論
透過 LED 燈號檢查點確認各階段狀態：

| 階段 | 結果 |
|---|---|
| BSP / UART init | ✅ 通過（上電掃描 LED0→7 完成）|
| I3C Master IP init | ✅ 通過 |
| I3C Target IP init | ✅ 通過 |
| Target FIFO Loopback enable | ✅ 通過 |
| DAA 匯流排通訊 | ❌ 失敗，卡在 LED2 閃爍 |

- `i3c_target_init()` 已確認加入並正常執行（曾被註解，已修復）。
- `i3c_target_fifo_loopback_enable()` 已加入，確保 Write/Read loopback 測試不會卡死。

### 根本原因確認
**外部 SDA 線路不通**（Master `m0_sda_io` ↔ Slave `s0_sda_io` 實體連線未導通）。

佐證：
1. 所有 SW init 全部通過，排除 IP 位址、bitstream、軔體邏輯問題。
2. DAA 無限重試，Master 一直送 ENTDAA 但收不到任何 ACK。
3. 先前 Reveal 波形觀測：`sda_oe` 一直為 LOW（Master 持續佔住匯流排），`sda_i` 無 Target 回應電位，符合外部 SDA 斷路特徵。

### sda_oe 異常分析（已排查）
在確認接線問題前，曾排查以下假設：
- **假設 A（SEIO33 T-pin 極性反相）**：模擬用 behavioral model，硬體用 SEIO33 primitive，若 OE 極性對應錯誤會導致 Push-Pull 驅動。
- **假設 B（sda_oe_reset 未清除）**：PDC 中 `set_false_path -to [get_nets .../sda_oe_reset]`，時序不保證，可能導致 OE 鎖在 LOW。
- **假設 C（sda_i 回授誤判仲裁失敗）**：PDC 中 `USE_PRIMARY=FALSE` 作用於 Target `sda_i`，可能造成採樣錯誤進而讓 Master FSM 誤判 Lost Arbitration。

以上假設在外部接線修復後需重新驗證是否仍存在。

### 下一步行動
1. **修復外部 SDA 線路**：確認 `m0_sda_io (E4)` ↔ `s0_sda_io (G9)` 實體連線導通，同步確認 `m0_scl_io (C3)` ↔ `s0_scl_io (G7)` 也導通。
2. **重新燒錄並觀察 LED**：接線修復後重新上電，確認 LED2 閃爍後能進入 LED1 恆亮（DAA 成功）。
3. **若接線修復後 DAA 仍失敗**：再以 Reveal 抓取 `sda_oe / sda_o / sda_i / scl_io`，確認上述假設 A/B/C 是否仍有影響。
