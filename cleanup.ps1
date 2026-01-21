<#
.SYNOPSIS
    Deletes old Volume Shadow Copy snapshots exceeding the retention period.

.DESCRIPTION
    This script lists all existing VSS snapshots and deletes those older than the configured retention days.
    Requires administrator privileges to manage snapshots.
#>

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\utils.ps1"

Require-Admin

$limitDate = (Get-Date).AddDays(-$RetentionDays)

Get-CimInstance Win32_ShadowCopy | ForEach-Object {
    if ($_.InstallDate -lt $limitDate) {
        Write-Host "Deleting snapshot $($_.ID) created on $($_.InstallDate)"
        Invoke-CimMethod -InputObject $_ -MethodName Delete | Out-Null
    }
}
