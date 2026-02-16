-- 最小版：只输出可 sqlldr 导入 d 的 CSV
-- 执行前:
--   mkdir -p out
--   export NLS_LANG=JAPANESE_JAPAN.AL32UTF8
--   sqlplus user/password@db @spool_merge_abc_to_d.sql
SET PAGESIZE 0
SET LINESIZE 32767
SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF
SET ECHO OFF
SET TRIMSPOOL ON

SPOOL out/abc_to_d.csv
SELECT
    '"' || REPLACE(NVL(TO_CHAR(s.d_key1), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key2), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key3), ''), '"', '""') || '",'
 || TO_CHAR(s.d_key4, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,') || ','
 || TO_CHAR(s.d_key5, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,') || ','
 || TO_CHAR(s.d_key6, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,') || ','
 || '"' || REPLACE(NVL(TO_CHAR(s.b_match_flg), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.c_match_flg), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(s.a_value, ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(s.b_value, ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(s.c_value, ''), '"', '""') || '",'
 || '"' || TO_CHAR(s.created_at, 'YYYY-MM-DD HH24:MI:SS') || '",'
 || '"' || TO_CHAR(s.updated_at, 'YYYY-MM-DD HH24:MI:SS') || '"'
  FROM (
        SELECT
            a.d_key1,
            a.d_key2,
            a.d_key3,
            a.d_key4,
            a.d_key5,
            a.d_key6,
            CASE WHEN b.b_pk1 IS NOT NULL THEN 1 ELSE 0 END AS b_match_flg,
            CASE WHEN c.c_pk1 IS NOT NULL THEN 1 ELSE 0 END AS c_match_flg,
            a.a_value,
            b.b_value,
            c.c_value,
            SYSTIMESTAMP AS created_at,
            SYSTIMESTAMP AS updated_at
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
           AND a.d_key6 IS NOT NULL
       ) s;
SPOOL OFF

EXIT SUCCESS
