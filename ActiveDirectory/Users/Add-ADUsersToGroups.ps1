#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Adds users to Active Directory groups
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module ActiveDirectory

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Users

    .Parameter UserNames
        Comma separated display name, SAMAccountName, DistinguishedName or user principal name of the users added to the groups

    .Parameter GroupNames
        Comma separated names of the groups to which the users added
       
    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter OUPath
        Set the OU Path or use a Query

    .Parameter DomainName
        Name of Active Directory Domain
    
    .Parameter SearchScope
        Specifies the scope of an Active Directory search

    .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string[]]$UserNames,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string[]]$GroupNames,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate" 
)

Import-Module ActiveDirectory

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AuthType' = $AuthType
                            }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $cmdArgs.Add("Current", 'LocalComputer')
    }
    else {
        $cmdArgs.Add("Identity", $DomainName)
    }
    $Domain = Get-ADDomain @cmdArgs
    
    $res = @()
    $UserSAMAccountNames = @()
    if($UserNames){    
        $cmdArgs = @{'ErrorAction' = 'Stop'
                    'Server' = $Domain.PDCEmulator
                    'AuthType' = $AuthType
                    'SearchBase' = $OUPath 
                    'SearchScope' = $SearchScope
                    'Filter' = ''                
                    }
        if($null -ne $DomainAccount){
            $cmdArgs.Add("Credential", $DomainAccount)
        }
        foreach($name in $UserNames){
            $cmdArgs.Item("Filter") = {(SamAccountName -eq $name) -or (DisplayName -eq $name) -or (DistinguishedName -eq $name) -or (UserPrincipalName -eq $name)}
            $usr= Get-ADUser @cmdArgs | Select-Object SAMAccountName
            if($null -ne $usr){
                $UserSAMAccountNames += $usr.SAMAccountName
            }
            else {
                $res = $res + "User $($name) not found"
            }
        }
    }
    foreach($usr in $UserSAMAccountNames){
        $founded = @()
        [hashtable]$groupArgs = @{'ErrorAction' = 'Stop'
                                'AuthType' = $AuthType
                                'Server' = $Domain.PDCEmulator
                                'SearchBase' = $OUPath 
                                'SearchScope' = $SearchScope
                                'Filter' = ''
                                }
        $cmdArgs = @{'ErrorAction' = 'Stop'
                    'Server' = $Domain.PDCEmulator
                    'AuthType' = $AuthType
                    }
        if($null -ne $DomainAccount){
            $cmdArgs.Add("Credential", $DomainAccount)
            $groupArgs.Add("Credential", $DomainAccount)
        }
        foreach($itm in $GroupNames){
            $groupArgs.Item("Filter") = {(SamAccountName -eq $itm) -or (DistinguishedName -eq $itm)}
            $grp= Get-ADGroup @groupArgs
            
            if($null -ne $grp){
                $founded += $itm
                try {
                    Add-ADGroupMember @cmdArgs -Identity $grp -Members $usr 
                    $res = $res + "User $($usr) added to Group $($itm)"
                }
                catch {
                    $res = $res + "Error: Add user $($usr) to Group $($itm) $($_.Exception.Message)"
                }
            }
            else {
                $res = $res + "Group $($itm) not found"
            }        
        }
        $GroupNames=$founded
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $res
    }
    else{
        Write-Output $res
    }   
}
catch{
    throw
}
finally{
}