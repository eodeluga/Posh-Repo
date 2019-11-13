function GetActiveComputers {
    param (
        $DaysSinceLogOn = 14,
        [Parameter(mandatory=$true)]$SearchBase
    )
    Import-Module ActiveDirectory
    $date = Get-Date
    $activeComputers = @()
    # Get all production Windows computers in AD
    $computers = Get-ADComputer `
        -SearchBase $SearchBase `
        -Properties Name, Description, LastLogonDate, CanonicalName, OperatingSystem `
        -LDAPFilter "(OperatingSystem=*Windows*)" `
        -ResultSetSize ([int]::MaxValue) `
        -ResultPageSize ([int]::MaxValue)
    # Filter computers down to those that have logged on to AD within specified days...
    foreach ($computer in $computers) {
        if ((New-TimeSpan -Start $computer.LastLogonDate -End $date).Days -le $DaysSinceLogOn) {            
            $activeComputers += New-Object psobject -Property @{
                Name = $computer.Name
                OS = $computer.OperatingSystem
                Description = $computer.Description
                Path = $computer.CanonicalName
            }
        }
    }
    return $activeComputers
}