<#
.SYNOPSIS
    Restore files or folders from a specified Volume Shadow Copy snapshot.

.DESCRIPTION
    Creates a symbolic link to the selected VSS snapshot volume,
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

$normalizedShadowID = $ShadowID.Trim().ToLower()
$shadow = Get-CimInstance Win32_ShadowCopy | Where-Object {
    $_.ID.ToString().Trim().ToLower() -eq $normalizedShadowID
}

if (-not $shadow) {
    throw "Snapshot $ShadowID not found"
}

$mount = "C:\ShadowMount\$ShadowID"
$device = $shadow.DeviceObject + "\\"

if (Test-Path $mount) {
    Write-Host "Removing existing mount folder or link: $mount"
    Remove-Item -Path $mount -Recurse -Force
}

cmd /c "mklink /d `"$mount`" $device"

$sourceFull = Join-Path $mount $SourcePath

Write-Host "Restoring from snapshot:"
Write-Host "  Source:      $sourceFull"
Write-Host "  Destination: $DestinationPath"

$parentFolder = Split-Path -Path $sourceFull -Parent
Write-Host "Contents of the parent folder ($parentFolder):"
try {
    Get-ChildItem -Path $parentFolder -Force | ForEach-Object {
        Write-Host " - $($_.Name)"
    }
} catch {
    Write-Warning "Unable to list contents of $parentFolder"
}

if (-not (Test-Path $sourceFull)) {
    Write-Error "Source path '$sourceFull' does not exist in the snapshot."
    Remove-Item $mount -Recurse -Force
    exit 1
}

Copy-Item -Path $sourceFull -Destination $DestinationPath -Recurse -Force

Remove-Item $mount -Recurse -Force

Write-Host "Restore completed successfully."
