<#
.SYNOPSIS
    Configuration parameters for snapshot scheduling and retention.

.DESCRIPTION
    Defines snapshot provider, volumes to snapshot, snapshot interval,
    retention period, cleanup schedule, and snapshot naming prefix.
    Modify these settings to customize backup behavior.
#>

# Possible values: "DiskShadow" | "WMI"
$SnapshotProvider = "WMI"

# Volumes to snapshot
$Volumes = @("C:")


# Snapshot interval in minutes
$SnapshotIntervalMinutes = 30

# Retention period in days for snapshots
$RetentionDays = 90

# Cleanup task daily start time (24h format)
$CleanupTime = "02:00"
