
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
      backup.bat  # Actual Backup/Robocopy/Rsync Script
      config.bat  # Variables, Paths, Etc (See also YAML,TOML)
      prompt.bat  # HCI Prompt to walk user through choices
      README.pdf  # Documentation
      targets.txt # List of folders (Only as separate file given Batch limitations)
      tests.bat   # Tests to prevent bad behavior
```

