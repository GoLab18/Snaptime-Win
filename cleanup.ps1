<#
.SYNOPSIS
    Deletes old Volume Shadow Copy snapshots exceeding the retention period.

.DESCRIPTION
    Deletes VSS snapshots older than retention period using CIM Remove-CimInstance.
    Requires admin privileges.
#>

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\utils.ps1"

Require-Admin

$limitDate = (Get-Date).AddDays(-$RetentionDays)

$snapshotsToDelete = Get-CimInstance Win32_ShadowCopy | Where-Object { $_.InstallDate -lt $limitDate }

foreach ($snapshot in $snapshotsToDelete) {
    Write-Host "Deleting snapshot $($snapshot.ID) created on $($snapshot.InstallDate)"
    try {
        Remove-CimInstance -InputObject $snapshot
        Write-Host "Deleted successfully."
    } catch {
        Write-Warning "Failed to delete snapshot $($snapshot.ID): $_"
    }
}
