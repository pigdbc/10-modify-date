@echo off
setlocal

if "%~1"=="" (
  echo Usage: run_sqlldr.bat user/password@db
  exit /b 1
)

set "ROOT_DIR=%~dp0.."
pushd "%ROOT_DIR%"

set NLS_LANG=JAPANESE_JAPAN.AL32UTF8

if not exist out mkdir out

sqlldr "%~1" ^
  control="02-sqlldr/d_load.ctl" ^
  data="out/d_load.csv" ^
  log="out/d_load.log" ^
  bad="out/d_load.bad" ^
  discard="out/d_load.dsc" ^
  errors=999999 ^
  direct=true

set "RET=%ERRORLEVEL%"
popd
if not "%RET%"=="0" exit /b %RET%

echo SQL*Loader finished.
endlocal
