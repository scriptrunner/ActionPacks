#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Sets the properties of the Active Directory group.
         Only parameters with value are set
    
    .DESCRIPTION
          
    .Parameter GroupName
        DistinguishedName or SamAccountName of the Active Directory group

    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP

    .Parameter Description
        Specifies a description of the group

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
    [string]$Description,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('','DomainLocal', 'Global', 'Universal')]
    [string]$Scope = '',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('','Distribution', 'Security')]
    [string]$Category = '',  
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

$Script:Grp

if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:Grp= Get-ADGroup -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
        -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)} 
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }  
    $Script:Grp= Get-ADGroup -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
        -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)}
}
if($null -ne $Script:Grp){
    if(-not [System.String]::IsNullOrWhiteSpace($Description)){
        $Script:Grp.Description = $Description
    }
    if(-not [System.String]::IsNullOrWhiteSpace($DisplayName)){
        $Script:Grp.DisplayName = $DisplayName
    }
    if(-not [System.String]::IsNullOrWhiteSpace($HomePage)){
        $Script:Grp.HomePage = $HomePage
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Scope)){
        $Script:Grp.GroupScope = $Scope
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Category)){
        $Script:Grp.GroupCategory = $Category
    }
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        Set-ADGroup -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Instance $Script:Grp 
    }
    else{
        Set-ADGroup -Server $Domain.PDCEmulator -AuthType $AuthType -Instance $Script:Grp
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group $($GroupName) changed"
    } 
    else{
        Write-Output "Group $($GroupName) changed"
    }
}
else {
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group $($GroupName) not found"
    }    
    Write-Error "Group $($GroupName) not found"
}