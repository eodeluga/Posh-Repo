<#
.SYNOPSIS
Returns the path of where a script is executed

.DESCRIPTION 

.EXAMPLE
NONE

.NOTES
NONE

#>




function GetScriptPath {
    $sPath = Split-Path $Script:MyInvocation.MyCommand.Path -Parent
    return $sPath
}