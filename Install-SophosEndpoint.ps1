# author: Eugene Odeluga
# Uninstalls old Sophos Anti-Virus Agent and installs new Sophos Endpoint Agent

function GetSophosUninstallers() {
    # Get Windows product uninstall registry keys
    $unSophos = New-Object 'System.Collections.Generic.List [PSCustomObject]'

    $uninstallerRegKeys = Get-ChildItem "HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Uninstall\",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"

    foreach ($key in $uninstallerRegKeys) {
        $prodDetails = [PSCustomObject] @{
            ProductName = ""
            Command = ""
            Argument = ""
        }

        $displayName = $key.GetValue("DisplayName")
    
        # Check current product is a Sophos one
        if ($displayName -match "Sophos") {
            
            $prodDetails.ProductName = $displayName

            # Format the command syntax ready for being run
            $cmd = $key.GetValue("UninstallString")

            if ($cmd.StartsWith("MsiExec.exe")) {
                $split = $cmd -split "{"
                $prodDetails.Command = "MsiExec.exe"
                $prodDetails.Argument = "/X {$($split[1]) /quiet"
            } else {
                $prodDetails.Command = $cmd
            }

            # Add Sophos product to collection
            $unSophos.Add($prodDetails)
        }
    }

    return $unSophos | Sort-Object ProductName -Unique
}

function IsSophosAgentInstalled() {
    $sophos = Get-Service -Name "Sophos Agent" -ErrorAction SilentlyContinue
    if ($sophos -ne $null) {return $true}
}

function IsSophosIXAgentInstalled() {
    $sophos = Get-Service -Name "Sophos MCS Agent" -ErrorAction SilentlyContinue
    if ($sophos -ne $null) {return $true}
}

function RunExe() {
    Param ($ExeName, $Arguments)

    # Prepare the process to run
    $start = New-Object System.Diagnostics.ProcessStartInfo

    # Enter in the command line arguments
    $start.Arguments = $Arguments

    # Enter the executable to run
    $start.FileName = $ExeName

    # Don't show a window
    $start.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $start.CreateNoWindow = $true
    [int]$exitCode

    # Run the external process & wait for it to finish
    $proc = [System.Diagnostics.Process]::Start($start)
    $proc.WaitForExit()
        
    return $proc.ExitCode
}

# :Main

# Uninstall old Sophos client if its installed
if (IsSophosAgentInstalled) {

    $uninstallers = GetSophosUninstallers      
    foreach ($uninstall in $uninstallers) {
        RunExe -ExeName $uninstall.Command -Arguments $uninstall.Argument
    }
}

# Install new Sophos client if not installed
if (!(IsSophosIXAgentInstalled)) {

    $exe = "\\sophos-cam\SophosUpdate\SophosSetup.exe"
    RunExe -ExeName $exe -Arguments "--quiet"
}