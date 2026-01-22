# SnapTime-Win

## Description

PowerShell-based tool that automates the creation and management of **Volume Shadow Copy** snapshots on Windows systems.  
It periodically creates point-in-time snapshots of specified volumes, allowing files and folders restoration. It includes automatic cleanup of snapshots older than a configurable retention period.

Key features:
- Automated snapshot creation at configurable intervals
- Easy listing of existing snapshots
- File and folder restoration from any snapshot
- Automatic deletion of snapshots older than a defined retention period
- Automation via PowerShell scripts and Windows Task Scheduler integration
- Configuration through a config file

## Requirements

- PowerShell running with Administrator privileges.
- VSS service must be enabled.
- Script execution enabled.
- `diskshadow.exe` must be in the system PATH if the DiskShadow backend is chosen (typically located at `C:\Windows\System32\diskshadow.exe`).

## How to run?

1. Copy the project to your local machine.

2. Run PowerShell **as Administrator**.

3. Navigate to the folder containing the scripts, for example:
   ```powershell
   cd C:\Path\To\SnapTime-Win
   ```

4. Execute the installation script:
    ```powershell
   .\install.ps1
   ```

5. This will register two scheduled tasks in Windows Task Scheduler that run automatically with configurable settings from `config.ps1`:
    - Snapshot creation every `$SnapshotIntervalMinutes` minutes (defaults to 30)
    - Cleanup of snapshots older than `$RetentionDays` days (defaults to 90), run daily at 2:00 AM (by default)

6. To list existing snapshots, run:
    ```powershell
    .\list.ps1
    ```

6. To restore in-place a file named **test.txt** from a snapshot with an id **GUID**, you can run:
    ```powershell
    .\restore.ps1 -ShadowID "{GUID}" -SourcePath "Users\test.txt"
    ```

    or:

    ```powershell
    .\restore.ps1 -ShadowID GUID -SourcePath "Users\test.txt"
    ```

6. To restore a folder named **test** from a snapshot with an id **GUID** to a folder **Backup** on your **C drive**, you can run:
    ```powershell
    .\restore.ps1 -ShadowID "{GUID}" -SourcePath "Users\test" -DestinationPath "C:\Backup"
    ```

## Snapshot Backend Selection

You can configure which snapshot engine to use by setting the `$SnapshotProvider` variable in `config.ps1`:

- `WMI (default)`: Uses the native WMI Win32_ShadowCopy interface. Compatible with both Windows Client and Server editions and does not require `diskshadow.exe`.
- `DiskShadow`: Uses the `diskshadow.exe` utility which is available only on `Windows Server` editions.
