function WriteLog() {
    <#
        .SYNOPSIS
        Eugene Odeluga 2017
        Writes an error log file (log.txt) to the directory of calling script.

        .DESCRIPTION 
        Writes an error log file to the directory of the calling script.
        This can contain system generated exception errors and/or a specified error.
        Each error log can have a timestamp and the maximum log size can be specified.

        .EXAMPLE
        WriteLog
        This will output the last exception error and a timestamp

        .EXAMPLE
        WriteLog -Severity Info
        As above, but this will prepend the severity level to the output

        .EXAMPLE
        WriteLog "This is an error"
        This will output the string specified as well as the last exception error and timestamp

        .EXAMPLE
        WriteLog "This is an error" -TimeStamp:$false
        As above but omits timestamp

        .EXAMPLE
        WriteLog "This is an error" -Verbose:$false
        Outputs specified string and timestamp only with system generated exception message

        .EXAMPLE
        WriteLog -MaxSize 100MB
        Changes the maximum log size from the 10MB default
    #>

    # Update: 27/03/2019 - Cleaned up some code (still dirty)
    # Update: 27/03/2019 - Added severity levels
    # Update: 04/04/2019 - Set the Verbose parameter switch to true as default for legacy code
    # Fix: 09/04/2019 - Bug fix - Empty log entries being written to disk




    [CmdletBinding()]
    Param (
        # Default function parameter values
        $Output,
        [ValidateSet("Info", "Verbose", "Warn", "Error")]
        $Severity,
        $TimeStamp = $true,
        $MaxSize = 10MB
    )
   
    function SetVerboseSwitch() {
        Param($BoundParams)
        $isVerbose = $true
        # Check whether Verbose default parameter has been specified
        if ($BoundParams.ContainsKey("Verbose")) {
            # Set isVerbose to false as this has been requested in default params
            if(!$BoundParams.Verbose.IsPresent) { $isVerbose = $false }
        }
        return $isVerbose
    }

    function GetCallingScriptPath() {
        # Try to get path for script file being executed otherwise set to the current directory
        try {
            $invoc = "$(Split-Path $Script:MyInvocation.MyCommand.Path -Parent)"
        } catch { $invoc = $pwd.Path }

        return "$($invoc)\log.txt"
    }

    function RemoveOverSizedLog() {
        Param ($Path,$Max)

        # Check for existing log file and remove if size exceeds max
        if (Test-Path -Path $Path) {
            if ((Get-Item $Path).Length -ge $Max) {
                Remove-Item $Path
            }
        }
    }

    function GetTimeStamp() {

        if ($TimeStamp) {
            $time = (Get-Date).ToString()
            return "$time - "
        } else {return $null}
    }

    function GetSeverity() {
        return $Severity
    }

    function GetUserMessage() {
        return $Output
    }

    function GetExceptionMessage() {
        
        # Add the full exception message if the Verbose default
        # cmdlet switch was specified
        if ($isVerbose) {
            $lastException = ($Error[0].Exception.Message)
            
            # Clear down error so it is not repeated in subsequent calls
            $Error.Clear()

            if ($lastException -ne $null) {
                return $lastException
            }
        }
    }
    
    function ComposeLog() {

        Param([String]$SeverityLevel, [string]$UserMessage, [string]$ExceptionMessage)

        function isUserMessage() {

            if (($UserMessage -ne $null) -and ($UserMessage -ne "")) {
                return $true
            }
        }

        function isExceptionMessage() {

            if (($ExceptionMessage -ne $null) -and ($ExceptionMessage -ne "")) {
                return $true
            }
        }

        function isSeverity() {

            if (($SeverityLevel -ne $null) -and ($SeverityLevel -ne "")) {
                return $true
            }
        }

        # Add severity level
        if (isSeverity) { $sev = "$SeverityLevel - " } 
        
        # Add user message
        if (isUserMessage) { $usrMsg = $UserMessage } 
        
        if (isExceptionMessage) {
            if (isUserMessage) {
                $usrMsg = "$UserMessage - "
                $exMsg = $ExceptionMessage
                
            } else { $exMsg = $ExceptionMessage }
        }

        $logComp = "$(GetTimeStamp)$($sev)$($usrMsg)$($exMsg)"
        return $logComp
    }

    function LoggingRequired() {

        if (($Output -ne $null) -or ($Error[0] -ne $null)) {
            return $true
        }
    }


    if (LoggingRequired) {
    
        # Set isVerbose switch to true as default unless explicitly specified as false
        $isVerbose = SetVerboseSwitch -BoundParams $PSBoundParameters

        $path = GetCallingScriptPath
        
        # If existing log is bigger than max then nuke it
        RemoveOversizedLog -Path $path -Max $MaxSize

        # Compose the log entry from elements
        $params = [psobject] @{
            SeverityLevel = GetSeverity
            ExceptionMessage = GetExceptionMessage
            UserMessage = GetUserMessage
        }

        # Add the log entry
        $log = New-Object System.Text.StringBuilder
        $log.AppendLine($(ComposeLog @params)) | Out-Null
        
        # Write the log out to file
        $log.ToString() | Out-File -Append -FilePath $path
    }
}