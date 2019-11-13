function MoveMDBByActivationPref {

    # Get all except the default that was created when Exchange was installed
    $mdb = Get-MailboxDatabase | ? {$_.Name -ne "Mailbox Database 1855196364"} | 
        Sort-Object Name
        
    # Log each database's current server mount location
    WriteLog -Severity Info "Mailbox database server mount info follows..." -Verbose:$false
    $mdb | ForEach-Object { 
        WriteLog -Severity Info "$($_.Name) on $($_.Server)" -Verbose:$false
    }

    # Check each database is mounted according to its activation policy
    foreach ($db in $mdb) {
        
        # Get actual server db is mounted on
        $mountedOnServer = $db.ServerName
        # Get preferred server db should be activated on
        $prefServer = $db.ActivationPreference | ? {$_.Value -eq 1}
        $prefServerName = $prefServer.Key.Name
        
        # Check that they match
        if ($mountedOnServer -ne $prefServerName) {

            WriteLog -Severity Warn "$($db.Name) mounted on $mountedOnServer but should be on $prefServerName" -Verbose:$false
            
            try {
                $params = [PSCustomObject]@{
                    Identity = $db.Name
                    ActivateOnServer = $prefServerName
                    SkipHealthChecks = $true
                    SkipActiveCopyChecks = $true
                    SkipClientExperienceChecks = $true
                    SkipLagChecks = $true
                    Confirm = $false
                    ErrorAction = "Stop"
                }

                WriteLog -Severity Info "Attempting to move $($db.Name) to $prefServerName" -Verbose:$false

                $mvResult = Move-ActiveMailboxDatabase @params
                
                # Check the result of the move
                if ($mvResult.Status -ne "Succeeded") {
                    WriteLog -Severity Error "Failed in moving $($db.Name) to $prefServerName" -Verbose:$false
                }
                
                if ($mvResult.NumberOfLogsLost -gt 0) {
                    WriteLog -Severity Warn "Logs were lost when moving $($db.Name) to $prefServerName" -Verbose:$false
                }

            } catch {
                WriteLog -Severity Error "Cannot move $($db.Name) to $prefServerName"
                continue
            }

            WriteLog -Severity Info "Successfully moved $($db.Name) from $mountedOnServer to $prefServerName" -Verbose:$false
        }
    }
}