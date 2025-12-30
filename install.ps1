<#
.SYNOPSIS
    Installs the snapshot and cleanup scripts by copying files and registering scheduled tasks.

.DESCRIPTION
    Creates an installation directory, copies all necessary scripts,
    removes any old scheduled tasks to avoid duplication,
    and registers new scheduled tasks to run snapshots and cleanup automatically
    at configured intervals and times.
    Tasks run as SYSTEM with highest privileges.
#>

$installDir = "C:\SnapTime-Win"

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# Copying all scripts to the install directory
Copy-Item -Path .\*.ps1 -Destination $installDir -Force

$snapshotScript = Join-Path $installDir "snapshot.ps1"
$cleanupScript = Join-Path $installDir "cleanup.ps1"

# Removing old scheduled tasks if they exist
try { Unregister-ScheduledTask -TaskName "PSTM_Snapshot" -Confirm:$false -ErrorAction SilentlyContinue } catch {}
try { Unregister-ScheduledTask -TaskName "PSTM_Cleanup" -Confirm:$false -ErrorAction SilentlyContinue } catch {}

. "$installDir\config.ps1"

# Creating a trigger to run the snapshot script once starting today, repeating every $SnapshotIntervalMinutes for ~ 10 years
$triggerSnapshot = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes $SnapshotIntervalMinutes) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

# Creating a trigger to run the cleanup script daily at the configured time
$cleanupDateTime = [datetime]::Today.Add(
    [TimeSpan]::Parse($CleanupTime)
)

$triggerCleanup = New-ScheduledTaskTrigger -Daily -At $cleanupDateTime

# Defining the actions to execute scripts, bypassing execution policy
$actionSnapshot = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$snapshotScript`""
$actionCleanup = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$cleanupScript`""

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

Register-ScheduledTask -TaskName "PSTM_Snapshot" -Trigger $triggerSnapshot -Action $actionSnapshot -Principal $principal
Register-ScheduledTask -TaskName "PSTM_Cleanup" -Trigger $triggerCleanup -Action $actionCleanup -Principal $principal

Write-Host "Scheduled tasks have been installed."
Write-Host "Scripts and configuration are located in $installDir"
