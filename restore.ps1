<#
.SYNOPSIS
    Restore files or folders from a specified Volume Shadow Copy snapshot.

.DESCRIPTION
    Creates a symbolic link to the selected VSS snapshot volume,
    then restores the specified file or folder either:
      - to a provided destination path (copy mode), or
      - directly to its original system location (in-place restore).

.PARAMETER ShadowID
    The ID (GUID) of the Volume Shadow Copy snapshot.

.PARAMETER SourcePath
    Relative path inside the snapshot volume (e.g. Users\Public\Documents\file.txt).

.PARAMETER DestinationPath
    Optional destination path. If omitted, restore happens in-place.

.NOTES
    Requires Administrator privileges.
#>

param(
    [Parameter(Mandatory)]
    [string]$ShadowID,

    [Parameter(Mandatory)]
    [string]$SourcePath,

    [Parameter(Mandatory = $false)]
    [string]$DestinationPath
)

. "$PSScriptRoot\utils.ps1"

Require-Admin

$normShadowID = $ShadowID.Trim().ToLower()

$shadow = Get-CimInstance Win32_ShadowCopy | Where-Object {
    $_.ID.ToLower() -eq $normShadowID
}

if (-not $shadow) {
    throw "Snapshot $ShadowID not found."
}

$mountRoot = "C:\ShadowMount"
$mount     = Join-Path $mountRoot $ShadowID
$device    = $shadow.DeviceObject + "\\"

if (Test-Path $mount) {
    Remove-Item -Path $mount -Recurse -Force
}

if (-not (Test-Path $mountRoot)) {
    New-Item -ItemType Directory -Path $mountRoot | Out-Null
}

cmd /c "mklink /d `"$mount`" $device" | Out-Null

$sourceFull = Join-Path $mount $SourcePath

if (-not (Test-Path $sourceFull)) {
    Remove-Item $mount -Recurse -Force
    throw "Source path '$SourcePath' does not exist in snapshot."
}

$sourceItem  = Get-Item -LiteralPath $sourceFull
$sourceIsFile = -not $sourceItem.PSIsContainer

if (-not $DestinationPath) {
    $relativePath = $SourcePath.TrimStart('\')
    $driveRoot    = $shadow.VolumeName.TrimEnd('\')

    $DestinationPath = Join-Path $driveRoot $relativePath
}

if ($sourceIsFile -and (Test-Path $DestinationPath -PathType Container)) {
    $DestinationPath = Join-Path $DestinationPath $sourceItem.Name
}

$destinationDir = Split-Path $DestinationPath -Parent
if (-not (Test-Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
}

Write-Host "Restoring from snapshot:"
Write-Host "  Source:      $sourceFull"
Write-Host "  Destination: $DestinationPath"

Copy-Item `
    -Path $sourceFull `
    -Destination $DestinationPath `
    -Recurse `
    -Force

Remove-Item $mountRoot -Recurse -Force

Write-Host "Restore completed successfully."