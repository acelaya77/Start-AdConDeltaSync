<#
.SYNOPSIS
    Initiates a delta synchronization cycle on the active Azure AD Connect server.

.DESCRIPTION
    This function identifies the active Azure AD Connect server from a provided list of servers,
    waits for any ongoing synchronization to complete, and then starts a delta sync cycle.

    It checks each server for staging mode and selects the one that is actively syncing.
    If a sync is already in progress, it waits and retries until the sync is complete.

.PARAMETER Servers
    An array of server names to check for Azure AD Connect activity.
    The function will select the first server that is not in staging mode.

.PARAMETER SleepTimeSeconds
    The number of seconds to wait between checks if a sync cycle is already in progress.
    Default is 8 seconds.

.EXAMPLE
    Start-AdConDeltaSync

    Runs the function with the default server list and sleep time of 8 seconds.

.EXAMPLE
    Start-AdConDeltaSync -Servers @('adconnect01.domain.com', 'adconnect02.domain.com') -SleepTimeSeconds 10

    Runs the function with a custom list of servers and a sleep interval of 10 seconds.

.NOTES
    Author: Anthony J. Celaya
    Created: August 2025
    Purpose: Automate delta sync initiation for Azure AD Connect in a multi-server setup.

    This function assumes that:
    - PowerShell remoting is enabled and accessible on the target servers.
    - The `Get-ADSyncScheduler` and `Start-ADSyncSyncCycle` cmdlets are available on those servers.

.LINK
    https://learn.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sync-feature-scheduler
#>
function Start-AdConDeltaSync {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [String[]]$Servers = @(),

        [Parameter()]
        [int]$SleepTimeSeconds = 8
    )

    begin {
        $activeServer = $null

        if (-not $servers -or $servers.Count -eq 0) {
            $configPath = [System.IO.FileInfo](Join-Path $PSScriptRoot "config.ini")
            $config = @{}
            if ( $configPath.Exists ){
                foreach ( $line in $(get-Content $configPath)) {
                    if ($line -match '^(\w+)=(.+)$') {
                        $config[$matches[1]] = $matches[2].Trim()
                    }
                }
            }
            $servers = @($config["Primary"], $config["Secondary"])
        }
    }

    process {
        # Find the active server
        foreach ($s in $servers) {
            try {
                $sync = Invoke-Command -ComputerName $s -ScriptBlock { Get-ADSyncScheduler } -ErrorAction Stop
                if (-not $sync.StagingModeEnabled) {
                    $activeServer = $sync.PSComputerName
                    Write-Verbose ("{0:s}: Found active server '{1}'." -f (Get-Date), $activeServer)
                    break
                }
            } catch {
                Write-Warning ("{0:s}: Failed to query server '{1}': {2}" -f (Get-Date), $s, $_.Exception.Message)
            }
        }

        if (-not $activeServer) {
            throw ("{0:s}: No active server found!" -f (Get-Date))
        }

        # Wait for any ongoing sync to finish
        $counter = 0
        do {
            $counter++
            $sync = Invoke-Command -ComputerName $activeServer -ScriptBlock { Get-ADSyncScheduler }
            if ($sync.SyncCycleInProgress) {
                Write-Verbose ("{0:s}: Sync in progress. Retrying in {1} seconds..." -f (Get-Date), $SleepTimeSeconds)
                Start-Sleep -Seconds $SleepTimeSeconds
            }
        } while ($sync.SyncCycleInProgress)

        # Double-check staging mode before starting sync
        if ($sync.StagingModeEnabled) {
            Write-Warning ("{0:s}: '{1}' is in staging mode. Aborting sync." -f (Get-Date), $activeServer)
        } else {
            Write-Verbose ("{0:s}: Starting delta sync on '{1}'." -f (Get-Date), $activeServer)
            if ( $PsCmdlet.ShouldProcess("Server: $activeServer", "Start delta sync") ){
                Invoke-Command -ComputerName $activeServer -ScriptBlock { Start-ADSyncSyncCycle -PolicyType 'Delta' }
            }
        }
    }
}
