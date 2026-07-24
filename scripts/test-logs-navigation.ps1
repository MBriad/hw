param(
  [Parameter(Mandatory = $true)]
  [string]$Target,

  [string]$DevEcoHome = 'D:\deveco\DevEco Studio'
)

$ErrorActionPreference = 'Stop'

$sdkHome = Join-Path $DevEcoHome 'sdk'
$nodeExe = Join-Path $DevEcoHome 'tools\node\node.exe'
$hvigorJs = Join-Path $DevEcoHome 'tools\hvigor\bin\hvigorw.js'
$hdcExe = Join-Path $sdkHome 'default\openharmony\toolchains\hdc.exe'
$javaHome = Join-Path $DevEcoHome 'jbr'
$javaExe = Join-Path $javaHome 'bin\java.exe'
$repoRoot = Split-Path -Parent $PSScriptRoot
$mainHap = Join-Path $repoRoot 'entry\build\default\outputs\default\entry-default-unsigned.hap'
$testHap = Join-Path $repoRoot 'entry\build\default\outputs\ohosTest\entry-ohosTest-unsigned.hap'

foreach ($tool in @($nodeExe, $hvigorJs, $hdcExe, $javaExe)) {
  if (-not (Test-Path -LiteralPath $tool)) {
    throw "Required tool was not found: $tool"
  }
}

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code ${LASTEXITCODE}: $FilePath $($Arguments -join ' ')"
  }
}

$targets = & $hdcExe list targets
if ($LASTEXITCODE -ne 0 -or $targets -notcontains $Target) {
  throw "HarmonyOS target '$Target' is not connected. Connected targets: $($targets -join ', ')"
}

Write-Warning 'This UI suite clears and replaces Actrace check-in data. Use a dedicated test device or emulator.'
$env:DEVECO_SDK_HOME = $sdkHome
$env:JAVA_HOME = $javaHome
$env:Path = "$(Join-Path $javaHome 'bin');$env:Path"

Push-Location $repoRoot
try {
  Invoke-Checked $nodeExe @(
    $hvigorJs, '--no-daemon', '--mode', 'module', '-p', 'module=entry@default', '-p', 'product=default',
    '-p', 'buildMode=debug', 'test'
  )
  Invoke-Checked $nodeExe @(
    $hvigorJs, '--no-daemon', '--mode', 'module', '-p', 'module=entry@default', '-p', 'product=default',
    '-p', 'buildMode=debug', 'assembleHap'
  )
  Invoke-Checked $nodeExe @(
    $hvigorJs, '--no-daemon', '--mode', 'module', '-p', 'module=entry@ohosTest', '-p', 'product=default',
    '-p', 'buildMode=debug', 'assembleHap'
  )

  foreach ($hap in @($mainHap, $testHap)) {
    if (-not (Test-Path -LiteralPath $hap)) {
      throw "Expected HAP was not produced: $hap"
    }
    Invoke-Checked $hdcExe @('-t', $Target, 'install', '-r', $hap)
  }

  # Ensure the fixture is written before a fresh EntryAbility reads it.
  Invoke-Checked $hdcExe @('-t', $Target, 'shell', 'aa', 'force-stop', 'com.example.test')

  $testOutput = & $hdcExe -t $Target shell aa test -b com.example.test -m entry_test `
    -s unittest OpenHarmonyTestRunner -s timeout 300000 2>&1
  $testExitCode = $LASTEXITCODE
  $testOutput | ForEach-Object { Write-Host $_ }
  if ($testExitCode -ne 0) {
    throw "aa test failed with exit code $testExitCode"
  }
  $joinedOutput = $testOutput -join "`n"
  if ($joinedOutput -notmatch 'OHOS_REPORT_STATUS_CODE:\s*0' -or
    $joinedOutput -notmatch 'OHOS_REPORT_RESULT: stream=Tests run: \d+, Failure: 0, Error: 0') {
    throw 'aa test did not report a successful completion status.'
  }
} finally {
  Pop-Location
}
