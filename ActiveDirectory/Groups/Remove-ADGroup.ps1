#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Removes the Active Directory group
    
    .DESCRIPTION
          
    .Parameter GroupName
        DistinguishedName or SamAccountName of the Active Directory group
    
    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP
    
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
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:Grp= Get-ADGroup -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
        -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)}     
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
    $Script:Grp= Get-ADGroup -Server $Domain.PDCEmulator -AuthType $AuthType  `
        -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)}     
}
if($null -ne $Script:Grp){
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        Remove-ADGroup -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Grp -Confirm:$false
    }
    else{
        Remove-ADGroup -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Grp -Confirm:$false
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage="Group $($GroupName) deleted"
    }
    else
    {
        Write-Output "Group $($GroupName) deleted"
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group $($GroupName) not found"
    }    
    Write-Error "Group $($GroupName) not found"
}