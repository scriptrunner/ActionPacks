#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Creates a user in the OU path
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter UserName
        Specifies the name of the new user

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter SAMAccountName
        Specifies the Security Account Manager (SAM) account name of the user

    .Parameter Description
        Specifies a description of the user

    .Parameter DisplayName
        Specifies the display name of the user

    .Parameter Password
        Specifies a new password value for an account

    .Parameter OUPath
        Specifies the AD path

    .Parameter ChangePasswordAtLogon
        Specifies whether a password must be changed during the next logon attempt

    .Parameter CannotChangePassword
        Specifies whether the account password can be changed

    .Parameter PasswordNeverExpires
        Specifies whether the password of an account can expire

    .Parameter City
        Specifies the user's town or city

    .Parameter PostalCode
        Specifies the user's postal code or zip code

    .Parameter Street
        Specifies the user's street address

    .Parameter Company
        Specifies the user's company

    .Parameter Department
        Specifies the user's department

    .Parameter EMailAddress
        Specifies the user's e-mail address

    .Parameter GivenName
        Specifies the user's given name

    .Parameter Surname
        Specifies the user's last name or surname

    .Parameter DomainName
        Name of Active Directory Domain
    
    .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Username,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Password,
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
    [switch]$ChangePasswordAtLogon,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$CannotChangePassword,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$PasswordNeverExpires,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$EmailAddress,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$GivenName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Surname,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Department,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Company,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$PostalCode,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$City,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Street,
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

$Script:Pwd = ConvertTo-SecureString $Password -AsPlainText -Force
$Script:User 
$Script:Domain
if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
}
if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    $Script:User = New-ADUser -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -Name $UserName -Path $OUPath -Confirm:$false -AuthType $AuthType `
                           -Description $Description -DisplayName $DisplayName -SamAccountName $SAMAccountName -GivenName $GivenName -Surname $Surname `
                           -AccountPassword $Pwd -EmailAddress $EmailAddress -Department $Department -Company $Company -City $City -PostalCode $PostalCode `
                            -ChangePasswordAtLogon $ChangePasswordAtLogon.ToBool() -PasswordNeverExpires $PasswordNeverExpires.ToBool() -CannotChangePassword $CannotChangePassword.ToBool() `
                            -UserPrincipalName ($SAMAccountName + '@' + $Domain.DNSRoot) -StreetAddress $Street -Enable $true -PassThru
}
else {
    $Script:User = New-ADUser -Server $Script:Domain.PDCEmulator -Name $UserName -Path $OUPath -Confirm:$false -AuthType $AuthType `
                        -Description $Description -DisplayName $DisplayName -SamAccountName $SAMAccountName -GivenName $GivenName -Surname $Surname `
                        -AccountPassword $Pwd -EmailAddress $EmailAddress -Department $Department -Company $Company -City $City -PostalCode $PostalCode `
                        -ChangePasswordAtLogon $ChangePasswordAtLogon.ToBool() -PasswordNeverExpires $PasswordNeverExpires.ToBool() -CannotChangePassword $CannotChangePassword.ToBool() `
                        -UserPrincipalName ($SAMAccountName + '@' + $Domain.DNSRoot) -StreetAddress $Street -Enable $true  -PassThru
}
if($Script:User){
    if($SRXEnv) {
        $SRXEnv.ResultMessage = Write-Output "User $($UserName) created"
    }
    else {
        Write-Output "User $($UserName) created"
    }    
}   