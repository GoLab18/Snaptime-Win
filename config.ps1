<#
.SYNOPSIS
    Configuration parameters for snapshot scheduling and retention.

.DESCRIPTION
    Defines volumes to snapshot, watched paths, snapshot interval,
    retention period, cleanup schedule, and snapshot naming prefix.
    Modify these settings to customize backup behavior.
#>

# Volumes to snapshot
$Volumes = @("C:")

# Paths to back up (must be on the volumes specified above)
$WatchedPaths = @(
    "C:\Users"
)

# Snapshot interval in minutes
$SnapshotIntervalMinutes = 30

# Retention period in days for snapshots
$RetentionDays = 90

# Cleanup task daily start time (24h format)
$CleanupTime = "02:00"

# Optional prefix for snapshot names
$SnapshotPrefix = "PS-TM"
