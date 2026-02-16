-- Template for question 1:
-- Keep processing even when one row fails.
-- Good rows continue; bad rows are logged.

DECLARE
  CURSOR c_src IS
    SELECT *
      FROM a;

  v_ok_cnt   NUMBER := 0;
  v_ng_cnt   NUMBER := 0;

  -- Replace with your real log table/columns
  PROCEDURE log_ng(p_rowid VARCHAR2, p_reason VARCHAR2) IS
  BEGIN
    INSERT INTO d_reject_log(source_rowid, reject_reason, log_at)
    VALUES (p_rowid, p_reason, SYSTIMESTAMP);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
BEGIN
  FOR r IN c_src LOOP
    SAVEPOINT sp_one_row;
    BEGIN
      -- Replace these assignments with real logic
      -- v_d_key1 := ...
      -- v_d_key2 := ...
      -- ...

      -- Example validation for d primary key (first 6 columns)
      IF r.d_key1 IS NULL OR r.d_key2 IS NULL OR r.d_key3 IS NULL
         OR r.d_key4 IS NULL OR r.d_key5 IS NULL OR r.d_key6 IS NULL THEN
        log_ng(TO_CHAR(r.ROWID), 'PK_NULL');
        v_ng_cnt := v_ng_cnt + 1;
        ROLLBACK TO sp_one_row;
        CONTINUE;
      END IF;

      INSERT INTO d(
        d_key1, d_key2, d_key3, d_key4, d_key5, d_key6,
        b_match_flg, c_match_flg, a_value, b_value, c_value, created_at, updated_at
      )
      VALUES (
        r.d_key1, r.d_key2, r.d_key3, r.d_key4, r.d_key5, r.d_key6,
        0, 0, r.a_value, NULL, NULL, SYSTIMESTAMP, SYSTIMESTAMP
      );

      v_ok_cnt := v_ok_cnt + 1;

      -- Commit in batches (avoid commit per row)
      IF MOD(v_ok_cnt, 1000) = 0 THEN
        COMMIT;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        log_ng(TO_CHAR(r.ROWID), SQLCODE || ':' || SUBSTR(SQLERRM, 1, 300));
        v_ng_cnt := v_ng_cnt + 1;
        ROLLBACK TO sp_one_row;
        CONTINUE;
    END;
  END LOOP;

  COMMIT;
END;
/
