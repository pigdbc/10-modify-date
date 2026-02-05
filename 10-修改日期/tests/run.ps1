$ErrorActionPreference = "Stop"

$testRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseDir = Resolve-Path (Join-Path $testRoot "..")
$inputDir = Join-Path $baseDir "input"
$outDir = Join-Path $baseDir "out"

if (-not (Test-Path $inputDir)) { New-Item -ItemType Directory -Path $inputDir | Out-Null }
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$file1 = Join-Path $inputDir "テーベtest.csv"
$file2 = Join-Path $inputDir "テこtest.csv"

$dataA = @(
    [pscustomobject]@{ a = "old1" },
    [pscustomobject]@{ a = "old2" }
)
$dataB = @(
    [pscustomobject]@{ b = "old3" },
    [pscustomobject]@{ b = "old4" }
)

$dataA | Export-Csv -Path $file1 -NoTypeInformation -Encoding Unicode
$dataB | Export-Csv -Path $file2 -NoTypeInformation -Encoding Unicode

$scriptPath = Join-Path $baseDir "Modify-Date.ps1"
if (-not (Test-Path $scriptPath)) {
    throw "Modify-Date.ps1 not found"
}

& $scriptPath -Paths @($file1, $file2) -Date "20260205" | Out-Null

$out1 = Join-Path $outDir "テーベtest.csv"
$out2 = Join-Path $outDir "テこtest.csv"

if (-not (Test-Path $out1)) { throw "出力ファイルがありません: $out1" }
if (-not (Test-Path $out2)) { throw "出力ファイルがありません: $out2" }

$check1 = Import-Csv -Path $out1 -Encoding Unicode
$check2 = Import-Csv -Path $out2 -Encoding Unicode

foreach ($row in $check1) {
    if ($row.a -ne "20260205") { throw "a列が更新されていません" }
}

foreach ($row in $check2) {
    if ($row.b -ne "20260205") { throw "b列が更新されていません" }
}

Write-Host "テスト成功"
