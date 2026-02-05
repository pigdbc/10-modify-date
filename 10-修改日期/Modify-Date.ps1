param(
    [string[]]$Paths,
    [string]$Date
)

$ErrorActionPreference = "Stop"

function Read-ConfigFromBat {
    param([string]$BatPath)

    $config = @{}
    if (-not (Test-Path $BatPath)) {
        throw "設定ファイルが見つかりません: $BatPath"
    }

    $lines = Get-Content -Path $BatPath -Encoding Default
    foreach ($line in $lines) {
        if ($line -match '^\s*set\s+([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            if ($key.Length -gt 0) {
                $config[$key] = $value
            }
        }
    }
    return $config
}

function Read-Header {
    param([string]$CsvPath)
    $firstLine = Get-Content -Path $CsvPath -Encoding Unicode -TotalCount 1
    if (-not $firstLine) { return @() }
    $firstLine = $firstLine.TrimStart([char]0xFEFF)
    return ($firstLine -split ',') | ForEach-Object { $_.Trim('\"') }
}

function Validate-Date {
    param([string]$Value)

    if (-not ($Value -match '^\d{8}$')) {
        return $false
    }

    try {
        [void][datetime]::ParseExact($Value, "yyyyMMdd", [System.Globalization.CultureInfo]::InvariantCulture)
        return $true
    } catch {
        return $false
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$inputDir = Join-Path $scriptDir "input"
$outDir = Join-Path $scriptDir "out"
$envPath = Join-Path $scriptDir "SetEnv.bat"

$config = Read-ConfigFromBat -BatPath $envPath

$class1Prefix = $config["CLASS1_PREFIX"]
$class1Field = $config["CLASS1_FIELD"]
$class2Prefix = $config["CLASS2_PREFIX"]
$class2Field = $config["CLASS2_FIELD"]

if (-not $class1Prefix -or -not $class1Field -or -not $class2Prefix -or -not $class2Field) {
    throw "SetEnv.bat の設定が不足しています。"
}

if (-not (Test-Path $inputDir)) {
    throw "input フォルダが見つかりません: $inputDir"
}
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

if (-not $Paths -or $Paths.Count -eq 0) {
    $files = Get-ChildItem -Path $inputDir -Filter "*.csv" | Select-Object -ExpandProperty FullName
    if (-not $files -or $files.Count -eq 0) {
        Write-Host "input にCSVファイルがありません。"
        exit 1
    }

    if (-not (Get-Command Out-GridView -ErrorAction SilentlyContinue)) {
        Write-Host "Out-GridView が利用できません。-Paths オプションで実行してください。"
        exit 1
    }

    $Paths = $files | Out-GridView -Title "CSVファイルを選択してください（複数選択可）" -PassThru
    if (-not $Paths -or $Paths.Count -eq 0) {
        Write-Host "ファイルが選択されませんでした。"
        exit 1
    }
}

while (-not $Date -or -not (Validate-Date -Value $Date)) {
    $Date = Read-Host "日付(yyyymmdd)を入力してください"
    if (-not (Validate-Date -Value $Date)) {
        Write-Host "日付の形式が正しくありません。例: 20260205"
        $Date = $null
    }
}

foreach ($path in $Paths) {
    if (-not (Test-Path $path)) {
        Write-Host "ファイルが見つかりません: $path"
        continue
    }

    $fileName = [System.IO.Path]::GetFileName($path)
    $targetField = $null

    if ($fileName.StartsWith($class1Prefix)) {
        $targetField = $class1Field
    } elseif ($fileName.StartsWith($class2Prefix)) {
        $targetField = $class2Field
    } else {
        Write-Host "対象外のファイルです: $fileName"
        continue
    }

    $headers = Read-Header -CsvPath $path
    if (-not ($headers -contains $targetField)) {
        Write-Host "対象列が見つかりません: $fileName ($targetField)"
        continue
    }

    $rows = Import-Csv -Path $path -Encoding Unicode
    foreach ($row in $rows) {
        $row.$targetField = $Date
    }

    $outPath = Join-Path $outDir $fileName
    $rows | Export-Csv -Path $outPath -NoTypeInformation -Encoding Unicode

    $logPath = Join-Path $outDir ("{0}.log" -f $fileName)
    $logMessage = "フィールド {0} は {1} に変更しました。" -f $targetField, $Date
    Set-Content -Path $logPath -Value $logMessage -Encoding Unicode

    Write-Host "処理完了: $fileName"
}
