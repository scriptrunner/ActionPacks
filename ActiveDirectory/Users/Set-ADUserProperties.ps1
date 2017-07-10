#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Sets the properties of the Active Directory user.
        Only parameters with value are set
    
    .DESCRIPTION
          
    .Parameter Username
        Display name, SAMAccountName, DistinguishedName or user principal name of Active Directory account

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter GivenName
        Specifies the user's given name

    .Parameter Surname
        Specifies the user's last name or surname

    .Parameter DisplayName
        Specifies the display name of the user

    .Parameter Description
        Specifies a description of the user

    .Parameter ChangePasswordAtLogon
        Specifies whether a password must be changed during the next logon attempt

    .Parameter CannotChangePassword
        Specifies whether the account password can be changed

    .Parameter PasswordNeverExpires
        Specifies whether the password of an account can expire

    .Parameter Office
        Specifies the location of the user's office or place of business
    
    .Parameter EmailAddress
        Specifies the user's e-mail address

    .Parameter Phone
        Specifies the user's office telephone number

    .Parameter Title
        Specifies the user's title

    .Parameter Department
        Specifies the user's department

    .Parameter Company
        Specifies the user's company

    .Parameter Street
        Specifies the user's street address

    .Parameter PostalCode
        Specifies the user's postal code or zip code

    .Parameter City
        Specifies the user's town or city

    .Parameter NewSAMAccountName
        The new SAMAccountName of Active Directory account

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
    [string]$GivenName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Surname,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DisplayName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Description,
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
    [string]$Office,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$EmailAddress,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Phone,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Title,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Department,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Company,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Street,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$PostalCode,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$City,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$NewSAMAccountName,
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
    if(-not [System.String]::IsNullOrWhiteSpace($GivenName)){
        $Script:User.GivenName = $GivenName
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Surname)){
        $Script:User.Surname = $Surname
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Description)){
        $Script:User.Description = $Description
    }
    if(-not [System.String]::IsNullOrWhiteSpace($DisplayName)){
        $Script:User.DisplayName = $DisplayName
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Office)){
        $Script:User.Office = $Office
    }
    if(-not [System.String]::IsNullOrWhiteSpace($EmailAddress)){
        $Script:User.EmailAddress = $EmailAddress
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Phone)){
        $Script:User.OfficePhone = $Phone
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Title)){
        $Script:User.Title = $Title
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Department)){
        $Script:User.Department = $Department
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Company)){
        $Script:User.Company = $Company
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Street)){
        $Script:User.StreetAddress = $Street
    }
    if(-not [System.String]::IsNullOrWhiteSpace($PostalCode)){
        $Script:User.PostalCode = $PostalCode
    }
    if(-not [System.String]::IsNullOrWhiteSpace($City)){
        $Script:User.City = $City
    }
    if($PSBoundParameters.ContainsKey('CannotChangePassword') -eq $true ){
        $Script:User.CannotChangePassword = $CannotChangePassword.ToBool()
    }
    if($PSBoundParameters.ContainsKey('PasswordNeverExpires') -eq $true){
        $Script:User.PasswordNeverExpires = $PasswordNeverExpires.ToBool()
    }
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        $Script:User = Set-ADUser -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Instance $Script:User -PassThru
    }
    else {
        $Script:User = Set-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Instance $Script:User -PassThru
    }
    if($PSBoundParameters.ContainsKey('ChangePasswordAtLogon') -eq $true ){ # is not a property from the user object
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            $Script:User = Set-ADUser -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $User.SAMAccountName -ChangePasswordAtLogon:$ChangePasswordAtLogon.ToBool() -PassThru
        }
        else {
            $Script:User = Set-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $User.SAMAccountName -ChangePasswordAtLogon:$ChangePasswordAtLogon.ToBool() -PassThru
        }
    }
    if(-not [System.String]::IsNullOrWhiteSpace($NewSAMAccountName)){ # user must changed with replace parameter
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            $Script:User = Set-ADUser -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $User.SamAccountName -Replace @{'SAMAccountName'=$NewSAMAccountName} -PassThru
        }
        else {
            $Script:User = Set-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $User.SamAccountName -Replace @{'SAMAccountName'=$NewSAMAccountName} -PassThru
        }
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage ="User $($Username) changed"
    }
    else {
        Write-Output "User $($Username) changed"
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "User $($Username) not found"
    }    
    Write-Error "User $($Username) not found"
}