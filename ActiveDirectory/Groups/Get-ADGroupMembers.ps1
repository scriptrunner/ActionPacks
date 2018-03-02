#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Gets the members of the Active Directory group
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Groups

    .Parameter OUPath
        Specifies the AD path

    .Parameter GroupName
        DistinguishedName or SamAccountName of the Active Directory group

    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP

    .Parameter Nested
        Shows group members nested 
        
    .Parameter ShowOnlyGroups
        Shows only Active Directory groups

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
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$Nested,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$ShowOnlyGroups,
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
    $Script:Grp
    $Script:resultMessage = @()
    function Get-NestedGroupMember($group) { 
        $Script:resultMessage += "Group: $($group.DistinguishedName);$($group.SamAccountName)"
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                $members =Get-ADGroupMember -Identity $group -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType | `
                Sort-Object -Property  @{Expression="objectClass";Descending=$true} , @{Expression="SamAccountName";Descending=$false}
            }
            else {
                $members =Get-ADGroupMember -Identity $group -Server $Script:Domain.PDCEmulator -AuthType $AuthType | `
                Sort-Object -Property  @{Expression="objectClass";Descending=$true} , @{Expression="SamAccountName";Descending=$false}
            }
            if($null -ne $members){
                foreach($itm in $members){
                    if($itm.objectClass -eq "group"){
                        if($Nested -eq $true){
                            Get-NestedGroupMember($itm)
                        }
                        else{
                            $Script:resultMessage += "Group: $($itm.DistinguishedName);$($itm.SamAccountName)"
                        }
                    }
                    else{
                        if($ShowOnlyGroups -eq $false){
                            $Script:resultMessage += "User: $($itm.DistinguishedName);$($itm.SamAccountName)"
                        }
                    }
                }
            }
    }
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        $Script:Grp= Get-ADGroup -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
            -SearchBase $OUPath -SearchScope $SearchScope `
            -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)}  -ErrorAction Stop
    }
    else{
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType  -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType  -ErrorAction Stop
        }  
        $Script:Grp= Get-ADGroup -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
            -SearchBase $OUPath -SearchScope $SearchScope `
            -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)} -ErrorAction Stop
    }
    if($null -ne $Script:Grp){    
        Get-NestedGroupMember $Script:Grp
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:resultMessage
        }
        else{
            Write-Output $Script:resultMessage
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group $($GroupName) not found"
        }    
        Throw "Group $($GroupName) not found"
    }   
}
catch{
    throw
}
finally{
}