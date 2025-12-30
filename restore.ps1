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

# Preparing and creating mount directory for the snapshot volume
$mount = "C:\ShadowMount\$ShadowID"
if (-Not (Test-Path $mount)) {
    New-Item -ItemType Directory -Path $mount | Out-Null
}

# Creating a symbolic link to the snapshot volume
cmd /c "mklink /d `"$mount`" \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy$ShadowID" | Out-Null

# Building the full source path inside the mounted snapshot
$sourceFull = Join-Path $mount $SourcePath.TrimStart("C:\")

Write-Host "Copying from $sourceFull to $DestinationPath"

Copy-Item -Path $sourceFull -Destination $DestinationPath -Recurse -Force

Write-Host "Restore completed."

Remove-Item $mount -Recurse -Force
