#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Removes Active Directory service account
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter AccountName
        SAMAccountName or DistinguishedName name of Active Directory service account

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$AccountName,
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

$Script:Srv 
$Script:Domain

[string]$Script:sam=$AccountName
if(-not $Script:sam.EndsWith('$')){
  #  $Script:sam += '$'
}
if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:Srv= Get-ADServiceAccount -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType `
            -Filter {(SamAccountName -eq $sam) -or (DistinguishedName -eq $AccountName)} 
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
    $Script:Srv= Get-ADServiceAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
            -Filter {(SamAccountName -eq $sam) -or (DistinguishedName -eq $AccountName)} 
}
if($null -ne $Script:Srv){
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        Remove-ADServiceAccount -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Srv -Confirm:$false
    }
    else {
        Remove-ADServiceAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Srv -Confirm:$false
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Service account $($AccountName) deleted"
    } 
    else {
        Write-Output "Service account $($AccountName) deleted"
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Service account $($AccountName) not found"
    }    
    Write-Error "Service account $($AccountName) not found"
}