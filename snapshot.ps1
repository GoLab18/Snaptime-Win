<#
.SYNOPSIS
    Creates Volume Shadow Copy snapshots for configured volumes.

.DESCRIPTION
    For each volume specified in the configuration,
    generates a temporary diskshadow script and executes it to create persistent snapshots.
    Requires administrator privileges.
#>

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\utils.ps1"

Require-Admin

foreach ($vol in $Volumes) {
    Write-Host "Creating snapshot for $vol"

    $script = @"
SET CONTEXT PERSISTENT
SET METADATA C:\ShadowCopyMetadata.cab
CREATE SHADOW ON $vol
END SET
"@

    $tempScriptFile = "$env:TEMP\diskshadow_script.txt"
    $script | Out-File -FilePath $tempScriptFile -Encoding ASCII

    diskshadow.exe /s $tempScriptFile

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Snapshot for $vol created successfully."
    } else {
        Write-Error "Error creating snapshot for $vol."
    }

    Remove-Item $tempScriptFile -Force
}
