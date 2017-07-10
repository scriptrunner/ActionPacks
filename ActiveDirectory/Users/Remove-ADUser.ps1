#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Removes Active Directory account
    
    .DESCRIPTION
          
    .Parameter Username
        Display name, SAMAccountName, DistinguishedName or user principal name of Active Directory user

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Username,
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

$Script:User 
$Script:Domain

if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
        -Filter {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)} 
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
    $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
        -Filter {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)}
}
if($null -ne $Script:User){
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        Remove-ADUser -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User -Confirm:$false
    }
    else {
        Remove-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User -Confirm:$false
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "User $($Username) deleted"
    } 
    else {
        Write-Output "User $($Username) deleted"
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "User $($Username) not found"
    }    
    Write-Error "User $($Username) not found"
}