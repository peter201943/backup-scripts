
:: CONFIG
:: Settings to control backup

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
set drive_letter=E

:: This is the folder path used for keeping logs of the backup process
:: Note that this is on the EXTERNAL drive, not on a local folder
:: set log_path=C:\Users\Public\Downloads\%backup_name%.log.txt
set log_path=%drive_letter%:\logs\devices\%backup_name%.log.txt

:: This is the folder path for the actual backups
:: Note the same restrictions as above
set backup_path=%drive_letter%:\backups\devices\%backup_name%.backup

:: Name of file where backup targets are listed
set backup_targets=targets.txt
