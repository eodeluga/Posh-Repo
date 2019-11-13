function SendLog() {
# 22/06/2018 UPDATE: Added the 'don't send log entry more than once' feature

<#
.SYNOPSIS
Emails a log file located in the current directory to the specified recipient(s) if it contains entries from the current date

.DESCRIPTION
NONE 

.EXAMPLE
SendLog -To "shabba.ranks@gmail.com" -Subject "Today's log droppings" -From "loverman@hotmail.com" -SMTPServer "cam-i-mail01"

You can prepend a message to the log

SendLog -To "shabba.ranks@gmail.com" -Subject "Today's log droppings" -From "loverman@hotmail.com" -Prepend "We have droppings for you" -SMTPServer "cam-i-mail01"

.NOTES
NONE

#>





    Param ( 
        # email attributes
        [Parameter(mandatory=$true)]
        $To,
        [Parameter(mandatory=$true)]
        $Subject,
        [Parameter(mandatory=$true)]
        $From,
        $Prepend
    )

    # Magic value
    $magic = "8583656870856775"

     # Try to get path for script file being executed otherwise set to the current directory
    try {
        $invoc = "$(Split-Path $Script:MyInvocation.MyCommand.Path -Parent)"
    } catch { $invoc = $pwd.Path }
    $path = "$invoc\log.txt"
    # Check if log file exists
    if (Test-Path -Path $path) {
        try {
            $log = Get-Content $path
        } catch {
            WriteLog
        }
        # Get today's date
        $date = Get-Date -UFormat "%d/%m/%Y"
        # Check if log file contains any entries for today
        foreach ($line in $log) {
            if ($line -match $date) {
                
                # Skip line if it contains magic value
                if ($line -match $magic) {continue}
                
                # Store the line and HTML format it for sending 
                $logForToday += "$($line)<p>"

                # Append the magic value to the log entry 
                # so it is not sent more than once
                foreach ($entry in $log) {
                    if ($entry -eq $line) {
                        $log[$log.IndexOf($entry)] = "$magic - $line"
                    }
                }
            }
        }

        # Write updated log file back to disk
        try {
            $log | Set-Content $path -Force -Confirm:$false
        } catch {
            WriteLog
        }

        # Send today's log entries if there are any
        if ($logForToday -ne $null) {
            if ($Prepend -ne $null) {
                $Prepend = "<font color=red>$Prepend</font><p>"
                $logForToday = "$($Prepend)$($logForToday)"
            }

            $params = $To, $Subject, $logForToday, $From
            SendMail @params
        }
    }
}