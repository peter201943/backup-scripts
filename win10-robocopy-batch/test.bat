
:: TEST
:: These are less intended to catch input-errors
:: (Such as misconfiguration - this should be handled by prompt)
:: And moreso prevent unintended behavior
:: (So just protect against stuff not being possible)

:: Do not print each step to the console
::    "don't show batch file command when execute it?"
::    https://serverfault.com/questions/187355/dont-show-batch-file-command-when-execute-it
::    https://serverfault.com/a/187358
@echo off

:: Load Configurations
::    "How to pass variables from one batch file to another batch file?"
::    https://stackoverflow.com/questions/27595440/how-to-pass-variables-from-one-batch-file-to-another-batch-file/27595570
::    https://stackoverflow.com/a/48264867
call config.bat

:: Counts how many failures have occurred
::    "How to increment variable under DOS?"
::    https://stackoverflow.com/questions/21697199/how-to-increment-variable-under-dos
::    https://stackoverflow.com/a/25632806
set failures=0

:: This checks that a "backup_targets.txt" exists
::    "How to check if a file exists from inside a batch file [duplicate]"
::    https://stackoverflow.com/questions/4340350/how-to-check-if-a-file-exists-from-inside-a-batch-file
::    https://stackoverflow.com/a/4340395
if not exist %backup_targets% (
  echo/
  echo Test 1
  echo WARNING A list of backup targets was NOT found
  echo Please create %backup_targets% and run this script again
  set /A failures=failures+1
)

:: Check that the backup drive is connected
if not exist %drive_letter%:\ (
  echo/
  echo Test 2
  echo WARNING backup drive not found at DRIVE LETTER %drive_letter%:\
  echo if drive is connected at different letter, please revise script and try again
  set /A failures=failures+1
)

:: Check that the backup drive has correct folder structure (logs)
if not exist %drive_letter%:\logs\devices\ (
  echo/
  echo Test 3
  echo WARNING backup drive not formatted correctly
  echo Please ensure %drive_letter%:\logs\devices\ exists on the backup device
  set /A failures=failures+1
)

:: Check that the backup drive has correct folder structure (backups)
if not exist %drive_letter%:\backups\devices\ (
  echo/
  echo Test 4
  echo WARNING backup drive not formatted correctly
  echo Please ensure %drive_letter%:\backups\devices\ exists on the backup device
  set /A failures=failures+1
)

:: Check that there are no failures or else exit with an error code
if not %failures%==0 (
  echo/
  echo CRITICAL failures occurred and must be resolved before backup can begin
  pause
  exit /B 2
)

:: Otherwise let the user know tests were successful
if %failures%==0 (
  echo/
  echo All integrity tests pass, backup can begin
  exit /B 1
)
