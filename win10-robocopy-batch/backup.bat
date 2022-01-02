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

:: Drive Letter of Backup Drive
set drive_letter=D

:: This is the folder path used for keeping logs of the backup process
:: Note that this is on the EXTERNAL drive, not on a local folder
:: set log_path=C:\Users\Public\Downloads\%backup_name%.log.txt
set log_path=%drive_letter%:\logs\devices\%backup_name%.log.txt

:: This is the folder path for the actual backups
:: Note the same restrictions as above
set backup_path=%drive_letter%:\backups\devices\%backup_name%.backup

:: Name of file where backup targets are listed
set backup_targets=backup_targets.txt

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
if not exist %backup_targets% (
  echo/
  echo Question 2
  echo WARNING A list of backup targets was NOT found
  echo Please create %backup_targets% and run this script again
  echo CRITICAL FAILURE
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
echo Question 4
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
if exist %log_path% (
  echo/
  echo Question 10
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
echo Question 11
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
  echo Question 12
  echo WARNING a backup already exists at %backup_path%
  echo Proceed? (Overwrites current)
  CHOICE /C YN /M "Press Y for Yes, N for No"
  if errorlevel 2 (
    echo Please edit this script to change backup path
    exit /B 1
  )
)

:: Check that backup drive is connected
if not exist %drive_letter%:\ (
  echo/
  echo Question 13
  echo WARNING backup drive not found at DRIVE LETTER %drive_letter%:\
  echo if drive is connected at different letter, please revise script and try again
  echo CRITICAL FAILURE
  exit /B 1
)

:: Final Notice to Begin Copying
echo/
echo Question 14
echo Everything is ready, begin copying now?
CHOICE /C YN /M "Press Y for Yes, N for No"
if errorlevel 2 exit /B 1

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Backup
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Note, there is a lot going on in here, I will try to walk through each line
:: Also note, the lines CANNOT be interrupted with comments
:: First the targets are read in (%%a)
::    "Robocopy from list.txt"
::    https://serverfault.com/questions/652119/robocopy-from-list-txt
::    https://serverfault.com/a/784056
:: Then the PATH to EACH TARGET FOLDER is copied (%%c)
:: Note that this is due to the finnickiness of Batch
:: %%a %%b and %%c are all "dynamic variables" that are magically assigned to
:: Even though %%c is not listed, it exists and represents the rest of the path
:: We are splitting "C:\Users..." on the ":" character and keeping the "\Users..." part
::    "Split string with string as delimiter"
::    https://stackoverflow.com/questions/23600775/split-string-with-string-as-delimiter
::    https://stackoverflow.com/a/23600870
:: Then we are invoking Robocopy
::    "Wikipedia: Robocopy"
::    https://en.wikipedia.org/wiki/Robocopy
:: With %%a as SOURCE to COPY FROM
:: And %backup_path%%%c as DESTINATION to COPY TO
:: We copy ALL subdirectories, even EMPTY ones (/E)
:: For each Directory, Copy the Data, Attributes, and Time (/DCOPY:DAT)
:: For each File, Copy the Data, Attributes, Time, Security, and Owner (/COPY:DATSO)
:: Only Try 5 Times (/R:5)
:: Only Wait 10 Seconds before retrying (/W:10)
:: Append the status as a log to %log_path% (/LOG+:...)
:: Mirror Changes (Copy NEW files and Delete OLD files) (/MIR)
:: Also note the added quotes to allow paths with spaces
::    "How to copy directories with spaces in the name"
::    https://stackoverflow.com/questions/12027987/how-to-copy-directories-with-spaces-in-the-name
::    https://stackoverflow.com/a/36357980
for /f "tokens=*" %%a in (%backup_targets%) do (
  for /F "tokens=1,2 delims=:" %%b in ("%%a") do (
    Robocopy ^
      "%%a " ^
      "%backup_path%%%c " ^
      /E ^
      /DCOPY:DAT ^
      /COPY:DATSO ^
      /R:5 ^
      /W:10 ^
      /LOG+:"%log_path%" ^
      /MIR
  )
)

:: Potential Future Revisions
:: 1. Use a dedicated "config.bat" to hold the variables
::    "How to pass variables from one batch file to another batch file?"
::    https://stackoverflow.com/questions/27595440/how-to-pass-variables-from-one-batch-file-to-another-batch-file/27595570
::    https://stackoverflow.com/a/48264867
:: 2. Move HCI into a separate "prompt.bat"
::    Can then just run "backup.bat" on its own
