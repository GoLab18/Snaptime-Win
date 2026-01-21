<#
.SYNOPSIS
    Displays a filtered list of all current Volume Shadow Copy snapshots.

.DESCRIPTION
    Lists existing snapshots via WMI, showing key details like Shadow Copy ID,
    Creation Time, and Original Volume.
    Requires Administrator privileges.
#>

. "$PSScriptRoot\utils.ps1"

Require-Admin

Get-CimInstance Win32_ShadowCopy |
    Sort-Object InstallDate -Descending |
    Select-Object ID, InstallDate, VolumeName |
    Format-Table -AutoSize
