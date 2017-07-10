#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Enable, disable and/or unlock a Active Directory account
    
    .DESCRIPTION
          
    .Parameter Username
        Display name, SAMAccountName, DistinguishedName or user principal name of Active Directory account

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter Enable
        Enables the Active Directory account
    
    .Parameter Disable
        Disables the Active Directory account
        
    .Parameter UnLock
        Unlock the Active Directory account

    .Parameter DomainName
        Name of Active Directory Domain
    
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
    [switch]$Enable,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$Disable,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$UnLock,
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

$Script:Domain 
$Script:User 
if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -Properties LockedOut,Enabled `
        -Filter {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)}
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
    $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Properties LockedOut,Enabled `
        -Filter {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)}
}
if($null -ne $Script:User){
    $res=@()
    if($UnLock -eq $true){
        if($Script:User.LockedOut -eq $true){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                Unlock-ADAccount -Identity $Script:User -Credential $DomainAccount -AuthType $AuthType -Server $Script:Domain.PDCEmulator
            }
            else {
                Unlock-ADAccount -Identity $Script:User -AuthType $AuthType -Server $Script:Domain.PDCEmulator
            }
            $res = $res + "User $($Username) unlocked"
        }
        else{
            $res = $res +  "User $($Username) is not locked"
        }
    }
    if($Enable -eq $true){
        if($Script:User.Enabled -eq $false){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                Enable-ADAccount -Identity $Script:UserUser -Credential $DomainAccount -AuthType $AuthType -Server $Script:Domain.PDCEmulator
            }
            else {
                Enable-ADAccount -Identity $Script:User -AuthType $AuthType -Server $Script:Domain.PDCEmulator
            }
            $res = $res +  "User $($Username) enabled"
        }
        else{
            $res = $res +  "User $($Username) is not disabled"
        }
    }
    if($Disable -eq $true){
        if($Script:User.Enabled -eq $true){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                Disable-ADAccount -Identity $Script:User -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType
            }
            else {
                Disable-ADAccount -Identity $Script:User -Server $Script:Domain.PDCEmulator -AuthType $AuthType
            }
            $res = $res +  "User $($Username) disabled"
        }
        else{
            $res = $res +  "User $($Username) is not enabled"
        }
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $res
    }  
    else {
        Write-Output $res
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "User $($Username) not found"
    }    
    Write-Error "User $($Username) not found"
}