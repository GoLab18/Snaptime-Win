<#
.SYNOPSIS
    Main snapshot script dispatcher.

.DESCRIPTION
    Selects the snapshot backend based on configuration and runs the corresponding snapshot creation script.
    Requires Administrator privileges.
#>

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\utils.ps1"

Require-Admin

switch ($SnapshotProvider) {
    "DiskShadow" {
        if (-not (Test-DiskShadowAvailable)) {
            Write-Warning "diskshadow.exe not found. Cannot use DiskShadow backend."
            exit 1
        }
        Write-Host "Using DiskShadow backend."
        . "$PSScriptRoot\snapshot.diskshadow.ps1"
    }
    "WMI" {
        Write-Host "Using WMI backend."
        . "$PSScriptRoot\snapshot.wmi.ps1"
    }
    default {
        Write-Error "Invalid SnapshotProvider '$SnapshotProvider' in config.ps1. Use 'DiskShadow' or 'WMI'."
        exit 1
    }
}
