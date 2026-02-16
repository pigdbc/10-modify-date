# 13-plsql-spool-merge-d-20260216

## 目录结构
- `01-generate-csv/`
  - `spool_abc_to_d_sqlldr.sql`：生成 `out/d_load.csv` + `out/d_reject.csv`
- `02-sqlldr/`
  - `d_load.ctl`：`sqlldr` 控制文件（导入 `d`）
  - `run_sqlldr.bat`：Windows 一键导入
- `03-templates/`
  - `cursor_insert_d_continue_template.sql`：游标逐行插入且不中断模板
- `99-legacy/`
  - `spool_merge_abc_to_d.sql`：旧版单文件脚本（保留）
- `out/`
  - 输出目录（CSV / log / bad / dsc）

## 最常用流程
1. 生成 CSV
```bash
cd /Users/jiwuqi/.gemini/antigravity/scratch/projects/13-plsql-spool-merge-d-20260216
mkdir -p out
export NLS_LANG=JAPANESE_JAPAN.AL32UTF8
sqlplus user/password@db @01-generate-csv/spool_abc_to_d_sqlldr.sql
```

2. 导入有效数据
```bash
sqlldr user/password@db control=02-sqlldr/d_load.ctl log=out/d_load.log bad=out/d_load.bad discard=out/d_load.dsc
```

Windows 可直接运行：
```bat
02-sqlldr\run_sqlldr.bat user/password@db
```

## 文件含义
- `out/d_load.csv`：有效行，可直接 `sqlldr` 导入 `d`
- `out/d_reject.csv`：无效行（含拒绝原因）

## 规则
- A 为主表，`a_to_b_key1..5 = b_pk1..5`，`a_to_c_key1..5 = c_pk1..5`
- `d_key1..d_key6` 任一为空 -> 进入 `d_reject.csv`
- `d_key1..d_key3` 按字符输出（带引号）
- `d_key4..d_key6` 按数字输出（不带引号）
- `b_match_flg/c_match_flg`：`1=匹配`，`0=不匹配`
