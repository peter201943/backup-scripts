
:: BACKUP
:: Just the backup, no prompts for configuring

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

:: Run Tests and Quit if any fail
call test.bat
if errorlevel 2 exit /B 1

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
