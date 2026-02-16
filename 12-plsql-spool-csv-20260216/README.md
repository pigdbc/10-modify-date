# 12-plsql-spool-csv-20260216

最简版目标：
- 直接 `spool` 导出 `csv`
- `A` 主表与 `B/C` 突合后输出
- 不做任何入库操作

## 文件
- `spool_abc_to_d.sql`：最简导出脚本
- `d_load.ctl`：`sqlldr` 控制文件模板
- `out/`：CSV 输出目录

## 固定输出
- CSV：`out/abc_to_d.csv`
- CASE 示例：`out/abc_case_demo.csv`
- 空键明细：`out/abc_to_d_null_keys.csv`

## 运行方式
```bash
cd /Users/jiwuqi/.gemini/antigravity/scratch/projects/12-plsql-spool-csv-20260216
mkdir -p out
export NLS_LANG=JAPANESE_JAPAN.AL32UTF8
sqlplus user/password@db @spool_abc_to_d.sql
```

## 需要按实际表结构替换的字段
- `A`: `d_key1..d_key6`, `a_to_b_key1..a_to_b_key5`, `a_to_c_key1..a_to_c_key5`, `a_value`
- `B`: `b_pk1..b_pk5`, `b_value`
- `C`: `c_pk1..c_pk5`, `c_value`

`out/abc_to_d_null_keys.csv` 列顺序：
1. `ROWID`
2. `d_key1`
3. `d_key2`
4. `d_key3`
5. `d_key4`
6. `d_key5`
7. `d_key6`
8. `missing_keys`（示例：`d_key2|d_key5`）

`out/abc_case_demo.csv` 列顺序：
1. `ROWID`
2. `b_match_flg`
3. `c_match_flg`
4. `key_status`（`KEY_NULL` / `KEY_OK`）
5. `match_status`（`B_C_OK` / `B_ONLY` / `C_ONLY` / `NONE`）
6. `a_value_status`（`A_VALUE_EMPTY` / `A_VALUE_OK`）
