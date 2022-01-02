
:: PROMPT
:: Sequence of prompts to help prevent misconfiguration

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

:: Greet the user/tell them what this program is
::    "How can I make an "are you sure" prompt in a Windows batchfile?"
::    https://stackoverflow.com/questions/1794547/how-can-i-make-an-are-you-sure-prompt-in-a-windows-batchfile
::    https://stackoverflow.com/a/51117474
echo === Simple Robocopy Backup Script for Mom and Dad ===

:: Run Tests and Quit if any fail
call test.bat
if errorlevel 2 exit /B 1

:: Tell the user what the script expects
echo/
echo Question 1
echo Before this script runs, a series of questions will confirm the setup.
echo Type Y to continue
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 exit /B 1

:: All the files to backup must be specified in some "backup_targets.txt"
:: These should just be the plaintext paths of each file and NOTHING ELSE
:: (Blank Lines are acceptable)
::    "Robocopy from list.txt"
::    https://serverfault.com/questions/652119/robocopy-from-list-txt
::    https://serverfault.com/a/784056
echo/
echo Question 2
echo Is this list of paths to backup correct?
for /f "tokens=*" %%a in (%backup_targets%) do (
  echo   - %%a
)
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo Please correct the paths in BACKUPDRIVE\scripts\THISSCRIPT\backup_targets.txt
  exit /B 1
)

:: Does each target location exist?
::    "How to check if a file exists from inside a batch file [duplicate]"
::    https://stackoverflow.com/questions/4340350/how-to-check-if-a-file-exists-from-inside-a-batch-file
::    https://stackoverflow.com/a/4340395
echo/
echo Question 3
for /f "tokens=*" %%a in (%backup_targets%) do (
  if not exist %%a echo WARNING could not find %%a
)
echo Any paths that could not be found will be skipped during copying
echo Proceed?
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo Please correct the paths in BACKUPDRIVE\scripts\THISSCRIPT\backup_targets.txt
  exit /B 1
)

:: Is "info.txt" missing?
::    "How to check if a file exists from inside a batch file [duplicate]"
::    https://stackoverflow.com/questions/4340350/how-to-check-if-a-file-exists-from-inside-a-batch-file
::    https://stackoverflow.com/a/4340395
if not exist info.txt (
  echo/
  echo Question 4
  echo "NOTICE The documentation (info.txt) could not be found"
  echo Proceed anyways?
  CHOICE /C YN /M "Press Y for Yes, N for No"
  if errorlevel 2 (
    echo Please check BACKUPDRIVE\scripts\generic\ for a copy of info.txt
    exit /B 1
  )
)

:: Has the user read the documentation?
echo/
echo Question 5
echo Have you read "info.txt" recently and are you aware of what actions the program will take?
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo You can find info.txt in BACKUPDRIVE\scripts\THISSCRIPT\info.txt
  exit /B 1
)

:: Is the device name correct?
echo/
echo Question 6
echo Is this device "%device_name%"?
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo Please see info.txt for assistance
  exit /B 1
)

:: Is the date correct?
echo/
echo Question 7
echo Is today %todays_date% (YYYY-MM-DD)?
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo This will require additional assistance to resolve
  echo In the short-term, you can override the date in the file with
  echo set todays_date=2022-01-01
  exit /B 1
)

:: Is the log location correct?
echo/
echo Question 8
echo Is the log path correct?
echo %log_path%
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo Please edit this script to change log path
  exit /B 1
)

:: Does the log location exist?
::    "How to check if a file exists from inside a batch file [duplicate]"
::    https://stackoverflow.com/questions/4340350/how-to-check-if-a-file-exists-from-inside-a-batch-file
::    https://stackoverflow.com/a/4340395
if exist %log_path% (
  echo/
  echo Question 9
  echo NOTICE a log already exists at %log_path%
  echo Proceed? (Will append to log)
  CHOICE /C YN /M "Press Y for Yes, N for No"
  if errorlevel 2 (
    echo Please edit this script to change log path
    exit /B 1
  )
)

:: Is the backup location correct?
echo/
echo Question 10
echo Is the backup path correct?
echo %backup_path%
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo Please edit this script to change backup path
  exit /B 1
)

:: Does the backup location already exist?
::    "How to check if a file exists from inside a batch file [duplicate]"
::    https://stackoverflow.com/questions/4340350/how-to-check-if-a-file-exists-from-inside-a-batch-file
::    https://stackoverflow.com/a/4340395
if exist %backup_path% (
  echo/
  echo Question 11
  echo WARNING a backup already exists at %backup_path%
  echo Proceed? (Overwrites current)
  CHOICE /C YN /M "Press Y for Yes, N for No"
  if errorlevel 2 (
    echo Please edit this script to change backup path
    exit /B 1
  )
)

:: Final Notice to Begin Copying
echo/
echo Question 12
echo Everything is ready, begin copying now?
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 exit /B 1

:: Begin the Backup
call backup.bat

:: Wait for user to confirm done
echo/
echo Backup Complete
pause
