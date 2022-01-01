:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Information
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: MIT License
:: 
:: Copyright 2021 Peter Mangelsdorf
:: 
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
:: 
:: The above copyright notice and this permission notice shall be included in all
:: copies or substantial portions of the Software.
:: 
:: 
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
:: SOFTWARE.
:: 
:: https://opensource.org/licenses/MIT

:: Info
:: Title:           Simple Robocopy Backup Script for Mom and Dad
:: UUID:            a2ab1d0d-a348-4f47-839d-2ebf09281293
:: Version:         0.0.1
:: Repo:            https://github.com/peter201943/backup-scripts
:: Created On:      2022-01-01
:: Created By:      Peter James Mangelsdorf
:: Contact At:      peter.j.mangelsdorf@outlook.com
:: Last Updated On: 2022-01-01

:: A Note on Batch Scripting
::
:: A "README.docx" should also be included with this script
:: And covers many of the same details in here
:: With pictures and additional documentation
:: If you are a non-technical user, read that documentation instead
::
:: Microsoft Windows Batch is really old and poorly specified.
::    "Wikipedia: Batch file"
::    https://en.wikipedia.org/wiki/Batch_file
:: But it is included by default on all Windows OS < Windows 11
:: (Please use PowerShell or Python for Windows 11 and greater)
:: 
:: Because of the finnicky and confusing nature of Batch
:: I have commented each line of code with an explanation of what we are doing
:: And included a linked article to explain what is going on.
:: Most of these linked articles are on StackOverflow or one of its various subsidiaries
::    "Wikipedia: Stack Overflow"
::    https://en.wikipedia.org/wiki/Stack_Overflow
:: These include a discussion and a list of alternate solutions
:: 
:: Because Windows cannot distinguish betweewn uppercase and lowercase letters
:: Snake case is used in all the variable names
::    "Wikipedia: Snake case"
::    https://en.wikipedia.org/wiki/Snake_case
::
:: To edit Batch Scripts, please use a decent Text Editor
:: (NOT "notepad.exe" (default on Windows Installs))
:: If possible download Microsoft Visual Studio Code
:: https://code.visualstudio.com/
:: (Free and Lightweight)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Setup
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Do not print each step to the console
::    "don't show batch file command when execute it?"
::    https://serverfault.com/questions/187355/dont-show-batch-file-command-when-execute-it
::    https://serverfault.com/a/187358
@echo off

:: Use for log file names and backup folder names
::    "How to find the PCs name in a batch script?"
::    https://superuser.com/questions/852373/how-to-find-the-pcs-name-in-a-batch-script
::    https://superuser.com/a/852388
set device_name=%COMPUTERNAME%

:: Record Today's Date in ISO 8601 Format (YYYY-MM-DD) for use in logs and backup names
::    "Windows batch: formatted date into variable"
::    https://stackoverflow.com/questions/10945572/windows-batch-formatted-date-into-variable/23755278
::    https://stackoverflow.com/a/10945887/12174419
for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined temp_date set temp_date=%%x
set todays_date=%temp_date:~0,4%-%temp_date:~4,2%-%temp_date:~6,2%

:: This is the name used both in logfiles and in backup folders
:: Should take the form of "YYYY-MM-DD.DEVICENAME"
set backup_name=%todays_date%.%device_name%

:: This is the folder path used for keeping logs of the backup process
:: Note that this is on the EXTERNAL drive, not on a local folder
:: Note that this assumes DRIVE LETTER "D"
:: If DRIVE LETTER "D" is NOT the backup drive, please change it
:: set log_path=C:\Users\Public\Downloads\%backup_name%.log.txt
set log_path=D:\logs\devices\%backup_name%.log.txt

:: This is the folder path for the actual backups
:: Note the same restrictions as above
:: If DRIVE LETTER "D" is not being used for backups, please change it
set backup_path=D:\backups\devices\%backup_name%.backup

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Human Interaction
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Greet the user/tell them what this program is
::    "How can I make an "are you sure" prompt in a Windows batchfile?"
::    https://stackoverflow.com/questions/1794547/how-can-i-make-an-are-you-sure-prompt-in-a-windows-batchfile
::    https://stackoverflow.com/a/51117474
echo === Simple Robocopy Backup Script for Mom and Dad ===

:: Tell the user what the script expects
echo/
echo Question 1
echo Before this script runs, a series of questions will confirm the setup.
echo Type Y to continue
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 exit /B 1

:: This checks that a "backup_targets.txt" exists
::    "How to check if a file exists from inside a batch file [duplicate]"
::    https://stackoverflow.com/questions/4340350/how-to-check-if-a-file-exists-from-inside-a-batch-file
::    https://stackoverflow.com/a/4340395
if not exist backup_targets.txt (
  echo/
  echo Question 2
  echo WARNING A list of backup targets was NOT found
  echo Please create backup_targets.txt and run this script again
  exit /B 1
)

:: All the files to backup must be specified in some "backup_targets.txt"
:: These should just be the plaintext paths of each file and NOTHING ELSE
:: (Blank Lines are acceptable)
::    "Robocopy from list.txt"
::    https://serverfault.com/questions/652119/robocopy-from-list-txt
::    https://serverfault.com/a/784056
echo/
echo Question 3
echo Is this list of paths to backup correct?
for /f "tokens=*" %%a in (backup_targets.txt) do (
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
echo Question 4
for /f "tokens=*" %%a in (backup_targets.txt) do (
  if not exist %%a echo WARNING could not find %%a
)
echo Any paths that could not be found will be skipped during copying
echo Proceed?
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo Please correct the paths in BACKUPDRIVE\scripts\THISSCRIPT\backup_targets.txt
  exit /B 1
)

:: Is README.pdf missing?
::    "How to check if a file exists from inside a batch file [duplicate]"
::    https://stackoverflow.com/questions/4340350/how-to-check-if-a-file-exists-from-inside-a-batch-file
::    https://stackoverflow.com/a/4340395
if not exist README.pdf (
  echo/
  echo Question 5
  echo "NOTICE The documentation (README.pdf) could not be found"
  echo Proceed anyways?
  CHOICE /C YN /M "Press Y for Yes, N for No"
  if errorlevel 2 (
    echo Please check BACKUPDRIVE\scripts\generic\ for a copy of README.pdf
    exit /B 1
  )
)

:: Has the user read the documentation?
echo/
echo Question 6
echo Have you read "README.pdf" recently and are you aware of what actions the program will take?
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo You can find README.pdf in BACKUPDRIVE\scripts\THISSCRIPT\README.pdf
  exit /B 1
)

:: Is the device name correct?
echo/
echo Question 7
echo Is this device "%device_name%"?
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo Please see README.pdf for assistance
  exit /B 1
)

:: Is the date correct?
echo/
echo Question 8
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
echo Question 9
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
if not exist %log_path% (
  echo/
  echo Question 10
  echo WARNING could not find %log_path%
  echo Proceed?
  CHOICE /C YN /M "Press Y for Yes, N for No"
  if errorlevel 2 (
    echo Please edit this script to change log path
    exit /B 1
  )
)

:: Is the backup location correct?
echo/
echo Question 11
echo Is the backup path correct?
echo %backup_path%
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 (
  echo Please edit this script to change backup path
  exit /B 1
)

:: Does the backup location exist?
::    "How to check if a file exists from inside a batch file [duplicate]"
::    https://stackoverflow.com/questions/4340350/how-to-check-if-a-file-exists-from-inside-a-batch-file
::    https://stackoverflow.com/a/4340395
if not exist %backup_path% (
  echo/
  echo Question 12
  echo WARNING could not find %backup_path%
  echo Proceed?
  CHOICE /C YN /M "Press Y for Yes, N for No"
  if errorlevel 2 (
    echo Please edit this script to change backup path
    exit /B 1
  )
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Backup
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: TEMP TEST DANGER
:: Robocopy ^
::   /SD:$SOURCE ^
::   /DD:$DEST ^
::   /E ^
::   /ZB ^
::   /DCOPY:DAT ^
::   /COPYALL ^
::   /R:5 ^
::   /W:10 ^
::   /LOG:$LOGFILE ^
::   /MIR
:: 