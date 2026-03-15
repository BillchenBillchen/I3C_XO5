#==============================================================================
# Pin Custom Test Script - 生成 D3 版與「對調 Master/Slave 版」
# 使用方式: .\pin_custom_tests.ps1
#==============================================================================

$ErrorActionPreference = "Continue"

# ---- Configuration ----
$ProjectDir = "C:\Users\billzhang\Desktop\I3C_XO5\I3C_XO5"
$ImplDir    = "$ProjectDir\impl_1"
$SourcePDC  = "$ProjectDir\source\impl_1\I3C_XO5.pdc"
$OutputDir  = "$ProjectDir\output"
$RadiantC   = "C:\lscc\radiant\2025.2\bin\nt64\radiantc.exe"

# TCL scripts
$MapTCL = "$ImplDir\pin_sweep_map.tcl"
$ParTCL = "$ImplDir\pin_sweep_par.tcl"
$BitTCL = "$ImplDir\pin_sweep_bit.tcl"

# Report files to collect
$ReportExtensions = @(".par", ".mrp", ".bgn", ".twr", ".tw1", ".tws", ".pad", ".ior", ".bit", ".drc")

# ---- Functions ----
function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
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

    $process = Start-Process -FilePath $RadiantC -ArgumentList $argList -NoNewWindow -Wait -PassThru `
        -RedirectStandardOutput "$LogDir\${StepName}_stdout.log" `
        -RedirectStandardError "$LogDir\${StepName}_stderr.log"

    $exitCode = $process.ExitCode
    if ($exitCode -ne 0) {
        Write-Log "  $StepName FAILED (exit code: $exitCode)"
    } else {
        Write-Log "  $StepName completed successfully."
    }
    return $exitCode
}

# ---- Main ----
if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
$originalPDC = Get-Content $SourcePDC -Raw

# 定義測試清單 (使用最穩定的陣列新增方式)
$Tests = New-Object System.Collections.ArrayList

# --- 定義 D3 版 ---
$pinMapD3 = New-Object System.Collections.ArrayList
$pinMapD3.Add(@{ From = "ldc_set_location -site \{.*\} \[get_ports m0_scl_io\]"; To = "ldc_set_location -site {D3} [get_ports m0_scl_io]" }) | Out-Null

$objD3 = New-Object PSObject
$objD3 | Add-Member -MemberType NoteProperty -Name Name -Value "D3"
$objD3 | Add-Member -MemberType NoteProperty -Name Desc -Value "Master SCL at D3 (Original)"
$objD3 | Add-Member -MemberType NoteProperty -Name PinMap -Value $pinMapD3
$Tests.Add($objD3) | Out-Null

# --- 定義對調版 ---
$pinMapSwap = New-Object System.Collections.ArrayList
$pinMapSwap.Add(@{ From = "ldc_set_location -site \{.*\} \[get_ports m0_scl_io\]"; To = "ldc_set_location -site {G7} [get_ports m0_scl_io]" }) | Out-Null
$pinMapSwap.Add(@{ From = "ldc_set_location -site \{.*\} \[get_ports m0_sda_io\]"; To = "ldc_set_location -site {G9} [get_ports m0_sda_io]" }) | Out-Null
$pinMapSwap.Add(@{ From = "ldc_set_location -site \{.*\} \[get_ports s0_scl_io\]"; To = "ldc_set_location -site {C3} [get_ports s0_scl_io]" }) | Out-Null
$pinMapSwap.Add(@{ From = "ldc_set_location -site \{.*\} \[get_ports s0_sda_io\]"; To = "ldc_set_location -site {E4} [get_ports s0_sda_io]" }) | Out-Null

$objSwap = New-Object PSObject
$objSwap | Add-Member -MemberType NoteProperty -Name Name -Value "Swap"
$objSwap | Add-Member -MemberType NoteProperty -Name Desc -Value "對調 Master/Slave (Master:G7,G9 / Slave:C3,E4)"
$objSwap | Add-Member -MemberType NoteProperty -Name PinMap -Value $pinMapSwap
$Tests.Add($objSwap) | Out-Null

# --- 執行迴圈 ---
foreach ($test in $Tests) {
    $tName = $test.Name
    $tDesc = $test.Desc
    Write-Log "========== Starting custom test: $tName ($tDesc) =========="
    
    $testOutputDir = "$OutputDir\$tName"
    if (!(Test-Path $testOutputDir)) { New-Item -ItemType Directory -Path $testOutputDir -Force | Out-Null }

    # 套用變更
    $modifiedPDC = $originalPDC
    foreach ($map in $test.PinMap) {
        $f = $map.From
        $t = $map.To
        $modifiedPDC = $modifiedPDC -replace $f, $t
    }
    
    $tempPDCPath = "$testOutputDir\I3C_XO5_$tName.pdc"
    Set-Content -Path $tempPDCPath -Value $modifiedPDC -NoNewline

    # 執行步驟
    $pdcPathForward = $tempPDCPath -replace '\\', '/'
    $rc = Run-RadiantStep "map" $MapTCL @($pdcPathForward) $testOutputDir
    if ($rc -eq 0) {
        $rc = Run-RadiantStep "par" $ParTCL @() $testOutputDir
        if ($rc -eq 0) {
            Run-RadiantStep "bit" $BitTCL @() $testOutputDir
        }
    }

    # 收集結果
    foreach ($ext in $ReportExtensions) {
        $srcFile = "$ImplDir\I3C_XO5_impl_1$ext"
        if (Test-Path $srcFile) {
            Copy-Item -Path $srcFile -Destination "$testOutputDir\I3C_XO5_$tName$ext" -Force
        }
    }
    Write-Log "Test $tName finished."
}

Write-Host "`nAll custom tests finished! Check the output/ folder." -ForegroundColor Green
