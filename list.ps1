<#
.SYNOPSIS
    Displays a filtered list of all current Volume Shadow Copy snapshots.

.DESCRIPTION
    Runs 'vssadmin list shadows' and filters the output to show key snapshot details:
    Shadow Copy ID, Creation Time, and Original Volume.
    Requires administrator privileges.
#>

. "$PSScriptRoot\utils.ps1"

Require-Admin

Write-Host "List of snapshots (Volume Shadow Copies):"

vssadmin list shadows | Select-String "Shadow Copy ID|Creation Time|Original Volume"
