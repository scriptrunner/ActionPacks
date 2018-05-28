#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Removes users from Active Directory group
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT
        Requires Module ActiveDirectory

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Users

    .Parameter OUPath
        Specifies the AD path

    .Parameter GroupName
        Name of the group from which the users are removed

    .Parameter UserNames
        Comma separated display name, SAMAccountName, DistinguishedName or user principal name of the users removed from the group
       
    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

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
    [string]$GroupName,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string[]]$UserNames,
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

#Clear
#$ErrorActionPreference='Stop'
try{
    $Script:Domain
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
    }
    else{
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType  -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType  -ErrorAction Stop
        }
    }
    $res = @()
    if($UserNames){    
        $UserSAMAccountNames = @()
        foreach($name in $UserNames){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                $usr= Get-ADUser -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
                        -SearchBase $OUPath -SearchScope $SearchScope `
                        -Filter {(SamAccountName -eq $name) -or (DisplayName -eq $name) -or (DistinguishedName -eq $name) -or (UserPrincipalName -eq $name)} | Select-Object SAMAccountName
            }
            else {
                $usr= Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
                        -SearchBase $OUPath -SearchScope $SearchScope `
                        -Filter {(SamAccountName -eq $name) -or (DisplayName -eq $name) -or (DistinguishedName -eq $name) -or (UserPrincipalName -eq $name)} | Select-Object SAMAccountName
            }
            if($null -ne $usr){
                $UserSAMAccountNames += $usr.SAMAccountName
            }
            else {
                $res = $res + "User $($name) not found"
            }
        }
    }
    foreach($usr in $UserSAMAccountNames){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                $grp= Get-ADGroup -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
                        -SearchBase $OUPath -SearchScope $SearchScope `
                        -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)}
            }
            else {
                $grp= Get-ADGroup -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
                        -SearchBase $OUPath -SearchScope $SearchScope `
                        -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)}
            }
            if($null -ne $grp){
                try {
                    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                        Remove-ADGroupMember -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $grp -Members $usr -Confirm:$false
                    } 
                    else {
                        Remove-ADGroupMember -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $grp -Members $usr -Confirm:$false
                    }
                    $res = $res + "User $($usr) removed from Group $($GroupName)"
                }
                catch {
                    $res = $res + "Error: Remove user $($usr) from Group $($GroupName) $($_.Exception.Message)"
                }
            }
            else {
                $res = $res + "Group $($GroupName) not found"
            }      
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