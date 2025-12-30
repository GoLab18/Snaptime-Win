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

# Calculating the cutoff date for snapshot retention
$limitDate = (Get-Date).AddDays(-$RetentionDays)

$vss = vssadmin list shadows

# Splitting the output into blocks, each describing one snapshot, by "Shadow Copy ID"
$blocks = ($vss -split "Shadow Copy ID:")[1..($vss.Length)]

foreach ($block in $blocks) {
    if ($block -match "Creation Time:\s+(.*)") {
        $creationDate = Get-Date $matches[1]

        if ($creationDate -lt $limitDate) {
            if ($block -match "{(.*?)}") {
                $shadowId = $matches[1]
                Write-Host "Deleting snapshot $shadowId, created on $creationDate"
                vssadmin delete shadows /Shadow={$shadowId} /Quiet
            }
        }
    }
}