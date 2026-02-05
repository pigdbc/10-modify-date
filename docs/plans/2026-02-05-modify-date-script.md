# Modify Date Script Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a PowerShell tool that edits UTF-16LE Japanese CSVs based on filename class, validates YYYYMMDD input, and writes updated CSVs plus logs to `out/`.

**Architecture:** A single PowerShell script loads configuration from `SetEnv.bat`, prompts for file selection and date, edits one target column per file based on filename prefix, and writes outputs. A small test script runs the tool in non-interactive mode against sample input files.

**Tech Stack:** PowerShell (pwsh), CSV import/export with UTF-16LE, basic filesystem operations.

### Task 1: Create base folders and configuration

**Files:**
- Create: `10-修改日期/input`
- Create: `10-修改日期/out`
- Create: `10-修改日期/SetEnv.bat`

**Step 1: Create folders**
Run: `mkdir -p 10-修改日期/input 10-修改日期/out`
Expected: directories exist

**Step 2: Create configuration file**
Create `10-修改日期/SetEnv.bat` with:
```
@echo off
set CLASS1_PREFIX=テーベ
set CLASS1_FIELD=a
set CLASS2_PREFIX=テこ
set CLASS2_FIELD=b
```
Expected: file exists with editable values

**Step 3: Commit**
```bash
git add 10-修改日期/input 10-修改日期/out 10-修改日期/SetEnv.bat

git commit -m "feat: add base folders and config"
```

### Task 2: Write failing test script (non-interactive)

**Files:**
- Create: `10-修改日期/tests/run.ps1`

**Step 1: Write failing test**
Create `10-修改日期/tests/run.ps1` that:
- Creates two UTF-16LE CSVs in `10-修改日期/input` (one with header `a`, one with header `b`)
- Calls `Modify-Date.ps1` with `-Paths` and `-Date` (e.g. `20260205`)
- Asserts output files exist and all values in target column match date
- Throws if any check fails

**Step 2: Run test to verify it fails**
Run: `pwsh 10-修改日期/tests/run.ps1`
Expected: FAIL because `Modify-Date.ps1` does not exist yet

**Step 3: Commit**
```bash
git add 10-修改日期/tests/run.ps1

git commit -m "test: add initial failing test script"
```

### Task 3: Implement Modify-Date.ps1

**Files:**
- Create: `10-修改日期/Modify-Date.ps1`

**Step 1: Implement minimal script**
Implement:
- Load `SetEnv.bat` and parse `set KEY=VALUE` lines into a hashtable
- Resolve `input` and `out` paths relative to script directory
- If `-Paths` provided, use them; else list files in `input` and use `Out-GridView -PassThru`
- Prompt for date if `-Date` missing; validate with regex + ParseExact
- For each file:
  - Decide class by filename prefix
  - Determine target field from config
  - Import CSV as UTF-16LE
  - Verify target column exists; if not, warn in Japanese and skip
  - Update all rows’ target field to date
  - Export to `out` as UTF-16LE
  - Write a `.log` file in `out` saying the field was updated
- All user-facing messages in Japanese

**Step 2: Run test to verify it passes**
Run: `pwsh 10-修改日期/tests/run.ps1`
Expected: PASS with no thrown errors

**Step 3: Commit**
```bash
git add 10-修改日期/Modify-Date.ps1

git commit -m "feat: add csv date modifier script"
```

### Task 4: Add sample CSVs for user confirmation

**Files:**
- Create: `10-修改日期/input/テーベサンプル.csv`
- Create: `10-修改日期/input/テこサンプル.csv`

**Step 1: Generate sample CSVs**
Use a PowerShell one-liner to create UTF-16LE CSVs with a few rows.

**Step 2: Run the test script again**
Run: `pwsh 10-修改日期/tests/run.ps1`
Expected: PASS

**Step 3: Commit**
```bash
git add 10-修改日期/input/テーベサンプル.csv 10-修改日期/input/テこサンプル.csv

git commit -m "test: add sample input csv files"
```

### Task 5: Verification

**Step 1: Manual interactive smoke test**
Run: `pwsh 10-修改日期/Modify-Date.ps1` and verify:
- file picker opens
- invalid date rejected
- output files and logs created in `out`

**Step 2: Record result in response**
If any step fails, capture the error message and report.
