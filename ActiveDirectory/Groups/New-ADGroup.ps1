#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Creates a group in the OU path
    
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
        Specifies the name of the new group
    
    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP

    .Parameter SAMAccountName
        Specifies the Security Account Manager (SAM) account name of the group

    .Parameter Description
        Specifies a description of the group

    .Parameter DisplayName
        Specifies the display name of the group

    .Parameter Scope
        Specifies the group scope of the group

    .Parameter Category
        Specifies the category of the group

    .Parameter DomainName
        Name of Active Directory Domain
    
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
    [string]$SAMAccountName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Description,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DisplayName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('DomainLocal', 'Global', 'Universal')]
    [string]$Scope = 'Universal',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Distribution', 'Security')]
    [string]$Category = 'Security',  
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

#Clear
#$ErrorActionPreference='Stop'

try{
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        else{
            $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        if([System.String]::IsNullOrWhiteSpace($OUPath)){
            $OUPath = $Domain.DistinguishedName
        }
        $Script:Grp= New-ADGroup -Credential $DomainAccount -Server $Domain.PDCEmulator -GroupCategory $Category -GroupScope $Scope -Name $GroupName -Path $OUPath  `
                            -Description $Description -DisplayName $DisplayName -SamAccountName $SAMAccountName -Confirm:$false  -AuthType $AuthType  -PassThru    -ErrorAction Stop 
    }
    else{
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType  -ErrorAction Stop
        }
        else{
            $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType  -ErrorAction Stop
        }
        if([System.String]::IsNullOrWhiteSpace($OUPath)){
            $OUPath = $Domain.DistinguishedName
        }
        $Script:Grp= New-ADGroup -Server $Domain.PDCEmulator -GroupCategory $Category -GroupScope $Scope -Name $GroupName -Path $OUPath  `
                            -Description $Description -DisplayName $DisplayName -SamAccountName $SAMAccountName -Confirm:$false  -AuthType $AuthType  -PassThru -ErrorAction Stop
    }
    if($null -ne $Script:Grp){
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group $($Grp.DistinguishedName);$($Grp.SAMAccountName) created"
        } 
        else{
            Write-Output "Group $($Grp.DistinguishedName);$($Grp.SAMAccountName) created"
        }
    }   
}
catch{
    throw
}
finally{
}