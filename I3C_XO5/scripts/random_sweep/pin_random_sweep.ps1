#==============================================================================
# Bank 0 Random Pin Sweep Script
#
# 目的：
#   從 MachXO5-NX Bank 0 引出至 Header 的 29 個腳位中，隨機抽取 4 個
#   (M0_SCL, M0_SDA, S0_SCL, S0_SDA) 產生 N 套 Bitstream，
#   逐一燒錄觀察 LED，找出 DAA 能成功的腳位組合。
#
# 執行方式：
#   cd C:\Users\billzhang\Desktop\I3C_XO5\I3C_XO5
#   .\scripts\random_sweep\pin_random_sweep.ps1
#
# 輸出：
#   output\Random_Tests\v1_M0SCL_xx_M0SDA_xx_S0SCL_xx_S0SDA_xx\  ← bitstream + 報告
#   output\Random_Tests\random_run_map.log                         ← 完整紀錄 + 版本腳位對照表
#
# 判斷標準：
#   LED2 閃爍           = DAA 失敗（腳位組合不對）
#   LED2 閃爍 + LED3 亮 = DAA 持續失敗（接線警告）
#   LED1 恆亮           = DAA 成功 ← 此為目標組合
#==============================================================================

$ErrorActionPreference = "Continue"

# ── 路徑設定 ──────────────────────────────────────────────────────────────────
$ProjectDir = "C:\Users\billzhang\Desktop\I3C_XO5\I3C_XO5"
$ImplDir    = "$ProjectDir\impl_1"
$SourcePDC  = "$ProjectDir\source\impl_1\I3C_XO5.pdc"
$ScriptDir  = "$ProjectDir\scripts\random_sweep"
$TclDir     = "$ScriptDir\tcl"
$OutputBase = "$ProjectDir\output\Random_Tests"
$RadiantC   = "C:\lscc\radiant\2025.2\bin\nt64\radiantc.exe"

$MapTCL     = "$TclDir\random_sweep_map.tcl"
$ParTCL     = "$TclDir\random_sweep_par.tcl"
$BitTCL     = "$TclDir\random_sweep_bit.tcl"
$MasterLog  = "$OutputBase\random_run_map.log"

$ReportExtensions = @(".par", ".mrp", ".bgn", ".twr", ".tw1", ".tws", ".pad", ".ior", ".bit", ".drc")

# ── Bank 0 腳位池 (29 pins) ───────────────────────────────────────────────────
$PinPool = @(
    # PMOD2 (J16) — F4 removed (nonexistent in package)
    "C1", "E4", "B2", "B1", "E3", "D3", "G4",
    # Versa Header (J9) — D4 removed (nonexistent in package)
    "D1", "A2", "A6", "B6", "C6", "D6", "A5", "B5",
    "C5", "D5", "A4", "B4", "C4", "A3", "B3", "C3",
    # I3C Origin
    "G9", "G8", "G7", "H8"
)

# ── 總版本數 ──────────────────────────────────────────────────────────────────
$N = 10

# ── Functions ─────────────────────────────────────────────────────────────────
function Write-Log {
    param([string]$Message)
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $Message"
    Write-Host $line
    Add-Content -Path $MasterLog -Value $line
}

# Fisher-Yates shuffle — 回傳新陣列，不改動原陣列
function Shuffle-Array {
    param([string[]]$arr)
    $result = [string[]]($arr.Clone())
    for ($i = $result.Count - 1; $i -gt 0; $i--) {
        $j   = Get-Random -Maximum ($i + 1)
        $tmp = $result[$i]
        $result[$i] = $result[$j]
        $result[$j] = $tmp
    }
    return $result
}

function Run-RadiantStep {
    param(
        [string]$StepName,
        [string]$TclScript,
        [string[]]$TclArgs,
        [string]$LogDir
    )
    Write-Log "  $StepName starting..."
    $argList = @("`"$TclScript`"") + ($TclArgs | ForEach-Object { "`"$_`"" })

    $process = Start-Process -FilePath $RadiantC -ArgumentList $argList `
        -NoNewWindow -Wait -PassThru `
        -RedirectStandardOutput "$LogDir\${StepName}_stdout.log" `
        -RedirectStandardError  "$LogDir\${StepName}_stderr.log"

    if ($process.ExitCode -ne 0) {
        Write-Log "  $StepName FAILED (exit code: $($process.ExitCode))"
    } else {
        Write-Log "  $StepName completed successfully."
    }
    return $process.ExitCode
}

# ── Main ──────────────────────────────────────────────────────────────────────
if (!(Test-Path $OutputBase)) { New-Item -ItemType Directory -Path $OutputBase -Force | Out-Null }

$originalPDC = Get-Content $SourcePDC -Raw
$AllPinMaps  = @()

Write-Log "======================================================"
Write-Log "Bank 0 Random Pin Sweep started. N=$N versions"
Write-Log "Pin pool: $($PinPool.Count) pins"
Write-Log "======================================================"

for ($v = 1; $v -le $N; $v++) {
    # 隨機洗牌，取前 4 個不重複腳位
    $shuffled = Shuffle-Array $PinPool
    $m0_scl   = $shuffled[0]
    $m0_sda   = $shuffled[1]
    $s0_scl   = $shuffled[2]
    $s0_sda   = $shuffled[3]

    $vName = "v${v}_M0SCL_${m0_scl}_M0SDA_${m0_sda}_S0SCL_${s0_scl}_S0SDA_${s0_sda}"
    $vDir  = "$OutputBase\$vName"

    Write-Log "========== [$vName] =========="
    Write-Log "  M0_SCL=$m0_scl  M0_SDA=$m0_sda  S0_SCL=$s0_scl  S0_SDA=$s0_sda"
    $AllPinMaps += "v${v}: M0_SCL=$m0_scl  M0_SDA=$m0_sda  S0_SCL=$s0_scl  S0_SDA=$s0_sda  dir=$vName"

    if (!(Test-Path $vDir)) { New-Item -ItemType Directory -Path $vDir -Force | Out-Null }

    # 逐行替換四個 I3C 腳位
    $modifiedLines = ($originalPDC -split "`r`n|`r|`n") | ForEach-Object {
        switch -Regex ($_) {
            "^ldc_set_location.*get_ports m0_scl_io" { "ldc_set_location -site {$m0_scl} [get_ports m0_scl_io]"; break }
            "^ldc_set_location.*get_ports m0_sda_io" { "ldc_set_location -site {$m0_sda} [get_ports m0_sda_io]"; break }
            "^ldc_set_location.*get_ports s0_scl_io" { "ldc_set_location -site {$s0_scl} [get_ports s0_scl_io]"; break }
            "^ldc_set_location.*get_ports s0_sda_io" { "ldc_set_location -site {$s0_sda} [get_ports s0_sda_io]"; break }
            default                                   { $_; break }
        }
    }
    $modifiedPDC    = $modifiedLines -join "`r`n"
    $tempPDCPath    = "$vDir\I3C_XO5_$vName.pdc"
    $pdcPathForward = $tempPDCPath -replace '\\', '/'
    Set-Content -Path $tempPDCPath -Value $modifiedPDC -NoNewline

    # Map → PAR → Bitstream
    $rc = Run-RadiantStep "map" $MapTCL @($pdcPathForward) $vDir
    if ($rc -eq 0) {
        $rc = Run-RadiantStep "par" $ParTCL @() $vDir
        if ($rc -eq 0) {
            Run-RadiantStep "bit" $BitTCL @() $vDir
        }
    }

    # 收集 PAR / Timing / Bitstream 報告
    foreach ($ext in $ReportExtensions) {
        $src = "$ImplDir\I3C_XO5_impl_1$ext"
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination "$vDir\I3C_XO5_$vName$ext" -Force
        }
    }

    Write-Log "[$vName] done. Bitstream: $vDir\I3C_XO5_$vName.bit"
}

# ── 版本腳位對照表 ─────────────────────────────────────────────────────────────
Write-Log "======================================================"
Write-Log "=== PIN MAP SUMMARY (burn order) ==="
$AllPinMaps | ForEach-Object { Write-Log "  $_" }
Write-Log "======================================================"
Write-Log "All $N versions completed."
Write-Log "LED guide:"
Write-Log "  LED2 blink only     = DAA failed (wrong pin combo)"
Write-Log "  LED2 blink + LED3   = DAA retry >= 20, check wiring"
Write-Log "  LED1 solid          = DAA SUCCESS => record this combo as the answer"
Write-Log "======================================================"

Write-Host "`nDone! Check output\Random_Tests\ for all bitstreams and random_run_map.log for pin assignments." -ForegroundColor Green
