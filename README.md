
# Backup Scripts
A collection of miscellaneous notes and scripts for backing up computers


## Example Backup Drive Layout
```yaml
drive/:
  backups/:
    2022-01-01.device-name.backup/:
      path/to/folder/from/drive/letter:
  logs/:
    2022-01-01.device-name.log
  scripts/:
    device-specific-script/:
      backup.bat
      config.bat
      prompt.bat
      README.pdf
      targets.txt
```

