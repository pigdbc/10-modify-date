LOAD DATA
CHARACTERSET AL32UTF8
INFILE '/absolute/path/abc_to_d.csv'
BADFILE '/absolute/path/abc_to_d.bad'
DISCARDFILE '/absolute/path/abc_to_d.dsc'
APPEND
INTO TABLE d
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' TRAILING NULLCOLS
SKIP 0
(
  d_key1,
  d_key2,
  d_key3,
  d_key4,
  d_key5,
  d_key6,
  b_match_flg,
  c_match_flg,
  a_value,
  b_value,
  c_value,
  created_at TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  updated_at TIMESTAMP "YYYY-MM-DD HH24:MI:SS"
)
