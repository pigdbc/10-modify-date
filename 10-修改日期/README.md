# 使用说明（Windows 11 / macOS）

## 目录结构
- `Modify-Date.ps1` 主脚本  
- `SetEnv.bat` 规则配置（文件名前缀、字段名）  
- `input/` 输入 CSV  
- `out/` 输出 CSV 与日志  
- `run.bat` Windows 一键运行（PowerShell 5.1）  
- `tests/run.ps1` 测试脚本  

## 运行方式

### Windows 11（推荐）
双击 `run.bat` 即可运行。  
或在 PowerShell 中执行：
```powershell
powershell .\10-修改日期\Modify-Date.ps1
```

### macOS / Linux
```powershell
pwsh 10-修改日期/Modify-Date.ps1
```
如果提示 `Out-GridView が利用できません`，请用参数方式：
```powershell
pwsh 10-修改日期/Modify-Date.ps1 -Paths "10-修改日期/input/テーベxxx.csv","10-修改日期/input/テこxxx.csv" -Date 20260205
```

## 配置规则（SetEnv.bat）
```
set CLASS1_PREFIX=テーベ
set CLASS1_FIELD=a
set CLASS2_PREFIX=テこ
set CLASS2_FIELD=b
```

## SJIS 版本（仅日语系统 + PS5.1）
- 脚本：`Modify-Date-sjis.ps1`
- 配置：`SetEnv-sjis.bat`
- 说明：这两份文件均为 **SJIS/CP932** 编码，只适用于日语系统的 Windows PowerShell 5.1  
- 运行：  
```powershell
powershell .\10-修改日期\Modify-Date-sjis.ps1
```

## 行为与情况表

| 情况 | 行为 | 提示/结果 |
|---|---|---|
| 未选择任何文件 | 退出 | `ファイルが選択されませんでした。` |
| `input` 无 CSV | 退出 | `input にCSVファイルがありません。` |
| `Out-GridView` 不可用 | 退出 | `Out-GridView が利用できません。-Paths オプションで実行してください。` |
| 输入日期格式不合法 | 重新输入 | `日付の形式が正しくありません。例: 20260205` |
| 文件名不匹配两类前缀 | 跳过该文件 | `対象外のファイルです: <文件名>` |
| 文件不存在 | 跳过该文件 | `ファイルが見つかりません: <路径>` |
| 目标字段不存在 | 跳过该文件 | `対象列が見つかりません: <文件名> (<字段名>)` |
| 多个文件混合处理 | 逐文件处理，互不影响 | 有字段的正常输出，缺字段的跳过 |

## 日志格式（out/*.log）
```
開始時刻   : yyyy-MM-dd HH:mm:ss
終了時刻   : yyyy-MM-dd HH:mm:ss
所要時間   : hh:mm:ss
更新フィールド : a / b
更新後の日付   : yyyymmdd
処理件数       : N
```

### 日志示例
```
開始時刻   : 2026-02-05 20:15:01
終了時刻   : 2026-02-05 20:15:03
所要時間   : 00:00:02
更新フィールド : a
更新後の日付   : 20260205
処理件数       : 5
```

## 常用命令示例
```powershell
# 交互式选择文件（Windows 11）
powershell .\10-修改日期\Modify-Date.ps1

# macOS/Linux 交互式
pwsh 10-修改日期/Modify-Date.ps1

# 指定文件与日期（无弹窗）
pwsh 10-修改日期/Modify-Date.ps1 -Paths "10-修改日期/input/テーベサンプル.csv","10-修改日期/input/テこサンプル.csv" -Date 20260205
```
