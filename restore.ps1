<#
.SYNOPSIS
    Restore files or folders from a specified Volume Shadow Copy snapshot.

.DESCRIPTION
    This script creates a symbolic link to the selected VSS snapshot volume,
    then copies the specified source file or folder from the snapshot to a destination path.

.PARAMETER ShadowID
    The ID (GUID suffix) of the Volume Shadow Copy snapshot to restore from.

.PARAMETER SourcePath
    The relative path inside the snapshot volume to the file or folder to restore.

.PARAMETER DestinationPath
    The destination path on the local system where the file or folder will be copied.

.NOTES
    Requires Administrator privileges to create symbolic links and access VSS snapshots.
#>

param(
    [Parameter(Mandatory)]
    [string]$ShadowID,

    [Parameter(Mandatory)]
    [string]$SourcePath,

    [Parameter(Mandatory)]
    [string]$DestinationPath
)

. "$PSScriptRoot\utils.ps1"

Require-Admin

$shadow = Get-CimInstance Win32_ShadowCopy | Where-Object ID -eq $ShadowID

if (-not $shadow) {
    throw "Snapshot $ShadowID not found"
}

$mount = "C:\ShadowMount\$ShadowID"
$device = $shadow.DeviceObject

if (-not (Test-Path $mount)) {
    New-Item -ItemType Directory -Path $mount | Out-Null
}

cmd /c "mklink /d `"$mount`" $device" | Out-Null

$sourceFull = Join-Path $mount $SourcePath

Write-Host "Restoring from snapshot:"
Write-Host "  Source:      $sourceFull"
Write-Host "  Destination: $DestinationPath"

Copy-Item -Path $sourceFull -Destination $DestinationPath -Recurse -Force

Remove-Item $mount -Recurse -Force

Write-Host "Restore completed successfully."
