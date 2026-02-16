-- 最简版：固定文件名、固定目录、无参数
-- 请在本目录执行：sqlplus user/password@db @spool_abc_to_d.sql

WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT FAILURE

SET PAGESIZE 0
SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF
SET ECHO OFF
SET TRIMSPOOL ON

-- 直接导出可供 sqlldr 使用的 CSV（无表头）
SPOOL out/abc_to_d.csv
SELECT
    '"' || REPLACE(NVL(TO_CHAR(a.d_key1), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key2), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key3), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key4), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key5), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key6), ''), '"', '""') || '",'
 || TO_CHAR(CASE WHEN b.b_pk1 IS NOT NULL THEN 1 ELSE 0 END) || ','
 || TO_CHAR(CASE WHEN c.c_pk1 IS NOT NULL THEN 1 ELSE 0 END) || ','
 || '"' || REPLACE(NVL(a.a_value, ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(b.b_value, ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(c.c_value, ''), '"', '""') || '",'
 || '"' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || '",'
 || '"' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || '"'
  FROM a
  LEFT JOIN b
    ON a.a_to_b_key1 = b.b_pk1
   AND a.a_to_b_key2 = b.b_pk2
   AND a.a_to_b_key3 = b.b_pk3
   AND a.a_to_b_key4 = b.b_pk4
   AND a.a_to_b_key5 = b.b_pk5
  LEFT JOIN c
    ON a.a_to_c_key1 = c.c_pk1
   AND a.a_to_c_key2 = c.c_pk2
   AND a.a_to_c_key3 = c.c_pk3
   AND a.a_to_c_key4 = c.c_pk4
   AND a.a_to_c_key5 = c.c_pk5
 WHERE a.d_key1 IS NOT NULL
   AND a.d_key2 IS NOT NULL
   AND a.d_key3 IS NOT NULL
   AND a.d_key4 IS NOT NULL
   AND a.d_key5 IS NOT NULL
   AND a.d_key6 IS NOT NULL;
SPOOL OFF

-- CASE WHEN 示例导出（用于查看突合和空键状态）
SPOOL out/abc_case_demo.csv
SELECT
    '"' || TO_CHAR(a.ROWID) || '",'
 || TO_CHAR(CASE WHEN b.b_pk1 IS NULL THEN 0 ELSE 1 END) || ','
 || TO_CHAR(CASE WHEN c.c_pk1 IS NULL THEN 0 ELSE 1 END) || ','
 || '"' || CASE
             WHEN a.d_key1 IS NULL OR a.d_key2 IS NULL OR a.d_key3 IS NULL
               OR a.d_key4 IS NULL OR a.d_key5 IS NULL OR a.d_key6 IS NULL
             THEN 'KEY_NULL'
             ELSE 'KEY_OK'
           END || '",'
 || '"' || CASE
             WHEN b.b_pk1 IS NOT NULL AND c.c_pk1 IS NOT NULL THEN 'B_C_OK'
             WHEN b.b_pk1 IS NOT NULL THEN 'B_ONLY'
             WHEN c.c_pk1 IS NOT NULL THEN 'C_ONLY'
             ELSE 'NONE'
           END || '",'
 || '"' || CASE
             WHEN NVL(TRIM(a.a_value), '') = '' THEN 'A_VALUE_EMPTY'
             ELSE 'A_VALUE_OK'
           END || '"'
  FROM a
  LEFT JOIN b
    ON a.a_to_b_key1 = b.b_pk1
   AND a.a_to_b_key2 = b.b_pk2
   AND a.a_to_b_key3 = b.b_pk3
   AND a.a_to_b_key4 = b.b_pk4
   AND a.a_to_b_key5 = b.b_pk5
  LEFT JOIN c
    ON a.a_to_c_key1 = c.c_pk1
   AND a.a_to_c_key2 = c.c_pk2
   AND a.a_to_c_key3 = c.c_pk3
   AND a.a_to_c_key4 = c.c_pk4
   AND a.a_to_c_key5 = c.c_pk5;
SPOOL OFF

-- 主键有空值的数据（定位用）
SPOOL out/abc_to_d_null_keys.csv
SELECT
    '"' || TO_CHAR(a.ROWID) || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key1), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key2), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key3), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key4), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key5), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(a.d_key6), ''), '"', '""') || '",'
 || '"' || RTRIM(
        CASE WHEN a.d_key1 IS NULL THEN 'd_key1|' ELSE '' END
     || CASE WHEN a.d_key2 IS NULL THEN 'd_key2|' ELSE '' END
     || CASE WHEN a.d_key3 IS NULL THEN 'd_key3|' ELSE '' END
     || CASE WHEN a.d_key4 IS NULL THEN 'd_key4|' ELSE '' END
     || CASE WHEN a.d_key5 IS NULL THEN 'd_key5|' ELSE '' END
     || CASE WHEN a.d_key6 IS NULL THEN 'd_key6|' ELSE '' END,
        '|'
      ) || '"'
  FROM a
 WHERE a.d_key1 IS NULL
    OR a.d_key2 IS NULL
    OR a.d_key3 IS NULL
    OR a.d_key4 IS NULL
    OR a.d_key5 IS NULL
    OR a.d_key6 IS NULL;
SPOOL OFF

EXIT SUCCESS
