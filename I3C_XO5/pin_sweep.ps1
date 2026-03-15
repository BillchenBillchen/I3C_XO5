#==============================================================================
# Pin Sweep Script - 批次測試多個 Master SCL Pin 產生對應 Bitfile
# 使用方式: .\pin_sweep.ps1
# 預估時間: 14 pins × ~10 min/pin ≈ 2.5 hours
#==============================================================================

$ErrorActionPreference = "Continue"

# ---- Configuration ----
$ProjectDir = "C:\Users\billzhang\Desktop\I3C_XO5\I3C_XO5"
$ImplDir    = "$ProjectDir\impl_1"
$SourcePDC  = "$ProjectDir\source\impl_1\I3C_XO5.pdc"
$OutputDir  = "$ProjectDir\output"
$RadiantC   = "C:\lscc\radiant\2025.2\bin\nt64\radiantc.exe"

# TCL scripts (3 separate scripts to avoid session state pollution)
$MapTCL = "$ImplDir\pin_sweep_map.tcl"
$ParTCL = "$ImplDir\pin_sweep_par.tcl"
$BitTCL = "$ImplDir\pin_sweep_bit.tcl"

# Current m0_scl_io pin in PDC (the one to be replaced)
$CurrentSCLPin = "D3"

$PinsToTest = @("A4", "E5", "F6", "C5", "B2", "A2", "B3", "A3", "B4", "D5", "A5", "B5")

# Report files to collect (from impl_1 directory)
$ReportExtensions = @(".par", ".mrp", ".bgn", ".twr", ".tw1", ".tws", ".pad", ".ior", ".bit", ".drc")

# ---- Functions ----
function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $Message"
    Write-Host $line
    Add-Content -Path "$OutputDir\pin_sweep.log" -Value $line
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
        $stderr = Get-Content "$LogDir\${StepName}_stderr.log" -ErrorAction SilentlyContinue
        if ($stderr) { Write-Log "  stderr: $stderr" }
    } else {
        Write-Log "  $StepName completed successfully."
    }
    return $exitCode
}

function Get-PARSummary {
    param([string]$ParFile)
    $result = @{
        Errors = "N/A"
        SetupSlack = "N/A"
        HoldSlack = "N/A"
        Status = "UNKNOWN"
    }
    if (Test-Path $ParFile) {
        $content = Get-Content $ParFile -Raw
        if ($content -match "PAR_SUMMARY::Number of errors = (\d+)") {
            $result.Errors = $Matches[1]
        }
        if ($content -match "PAR_SUMMARY::Estimated worst slack<setup/<ns>> = ([\d\.\-]+)") {
            $result.SetupSlack = $Matches[1]
        }
        if ($content -match "PAR_SUMMARY::Estimated worst slack<hold/<ns>> = ([\d\.\-]+)") {
            $result.HoldSlack = $Matches[1]
        }
        if ($result.Errors -eq "0" -and $result.SetupSlack -ne "N/A") {
            $slack = [double]$result.SetupSlack
            if ($slack -ge 0) { $result.Status = "PASS" } else { $result.Status = "TIMING_FAIL" }
        } elseif ($result.Errors -ne "0") {
            $result.Status = "PAR_ERROR"
        }
    } else {
        $result.Status = "NO_PAR_FILE"
    }
    return $result
}

# ---- Main ----
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Pin Sweep Script - I3C_XO5 Master SCL Pin" -ForegroundColor Cyan
Write-Host " Testing $($PinsToTest.Count) pins" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Create output directory
if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

# Read original PDC
$originalPDC = Get-Content $SourcePDC -Raw

# Summary collection
$summaryLines = @()
$summaryLines += "PIN  | PAR_ERRORS | SETUP_SLACK | HOLD_SLACK  | STATUS"
$summaryLines += "-----|------------|-------------|-------------|-------"

$totalPins = $PinsToTest.Count
$pinIndex = 0

foreach ($pin in $PinsToTest) {
    $pinIndex++
    $pinStartTime = Get-Date
    Write-Host ""
    Write-Log "========== [$pinIndex/$totalPins] Testing pin: $pin =========="

    # 1. Create pin-specific output directory
    $pinOutputDir = "$OutputDir\$pin"
    if (!(Test-Path $pinOutputDir)) { New-Item -ItemType Directory -Path $pinOutputDir -Force | Out-Null }

    # 2. Create modified PDC
    $modifiedPDC = $originalPDC -replace "ldc_set_location -site \{$CurrentSCLPin\} \[get_ports m0_scl_io\]", "ldc_set_location -site {$pin} [get_ports m0_scl_io]"
    $tempPDCPath = "$pinOutputDir\I3C_XO5_$pin.pdc"
    Set-Content -Path $tempPDCPath -Value $modifiedPDC -NoNewline
    Write-Log "Created PDC with m0_scl_io -> $pin"

    # Verify substitution
    if ($modifiedPDC -eq $originalPDC -and $pin -ne $CurrentSCLPin) {
        Write-Log "WARNING: PDC substitution may have failed for pin $pin!"
    }

    # 3. Run Map -> PAR -> Bitgen (3 separate radiantc calls)
    $pdcPathForward = $tempPDCPath -replace '\\', '/'

    # Step 3a: MAP
    $mapExit = Run-RadiantStep -StepName "map" -TclScript $MapTCL -TclArgs @($pdcPathForward) -LogDir $pinOutputDir

    if ($mapExit -ne 0) {
        Write-Log "MAP failed for pin $pin, skipping PAR and BITGEN."
        $summaryLines += "{0,-4} | {1,-10} | {2,-11} | {3,-11} | {4}" -f $pin, "N/A", "N/A", "N/A", "MAP_FAIL"
        continue
    }

    # Step 3b: PAR
    $parExit = Run-RadiantStep -StepName "par" -TclScript $ParTCL -TclArgs @() -LogDir $pinOutputDir

    if ($parExit -ne 0) {
        Write-Log "PAR failed for pin $pin, skipping BITGEN."
        $summaryLines += "{0,-4} | {1,-10} | {2,-11} | {3,-11} | {4}" -f $pin, "N/A", "N/A", "N/A", "PAR_FAIL"
        continue
    }

    # Step 3c: BITGEN
    $bitExit = Run-RadiantStep -StepName "bit" -TclScript $BitTCL -TclArgs @() -LogDir $pinOutputDir

    # 4. Collect all reports
    $collectedFiles = @()
    foreach ($ext in $ReportExtensions) {
        $srcFile = "$ImplDir\I3C_XO5_impl_1$ext"
        if (Test-Path $srcFile) {
            $dstFile = "$pinOutputDir\I3C_XO5_$pin$ext"
            Copy-Item -Path $srcFile -Destination $dstFile -Force
            $collectedFiles += $ext
        }
    }
    # Also collect HTML reports
    Get-ChildItem -Path $ImplDir -Filter "I3C_XO5_impl_1*.html" -ErrorAction SilentlyContinue | ForEach-Object {
        $dstName = $_.Name -replace "I3C_XO5_impl_1", "I3C_XO5_$pin"
        Copy-Item -Path $_.FullName -Destination "$pinOutputDir\$dstName" -Force
        $collectedFiles += $_.Name
    }
    Write-Log "Collected $($collectedFiles.Count) report files"

    # 5. Parse PAR summary
    $parFile = "$pinOutputDir\I3C_XO5_$pin.par"
    $parSummary = Get-PARSummary -ParFile $parFile

    $elapsed = (Get-Date) - $pinStartTime
    $statusColor = if ($parSummary.Status -eq "PASS") { "Green" } else { "Red" }
    Write-Host "  Result: $($parSummary.Status) | Errors=$($parSummary.Errors) | Setup=$($parSummary.SetupSlack)ns | Hold=$($parSummary.HoldSlack)ns | Time=$($elapsed.ToString('mm\:ss'))" -ForegroundColor $statusColor

    $summaryLines += "{0,-4} | {1,-10} | {2,-11} | {3,-11} | {4}" -f $pin, $parSummary.Errors, $parSummary.SetupSlack, $parSummary.HoldSlack, $parSummary.Status
}

# ---- Write Summary ----
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Pin Sweep Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$summaryContent = $summaryLines -join "`n"
Set-Content -Path "$OutputDir\summary.txt" -Value $summaryContent
Write-Host $summaryContent
Write-Log "Summary written to $OutputDir\summary.txt"
Write-Log "Pin sweep finished."
