<#
.SYNOPSIS
Redistribute Mailbox Database
2019 eo15
   
.DESCRIPTION
Runs on mail server as a scheduled task that activates Exchange mailbox databases on preferred 
mailbox servers in accordance to the db's activation preference, where a failover event may have 
moved them to other servers
#>




function GetExecutionPath {
    return (Split-Path $Script:MyInvocation.MyCommand.Path -Parent)
}

# Load Exchange snapin and connect to Exchange
.'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'
Connect-ExchangeServer -Auto

# Load in all PowerShell resources
$res =  Get-ChildItem "$(GetExecutionPath)\res" | Sort-Object Name
foreach ($psfile in $res) {
    .$($psfile.FullName)
}

# Run main function for carrying out MDB moves
MoveMDBByActivationPref
exit