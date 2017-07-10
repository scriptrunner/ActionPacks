#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Creates a group in the OU path
    
    .DESCRIPTION         
    
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

    .Parameter OUPath
        Specifies the AD path

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
    [string]$OUPath,
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
$ErrorActionPreference='Stop'

if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    if([System.String]::IsNullOrWhiteSpace($OUPath)){
        $OUPath = $Domain.DistinguishedName
    }
    $Script:Grp= New-ADGroup -Credential $DomainAccount -Server $Domain.PDCEmulator -GroupCategory $Category -GroupScope $Scope -Name $GroupName -Path $OUPath  `
                        -Description $Description -DisplayName $DisplayName -SamAccountName $SAMAccountName -Confirm:$false  -AuthType $AuthType  -PassThru    
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
    if([System.String]::IsNullOrWhiteSpace($OUPath)){
        $OUPath = $Domain.DistinguishedName
    }
    $Script:Grp= New-ADGroup -Server $Domain.PDCEmulator -GroupCategory $Category -GroupScope $Scope -Name $GroupName -Path $OUPath  `
                        -Description $Description -DisplayName $DisplayName -SamAccountName $SAMAccountName -Confirm:$false  -AuthType $AuthType  -PassThru
}
if($null -ne $Script:Grp){
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group $($Grp.DistinguishedName);$($Grp.SAMAccountName) created"
    } 
    else{
        Write-Output "Group $($Grp.DistinguishedName);$($Grp.SAMAccountName) created"
    }
}