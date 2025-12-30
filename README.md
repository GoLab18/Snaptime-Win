# Volume Shadow Copy Manager for Windows

## Description

PowerShell-based tool that automates the creation and management of Volume Shadow Copy snapshots on Windows systems.
It periodically creates point-in-time snapshots of specified volumes, allowing users to browse and restore individual files or folders from previous states. The solution includes automatic cleanup of snapshots older than a configurable retention period, ensuring efficient disk space usage.

Key features:
- Automated snapshot creation at configurable intervals
- Easy listing of existing snapshots
- File and folder restoration from any snapshot
- Automatic deletion of snapshots older than a defined retention period
- Full automation via PowerShell scripts and Windows Task Scheduler integration
- Configuration through a single config file

## Requirements

- Script execution enabled.
- PowerShell running with Administrator privileges.
- VSS service must be enabled.
- `diskshadow.exe` must be available in the system PATH (typically located at `C:\Windows\System32\diskshadow.exe`).

## How to run?

1. Copy all the provided script files into a local project folder on your machine.

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
    - Cleanup of snapshots older than `$RetentionDays` days (defaults to 90), run daily at 2:00 AM

6. To list existing snapshots, run:
    ```powershell
    .\restore.ps1 -ShadowID &lt;SnapshotID&gt; -SourcePath &lt;PathInsideSnapshot&gt; -DestinationPath &lt;RestoreLocation&gt;
    ```