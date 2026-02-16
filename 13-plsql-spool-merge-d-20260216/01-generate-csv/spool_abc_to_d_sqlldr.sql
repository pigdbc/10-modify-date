-- Generate two CSV files from A/B/C joins:
-- 1) out/d_load.csv   : rows ready for SQL*Loader into D
-- 2) out/d_reject.csv : rejected rows with reason
--
-- Run:
--   mkdir -p out
--   export NLS_LANG=JAPANESE_JAPAN.AL32UTF8
--   sqlplus user/password@db @01-generate-csv/spool_abc_to_d_sqlldr.sql

WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT FAILURE

SET PAGESIZE 0
SET LINESIZE 32767
SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF
SET ECHO OFF
SET TRIMSPOOL ON

SPOOL out/d_load.csv
SELECT
    '"' || REPLACE(NVL(TO_CHAR(s.d_key1), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key2), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key3), ''), '"', '""') || '",'
 || TO_CHAR(s.d_key4, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,') || ','
 || TO_CHAR(s.d_key5, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,') || ','
 || TO_CHAR(s.d_key6, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,') || ','
 || TO_CHAR(s.b_match_flg, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,') || ','
 || TO_CHAR(s.c_match_flg, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,') || ','
 || '"' || REPLACE(NVL(s.a_value, ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(s.b_value, ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(s.c_value, ''), '"', '""') || '",'
 || '"' || TO_CHAR(s.created_at, 'YYYY-MM-DD HH24:MI:SS') || '",'
 || '"' || TO_CHAR(s.updated_at, 'YYYY-MM-DD HH24:MI:SS') || '"'
  FROM (
        SELECT
            a.ROWID AS a_rowid,
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
            SYSTIMESTAMP AS updated_at,
            RTRIM(
                CASE WHEN a.d_key1 IS NULL THEN 'd_key1|' ELSE '' END
             || CASE WHEN a.d_key2 IS NULL THEN 'd_key2|' ELSE '' END
             || CASE WHEN a.d_key3 IS NULL THEN 'd_key3|' ELSE '' END
             || CASE WHEN a.d_key4 IS NULL THEN 'd_key4|' ELSE '' END
             || CASE WHEN a.d_key5 IS NULL THEN 'd_key5|' ELSE '' END
             || CASE WHEN a.d_key6 IS NULL THEN 'd_key6|' ELSE '' END,
                '|'
            ) AS reject_reason
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
       ) s
 WHERE s.reject_reason IS NULL;
SPOOL OFF

SPOOL out/d_reject.csv
SELECT
    '"' || REPLACE(NVL(TO_CHAR(s.a_rowid), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(s.reject_reason, 'UNKNOWN'), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key1), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key2), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key3), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key4), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key5), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.d_key6), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.b_match_flg), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(TO_CHAR(s.c_match_flg), ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(s.a_value, ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(s.b_value, ''), '"', '""') || '",'
 || '"' || REPLACE(NVL(s.c_value, ''), '"', '""') || '"'
  FROM (
        SELECT
            a.ROWID AS a_rowid,
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
            RTRIM(
                CASE WHEN a.d_key1 IS NULL THEN 'd_key1|' ELSE '' END
             || CASE WHEN a.d_key2 IS NULL THEN 'd_key2|' ELSE '' END
             || CASE WHEN a.d_key3 IS NULL THEN 'd_key3|' ELSE '' END
             || CASE WHEN a.d_key4 IS NULL THEN 'd_key4|' ELSE '' END
             || CASE WHEN a.d_key5 IS NULL THEN 'd_key5|' ELSE '' END
             || CASE WHEN a.d_key6 IS NULL THEN 'd_key6|' ELSE '' END,
                '|'
            ) AS reject_reason
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
       ) s
 WHERE s.reject_reason IS NOT NULL;
SPOOL OFF

EXIT SUCCESS
