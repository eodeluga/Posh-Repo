
function CreateAccount {
[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,
        $DefaultPassword,
        $Description,
        [Parameter(mandatory=$true)]
        $NumberOfAccounts,
        $GroupMembership,
        $OrganizationalUnit,
        
        # Below defaults used if params not specified
        #
        # Account expiration days from today
        $DaysTillExpiration = 10,
        # The DC for the script to work with
        $DomainController = $env:LOGONSERVER.Replace("\\",""),
        # The index to start at for numbering account name
        $AccountIndex = 1
    )
      
    DynamicParam {

        # Remove 'PasswordLength' parameter if 'DefaultPassword' is specified
        if ($DefaultPassword -eq $null) {
            
            # Set the dynamic parameters' name
            $ParameterName = 'PasswordLength'
            # Create the dictionary
            $RuntimeParameterDictionary =
                New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Create the collection of attributes
            $AttributeCollection =
                New-Object System.Collections.ObjectModel.Collection[System.Attribute]

            # Create and set the parameters' attributes
            $ParameterAttribute =
                New-Object System.Management.Automation.ParameterAttribute

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)
            
            # Create and return the dynamic parameter
            $RuntimeDefinedParameter =
                New-Object System.Management.Automation.RuntimeDefinedParameter(
                    $ParameterName,[String], $AttributeCollection)          
            
            $RuntimeParameterDictionary.
                Add($ParameterName, $RuntimeDefinedParameter)

            return $RuntimeParameterDictionary
        }
    }

    Begin {
 
        # Bind dynamic parameter value for use in script
        if ($PSBoundParameters.ContainsKey("PasswordLength")) {
            $PasswordLength = $PSBoundParameters.Item("PasswordLength")
        } else {
            # Default password length if none specified
            $PasswordLength = 10
        }

        # Set OU to root if none specified
        if (($OrganizationalUnit -eq $null) -or ($OrganizationalUnit -eq "")) {
            $OrganizationalUnit = $env:USERDNSDOMAIN.
                Split(".")

            # Construct LDAP string
            foreach ($element in $OrganizationalUnit) {
                $OU += $("DC=$element,")
            }
            # Remove trailing ,
            $OrganizationalUnit = $OU.Remove(($OU.Length - 1),1)
        }
    }
    
    Process {

        # Main loop for creating accounts
        for ($i = 0; $i -lt $NumberOfAccounts; $i++) {
          
            # Construct user name combined with index
            $user = "$($Name)$($AccountIndex.ToString("0#"))"
            $AccountIndex++
    
            # Collate account credentials for returning later
            if (($DefaultPassword -ne $null) -or ($DefaultPassword -ne "")) {
                
                # Create credentials with default password
                $account += New-Object -TypeName psobject -Property @{  
                    User = $user
                    Password = $DefaultPassword | ConvertTo-SecureString
                }
            } else {
                
                # Create credentials with generated password
                $account += New-Object -TypeName psobject -Property @{  
                    User = $user
                    Password = Get-Password -Length $PasswordLength -AsSecureString
                }
            }
    
            # Account creation parameters
            $pass = $account[$i].Password
            $params = @{
                SamAccountName = $user
                UserPrincipalName = "$user@$($env:USERDNSDOMAIN)"
                Name = $user
                AccountPassword = $pass
                Path = $OrganizationalUnit
                AccountExpirationDate = (Get-Date).Add($DaysTillExpiration)
                CannotChangePassword = $true
                PasswordNeverExpires = $false
                Description = $Description
                HomeDirectory = ""
                HomeDrive = "H:"
                Enabled = $true
                Confirm = $false
            }

            # Create account
            New-ADUser @params -Server $DomainController
    
            # Add account to required membership
            if (($GroupMembership -ne $null) -or ($GroupMembership -ne "")) {
                $user = Get-ADUser -Identity "$("CN=")$($params.SamAccountName)$(",")$OrganizationalUnit" -Server $DomainController
                Add-ADGroupMember -Identity $GroupMembership -Members $user -Server $DomainController
            }
        }

        ($account | ConvertTo-Html -PreContent "<p><h2>$Description List</h2></p><br>")
    }
}


