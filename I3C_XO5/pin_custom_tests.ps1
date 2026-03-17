#==============================================================================
# Pin Sweep Script - s0_sda_io 換腳尋通測試
#
# 目的：
#   Master 腳位全部固定，對 s0_sda_io 逐一嘗試候選腳位，
#   找出哪個腳與 m0_sda_io (E4) 在板子上實際連通，使 DAA 能成功。
#
# 固定腳位：
#   m0_scl_io = G7   (Master SCL, 不動)
#   m0_sda_io = G9   (Master SDA, 不動)
#   s0_scl_io = D3   (Slave  SCL, 不動)
#
# 掃描腳位：
#   s0_sda_io = 下方 $SdaCandidates 清單，每次跑一個腳
#
# 使用方式：
#   .\pin_custom_tests.ps1
#
# 結果：
#   output\<腳位名>\I3C_XO5_<腳位名>.bit  — 每個候選腳的 bitstream
#   output\custom_tests.log               — 完整執行紀錄
#==============================================================================

$ErrorActionPreference = "Continue"

# ── 路徑設定 ─────────────────────────────────────────────────────────────────
$ProjectDir = "C:\Users\billzhang\Desktop\I3C_XO5\I3C_XO5"
$ImplDir    = "$ProjectDir\impl_1"
$SourcePDC  = "$ProjectDir\source\impl_1\I3C_XO5.pdc"
$OutputDir  = "$ProjectDir\output"
$RadiantC   = "C:\lscc\radiant\2025.2\bin\nt64\radiantc.exe"

$MapTCL = "$ImplDir\pin_sweep_map.tcl"
$ParTCL = "$ImplDir\pin_sweep_par.tcl"
$BitTCL = "$ImplDir\pin_sweep_bit.tcl"

$ReportExtensions = @(".par", ".mrp", ".bgn", ".twr", ".tw1", ".tws", ".pad", ".ior", ".bit", ".drc")

# ── s0_sda_io 候選腳位清單 ────────────────────────────────────────────────────
# 在這裡新增或移除候選腳，每個字串對應一個 Radiant site name
$SdaCandidates = @(
    "E4",
    "C3",
    "C2",
    "A4"
)


# ── Functions ────────────────────────────────────────────────────────────────
function Write-Log {
    param([string]$Message)
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $Message"
    Write-Host $line
    if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
    Add-Content -Path "$OutputDir\custom_tests.log" -Value $line
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

# ── Main ─────────────────────────────────────────────────────────────────────
if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
$originalPDC = Get-Content $SourcePDC -Raw

Write-Log "======================================================"
Write-Log "s0_sda_io sweep started. Total candidates: $($SdaCandidates.Count)"
Write-Log "Fixed: m0_scl=G7  m0_sda=G9  s0_scl=D3"
Write-Log "======================================================"

foreach ($sda in $SdaCandidates) {
    $tName = "sda_$sda"
    Write-Log "========== [$tName] s0_sda_io = $sda =========="

    $testOutputDir = "$OutputDir\$tName"
    if (!(Test-Path $testOutputDir)) { New-Item -ItemType Directory -Path $testOutputDir -Force | Out-Null }

    # 逐行替換 ldc_set_location 腳位 (避免 regex 在多行字串上產生零長度匹配問題)
    $modifiedLines = ($originalPDC -split "`r`n|`r|`n") | ForEach-Object {
        switch -Regex ($_) {
            "^ldc_set_location.*get_ports m0_scl_io" { "ldc_set_location -site {G7} [get_ports m0_scl_io]"; break }
            "^ldc_set_location.*get_ports m0_sda_io" { "ldc_set_location -site {G9} [get_ports m0_sda_io]"; break }
            "^ldc_set_location.*get_ports s0_scl_io" { "ldc_set_location -site {D3} [get_ports s0_scl_io]"; break }
            "^ldc_set_location.*get_ports s0_sda_io" { "ldc_set_location -site {$sda} [get_ports s0_sda_io]"; break }
            default                                   { $_; break }
        }
    }
    $modifiedPDC = $modifiedLines -join "`r`n"

    # 儲存暫時 PDC
    $tempPDCPath     = "$testOutputDir\I3C_XO5_$tName.pdc"
    $pdcPathForward  = $tempPDCPath -replace '\\', '/'
    Set-Content -Path $tempPDCPath -Value $modifiedPDC -NoNewline

    # 執行 Map → PAR → Bitstream
    $rc = Run-RadiantStep "map" $MapTCL @($pdcPathForward) $testOutputDir
    if ($rc -eq 0) {
        $rc = Run-RadiantStep "par" $ParTCL @() $testOutputDir
        if ($rc -eq 0) {
            Run-RadiantStep "bit" $BitTCL @() $testOutputDir
        }
    }

    # 收集結果報告
    foreach ($ext in $ReportExtensions) {
        $srcFile = "$ImplDir\I3C_XO5_impl_1$ext"
        if (Test-Path $srcFile) {
            Copy-Item -Path $srcFile -Destination "$testOutputDir\I3C_XO5_$tName$ext" -Force
        }
    }

    Write-Log "[$tName] done. Bitstream: $testOutputDir\I3C_XO5_$tName.bit"
}

Write-Log "======================================================"
Write-Log "All s0_sda_io sweep tests finished."
Write-Log "Burn each .bit to board, observe if LED progresses past LED2."
Write-Log "The first candidate that shows LED1 ON = correct s0_sda pin."
Write-Log "======================================================"
Write-Host "`nDone! Check output\ folder for each candidate's bitstream." -ForegroundColor Green
