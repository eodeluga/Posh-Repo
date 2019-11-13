function ConnectExchange {
    Param ($Server)
    # Try to connect to Exchange session
    foreach ($exServer in $Server) {
        # Construct a url from server name
        $exServer = "http://$exServer/PowerShell/"
        try{
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exServer `
                -Authentication Kerberos -Verbose -ErrorAction Stop
            # Break out if successful connection
            if ($Session -ne $null) {break}
            # Wait some time
            sleep 5
        }catch{
            WriteLog
        }
    }
    if ($Session -eq $null) {
        WriteLog "ConnectExchange: Cannot Connect to Exchange"
        return
    } else {   
        # Import Exchange PS commands into session
        try {
            Import-PSSession $Session -AllowClobber
        } catch {
            WriteLog
            return
        }
    }
}