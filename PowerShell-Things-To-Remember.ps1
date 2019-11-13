# PowerShell things to remember

# Powershell style guide
# https://github.com/PoshCode/PowerShellPracticeAndStyle#table-of-contents

# *** Just in case you're dumb enough to try and run this ***
## How to exit from PowerShell
exit

## Get PowerShell version
$PSversionTable

# Set text zoom level of PowerShell host
$Host.PrivateData.Zoom = 125

# Output without new line (newline)
Write-Output -NoNewLine "Hello..."

## Get variable type
$myVariable.GetType()

## Array creation
$myArray = @()

## Array initialisation creating 10 elements
$myArray = @(0) * 10
$myArray2 = ,0 * 10


## Array initialisation and using for operator
for ($i=0; $i -lt 6; $i++) {
    $myArray += @(0)
}

## Hashtable creation
$myHashTable = @{}

## This should be default but for some dumb MS reason it isn't
## Ordered hashtable creation
$myHashTable = [ordered]@{}

# Create a custom object and fill in properties
$account = @()
for ($i=1; $i -lt 51; $i++){

        $account += New-Object -TypeName psobject -Property @{
            
            User = ("Name"+$i)
            Password = ("Password"+$i)
        }
}

# PowerShell 3.0 version of above is nicer, faster and preserves object property creation order
# Wow! What a difference...Blockbuster Video
$account = @()
for ($i=1; $i -lt 51; $i++){

        $account += [PSCustomObject] @{
            
            User = ("Name"+$i)
            Password = ("Password"+$i)
        }
}

# Better way using collections
$collection = New-Object 'System.Collections.Generic.LinkedList[PSCustomObject]'
for ($i=1; $i -lt 51; $i++){

    $account = [PSCustomObject] @{
        User = "Name$i"
        Password = "Password$i"
    }
    
    $collection.Add($account)
}

foreach ($item in $collection) {
    $item.User
    $item.Password
}

# Building up a text string
$log = New-Object System.Text.StringBuilder
$log.Append("Hello")
$log.AppendLine("My friend")

# Comparing two lists of objects..<= means result in reference object, == means result is in both, => means result in difference
Compare-Object -ReferenceObject $cat -DifferenceObject $mouse

# Finding duplicate objects through grouping
$somelist | Sort-Object | Group-Object | ? {$_.Count -gt 1}


# Using If...Else
if ($mouse -eq $cat) {
    
    Write-Host "No they're different"

    } else {
    Write-Host "Like I said..."
}

# Using Try...Catch
try {
    "Try something"
    
    } catch {
    "Catch an error if an exception is thrown"
}

# Using Switch
$a = 5

switch ($a) { 
    1 {"The color is red."}
    2 {"The color is blue."} 
    3 {"The color is green."} 
    4 {"The color is yellow."} 
    5 {"The color is orange."} 
    6 {"The color is purple."} 
    7 {"The color is pink."}
    8 {"The color is brown."} 
    default {"The color could not be determined."}
}
  


<# ForEach 

   loads all the items up front into memory
   before processing them one at a time.
#>

$computers = Get-ADComputer -SearchBase 'DC=dabba, DC=local' -Filter "*"
ForEach ($computer in $computers) {
    $computer.Name
}

<# ForEach-Object

Streams items via the pipeline, rather than storing all of them,
lowering memory requirements at a cost to performance.
#>

$computers = Get-ADComputer -SearchBase 'DC=dabba, DC=local' -Filter "*"
$computers | ForEach-Object {$_.Name}

# Get current element of foreach loop
foreach ($item in $array) {
    $array.IndexOf($item)
}

## Using Do...While
$i = 0
do {
    "No. $i"
    $i++

} while ($i -lt 10)


## Using try...catch for error handling
try {
        $mailbox = Get-Mailbox -Identity (Read-Host) -ErrorAction Stop

    } catch {

        Clear-Host
        Write-Output "Mailbox not found`n"

}

# Setting the default error action
$ErrorActionPreference.value__ = 1  # Stop when a cmdlet encounters an error
$ErrorActionPreference.value__ = 2  # Continue
$ErrorActionPreference.value__ = 3  # Inquire
$ErrorActionPreference.value__ = 4  # Ignore

# Wait some time
Start-Sleep -s 10 # 10 seconds

# Measure time of how long command takes to run
Measure-Command {$computers | ForEach-Object {$_.Name}}

# Measure averages 
$stats | Measure-Object -Property Value -Average


# Number formating: Specify how many decimal places
#The x specifies how many decimal places
"{0:Nx}" -f $test

$test = 23.000404040404
"{0:N3}" -f $test # Show 3 decimal places

# Use leading zeroes When displaying a value
$num = 9
$num.ToString("0#")

## To include an external script in a script 
## and use functions from external script
."c:\powershell\PowerShell-Things-To-Remember.ps1"


## Show all available functions
ls function:


## Show all available variables
ls variable:

## Delete variable
rm variable:myVariable

## Delete function
rm variable:MyFunction

## What does $_ mean
Write-Output "$_ is used to pass the current object in the pipeline through to the next operation in the pipeline...See below"

## Comparing time and dates
New-TimeSpan -Start $computer.LastLogonDate -End $date

# Convert Timestamp to DateTime (lastLogonTime)
$user = Get-ADUser "svc-crmemail" -Properties lastLogon
[datetime]::FromFileTime($user.lastLogon)

# Set a 10 second timeout
$timeout = 10
$timer = (Get-Date).AddSeconds($timeout)
do {
    # Something
} while ((Get-Date) -le $timer)

## Using regular expressions (regex)
## This input matches all alphabetical characters in at the start of a string
$regex = [regex]'^([A-z]+)([a-z])'
"Porsche911" -replace $regex,""  ## Output shows just 911
$regex = [regex]'[^0-9.]'
"Porsche911" -replace $regex,""  ## Output shows just 911
## This input matches all trailing white spaces
$regex = [regex]'[ \t]+$'

## Using comparison operators, see below for all operators
$myArray | Where-Object {$_ -like "wakawaka" -Or $_ -like "pookaluka"}

## Show full output
$myArray | Where-Object {$_ -like "wakawaka" -Or $_ -like "pookaluka"} | Format-Table -Wrap -AutoSize

## Shorcut for Where-Object
$myArray | ? {$_ -like "wakawaka" -Or $_ -like "pookaluka"} | Format-Table -Wrap -AutoSize

## Add a property to a hashtable
$myArray = @{}
$myArray | Add-Member -MemberType NoteProperty -Name 'Some Property' -Value "Some Value"

## Remove a property from an object
$myArray.PSObject.Properties.Remove('Some Property')

## Create an object
$myObject = @()

<#
    ## Load a webpage as a collection of objects
#>
$page = Invoke-WebRequest

# Using PowerShell Remoting to run commands remotely
Invoke-Command -ComputerName $computer -ScriptBlock {<# Remote commands to run in here #> $env:COMPUTERNAME}

# Using PSExec to run command remotely when PSRemoting (Invoke-Command) not supported
# Define remote command to run
$command = "SpeculationControl.exe"
# Define psexec command to run remotely and arguments
$process = New-Object System.Diagnostics.Process
$process.StartInfo.UseShellExecute = $false
$process.StartInfo.RedirectStandardInput = $false
$process.StartInfo.RedirectStandardOutput = $true
$cd = (Split-Path $Script:MyInvocation.MyCommand.Path -Parent)
$process.StartInfo.FileName = @($cd + "\PsExec.exe")
$spec = $cd + "\SpeculationControl.exe"
#  Define parameters for remote command
$param = ("\\" + ($computer.Name + " $command"))
$process.StartInfo.Arguments = $param
$process.Start() >> $null
# Get exe command output
$output = ($process.StandardOutput).ReadToEnd()

## Creating functions
function DoNothing ([int]$i, [string]$var1, [array]$myArray) {
    
    # this function receives an integer and a string variable, and an array 
}

function DoNothingToo {
    
    # this function receives an integer and a string variable, and an array
    param (
            [int]$i,
            [string]$var1,
            [array]$myArray
    ) 
         
}

# Specifying parameter arguments
function SpecifySwitchParam {
    <#
        Switch parameters, are $false if you don't specify them on the command line
        and are $true if you do specify them on the command line.
        They don't take any arguments
    #>

    param (
            [switch]$switch
    )

    if ($switch) {
    
        Write-Output "Parameter switch was specified"
    
    } else {
    
            Write-Output "Parameter switch was not specified"
    }
}

<# 
    Specifying mandatory parameter arguments
    You can also use this to parse commandline arguments
#>
function SpecifyMandatoryParam {

    param (
            [Parameter(mandatory=$true)]
            [int]$someint
    )
}

function SpecifyMultipleMandatorySwitches {
    
    param (
        [Parameter(mandatory=$true)]
        [ValidateSet('Production', 'Development', ignorecase=$true)]
        [string[]]$Environment
    )
}

function SpecifyDefaultParamValue {

    param (
            [int]$someint = 34
    )
}

<# 
    Splatting simplifies calling functions that have multiple parameters
    
    Instead of doing:
    
    SendLog -To 'tom.hardy@dabba.ac.uk' -Subject "WSUS Auto Approvals" -From "$($env:COMPUTERNAME)@dabba.ac.uk" -SMTPServer 'mail.dabba.ac.uk'
#>

# Do this for postitional splatting
$params = 
    "tom.hardy@dabba.ac.uk", # To
    "WSUS Auto Approvals", # Subject
    "$($env:COMPUTERNAME)@dabba.ac.uk", # From
    "mail.dabba.ac.uk" # SMTP server

SendLog @params

# Or this for parameter based
$params = @{
    To = "tom.hardy@dabba.ac.uk"
    Subject = "WSUS Auto Approvals"
    From = "$($env:COMPUTERNAME)@dabba.ac.uk"
    "SMTP Server" = "mail.dabba.ac.uk"
}

# Convert hashtable to object
function ConvertHashtableTo-Object {
    [CmdletBinding()]
    Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [hashtable]$ht
    )
    PROCESS {
        $results = @()
 
        $ht | %{
            $result = New-Object psobject;
            foreach ($key in $_.keys) {
                $result | Add-Member -MemberType NoteProperty -Name $key -Value $_[$key]
             }
             $results += $result;
         }
        return $results
    }
}

# Using continue
:mainloop foreach ($item in $itemResults.Items) {
    # Check for automatic replies
    if ($item.Subject -match "Automatic reply:") {
        # Auto reply found..Delete then break out back to top of loop
        DeleteMail
        continue mainloop

## Using .NET Framework
# https://msdn.microsoft.com/en-us/library/gg145045(v=vs.110).aspx
# Loading an external dll
[void] [Reflection.Assembly]::LoadFile("C:\scripts\Reset-DoorControl\Microsoft.Exchange.WebServices.dll")

$system = [System.IO.Directory]
$system::GetFiles("C:")
#Sometimes you'll have to load classes as an assembly like this
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") >> $null  # Remove >> null if you want to see command output
[System.Windows.Forms.MessageBox]::Show("Mr. Lover Man! Mr. Lover Man! Shabba!")

# Freeing system RAM by manually calling garbage collection
[System.GC]::Collect()


# Try to connect to Exchange session
$cas01 = "http://mr-mbx01/PowerShell/"
$cas02 = "http://mr-mbx02/PowerShell/"
try{
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $cas01 `
        -Authentication Kerberos -Verbose -ErrorAction Stop
}catch{
    WriteLog
    try{
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $cas02 `
                -Authentication Kerberos -Verbose -ErrorAction Stop
    }catch{
        Clear-Host
        WriteLog
        exit
    }
}
# Import Exchange PS commands into session
try {
    Import-PSSession $Session
} catch {
    Write-Log
}


## Import from CSV text file
$students = @()
$imports = Get-Content C:\students.txt -Delimiter ","
foreach ($import in $imports) {
    $students += [PSCustomObject] @{
        Email = ($import -replace ",","")
    }
}
$students | Export-Csv -NoTypeInformation C:\students.csv

# Capture output of a windows command line / DOS tool
$result = ping eugeneo -n 1 | Out-String

## Export / Outputing to CSV
$services = Get-Service
$services | Select-Object Name, Status | ConvertTo-Csv -Delimiter `t -NoTypeInformation | Out-File -NoClobber "C:\Services.csv"

## Calling functions NOTE: no brackets or commas for passing parameters
DoNothing "doo" $myArray


## Formatting output
$mbx | Format-Table Name, Server, DatabaseSize -AutoSize

## Show all truncated output
$FormatEnumerationLimit = -1


# Testing file existence
Test-Path

# Reliably testing UNC paths
Test-Path "filesystem::\\server\"

# Get path location directory of where script runs (executed) from
$cd = (Split-Path $Script:MyInvocation.MyCommand.Path -Parent) + "\"

# AD search cmdlet syntax
Get-ADUser -Filter 'Name -like "*p" -or Name -like "*-pr"'`
	-SearchBase 'OU=Users and Groups,OU=AD_Admins,DC=DABBA,DC=LOCAL'

Get-ADComputer -SearchBase 'OU=Devices,DC=DABBA,DC=LOCAL' -Filter {LastLogonTimeStamp -lt 90} -Properties LastLogonTimeStamp 


# Add AD members to a group from CSV file
$computers = Get-Content "c:\computers.csv" | ConvertFrom-Csv
foreach ($computer in $computers) {
    $comp = Get-ADComputer -Identity ($computer.FullDomainName -replace ".dabba.local","")
    Add-ADGroupMember -Members $comp.DistinguishedName "Dabba-Doos"
}

# Restart collection of computers
Get-ADGroupMember "Dabba-Servers" | ForEach-Object {
    Restart-Computer $_.Name -Confirm:$false -Force
}

# See all Powershell Providers
Get-PSProvider

# Removing variables
rm Variable:<name>

# Using .NET members
[System.Math]::Sqrt(36)

# Finding the type of a variable
$myVariable.GetType()

<#
    Create and use a credentials file
#>
#Store password as secure string (do this only once)
Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File C:\powershell\creds.txt
# Load in credentials file and create a credentials object using it and username
$user = "dabba.local\shabba"
$pass = Get-Content C:\powershell\creds.txt | ConvertTo-SecureString
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass
# Convert password back to plaintext
$cred = Get-Credential
# Convert SecureString to BasicString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.Password)
$plainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)


# Do a ping test to check a server is up or down
do {
    # Convert command output to string otherwise won't work
    $result = ping 10.22.210.174 -n 1 | Out-String
    sleep 2
} while ($result -notmatch "Reply from")

# Connect to a remote PS terminal
Enter-PSSession -ComputerName server01 -Credential $cred

# Using a range of between values as a condition
10 -in 9..11  # Matches true as 10 is between 9 and 11

<#      
    Comparison operators are all Case-Insensitive by default: prefix with c eg. -ceq to make case sensitive

 -eq             Equal
 -ne             Not equal
 -ge             Greater than or equal
 -gt             Greater than
 -lt             Less than
 -le             Less than or equal
 -like           Wildcard comparison
 -notlike        Wildcard comparison
 -match          Regular expression comparison
 -notmatch       Regular expression comparison
 -replace        Replace operator
 -contains       Containment operator
 -notcontains    Containment operator
 -shl            Shift bits left (PowerShell 3.0)
 -shr            Shift bits right – preserves sign for signed values.(PowerShell 3.0)
 -in             Like –contains, but with the operands reversed.(PowerShell 3.0)
 -notin          Like –notcontains, but with the operands reversed.(PowerShell 3.0)
To perform a Case-Sensitive comparison just prefix any of the above with "c"
for example -ceq for case-sensitive Equals or -creplace for case-sensitive replace.

Similarly prefixing with "i" will explicitly make the operator case insensitive.

Types
 -is     Is of a type
 -isnot  Is not of a type
 -as     As a type, no error if conversion fails

Logical operators
 -and    Logical And
 -or     Logical Or
 -not    logical not
  !      logical not

Bitwise operators 
 -band   Bitwise and
 -bor    Bitwise or

#>

# Remove line breaks in string
$mystring -replace "`n|`r"

 <#
 
 The following special characters are recognized by Windows PowerShell:

        `0    Null
        `a    Alert
        `b    Backspace
        `f    Form feed
        `n    New line
        `r    Carriage return
        `t    Horizontal tab
        `v    Vertical tab
        --%   Stop parsing
          

    These characters are case-sensitive. 

#>

# How to use Comment-based help

<#
     .SYNOPSIS
     eRealise Systems Reporting Solution
     ©2016 Eugene Odeluga
     
     .DESCRIPTION
     Retrieves and exports information on HSAN and HNAS storage capacity, VMware CPU, memory and storage capacity and vDatacentre usage

     .EXAMPLE
     TODO

     .NOTES
     This script requires a credentials file for vCenter login. Create one following this syntax.

     New-VICredentialStoreItem -Host <vCenter FQDN> -User <user> -Password <password> -File <filename>

     Example:
     New-VICredentialStoreItem -Host myvcenter.mydomain -User vcadmin -Password notsosecure -File c:\scripts\creds

     It is possible to specify multiple hosts separated by spaces

#>
#
#
# Must leave at least two spaces after end of comment block
