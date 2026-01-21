<#
.SYNOPSIS
    Main snapshot script dispatcher.

.DESCRIPTION
    Selects the snapshot backend based on configuration or an explicit script parameter -Provider 
    and runs the corresponding snapshot creation script.
    Requires Administrator privileges.
#>

param(
    [ValidateSet("WMI", "DiskShadow")]
    [string]$Provider
)

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\utils.ps1"

Require-Admin

$SnapshotProvider = if ($PSBoundParameters.ContainsKey("Provider")) {
    Write-Host "Snapshot provider overridden via parameter: $Provider"
    $Provider
} else {
    Write-Host "Snapshot provider loaded from config: $SnapshotProvider"
    $SnapshotProvider
}

switch ($SnapshotProvider) {
    "DiskShadow" {
        if (-not (Test-DiskShadowAvailable)) {
            Write-Error "DiskShadow backend selected but diskshadow.exe is not available on this system."
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
