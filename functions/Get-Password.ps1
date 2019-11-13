function Get-Password() {
<#
.SYNOPSIS
Get-Password
© Eugene Odeluga

     
.DESCRIPTION
Generates a password of specified length by randomly choosing characters from ASCII set

Defaults to use a password of 10 characters long consisting of only alpha-numeric characters.

Can return the password as a standard or secure string

.EXAMPLE
Get-Password
Returns a password of 10 characters long consisting of alpha-numerics only

.EXAMPLE
Get-Password -Length 14
As above but with 14 character length password

.EXAMPLE
Get-Password -UseComplex
Returns a default length password consisting of all visible ASCII characters (so no space or control key chars)

.EXAMPLE
Get-Password -Length 14 -UseComplex -AsSecureString
Returns a 14 character complex password as a secure string object

.NOTES
NONE

#>





    Param(
        [int]$Length=10,
        [switch]$UseComplex,
        [switch]$AsSecureString
    )
    
    # Character set index
    $exclamation = 33; $tilde = 126; 
    $0 = 48; $9 = 57
    $A = 65; $Z = 90
    $aLowCase = 97; $zLowCase =122
    
    if ($UseComplex) {
        # Use extended ASCII character set 
        for ($char = $exclamation; $char –le $tilde; $char++) {
            $ascii +=,[char][byte]$char
        }
    } else {
        # Use only alpha-numerics
        for ($char = $0; $char –le $9; $char++) { $ascii +=,[char][byte]$char }
        for ($char = $A; $char –le $Z; $char++) { $ascii +=,[char][byte]$char }
        for ($char = $aLowCase; $char –le $zLowCase; $char++) { $ascii +=,[char][byte]$char }
    }

    # Generate the password
    for ($loop=1; $loop –le $length; $loop++) {
                $password += ($ascii | Get-Random)
    }
    
    if ($AsSecureString) {
        $password = $password | ConvertTo-SecureString -AsPlainText -Force
    }

    return $password
}