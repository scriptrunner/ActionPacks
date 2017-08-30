#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Copy a Active Directory account
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter SourceUsername
        Display name, SAMAccountName, DistinguishedName or user principal name of Active Directory user

    .Parameter NewUserName
        Specifies the name of the new user

    .Parameter Password
        Specifies the password value for the new account
    
    .Parameter DisplayName
        Specifies the new user's display name

    .Parameter SamAccountName
        Specifies the Security Account Manager (SAM) account name of the new user

    .Parameter UserPrincipalName
        Specifies the user principal name (UPN) in the format <user>@<DNS-domain-name>. 
    
    .Parameter GivenName
        Specifies the new user's given name

    .Parameter Surname
        Specifies the new user's last name or surname

    .Parameter CopyGroupMemberships
        Copies the group memberships too

    .Parameter ChangePasswordAtLogon
        Specifies whether a password must be changed during the next logon attempt

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP
    
    .Parameter DomainName
        Name of Active Directory Domain

    .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$SourceUsername,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$NewUserName,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Password,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$DisplayName,    
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$SAMAccountName,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$UserPrincipalName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$GivenName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Surname,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$CopyGroupMemberships,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$ChangePasswordAtLogon,
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
#$ErrorActionPreference='Stop'
$Script:Properties =@('AccountExpirationDate','accountExpires','AccountLockoutTime','AccountNotDelegated','AllowReversiblePasswordEncryption','CannotChangePassword','City','co','Company','Country','countryCode','Department','Description','Division', `
                    'DoesNotRequirePreAuth','EmailAddress','Enabled','facsimileTelephoneNumber','Fax','HomeDirectory','HomedirRequired','HomeDrive','HomePage','HomePhone','Initials','ipPhone','mail','Manager','MNSLogonAccount','mobile','MobilePhone', `
                    'Office','OfficePhone','Organization','OtherName','pager','PasswordExpired','PasswordNeverExpires','PasswordNotRequired','physicalDeliveryOfficeName','POBox','PostalCode','postOfficeBox','ProtectedFromAccidentalDeletion', `
                    'ScriptPath','SmartcardLogonRequired','sn','st','State','StreetAddress','telephoneNumber','Title','TrustedForDelegation','TrustedToAuthForDelegation','UseDESKeyOnly','wWWHomePage')
$Script:User 
$Script:Domain
$Script:Pwd=ConvertTo-SecureString $Password -AsPlainText -force
if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount 
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount 
    }
    $Source= Get-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
        -Filter {(SamAccountName -eq $SourceUserName) -or (DisplayName -eq $SourceUserName) -or (DistinguishedName -eq $SourceUserName) -or (UserPrincipalName -eq $SourceUserName)} `
        -Properties $Script:Properties
    New-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
        -Instance $Source -Name $NewUserName -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName `
        -Path ($Source.DistinguishedName -split ",",2)[1] -SamAccountName $SAMAccountName -AccountPassword $Script:Pwd 
    $Script:User=Get-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -Identity $SAMAccountName
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
    $Source= Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
        -Filter {(SamAccountName -eq $SourceUserName) -or (DisplayName -eq $SourceUserName) -or (DistinguishedName -eq $SourceUserName) -or (UserPrincipalName -eq $SourceUserName)} `
        -Properties $Script:Properties
    New-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
        -Instance $Source -Name $NewUserName -DisplayName $DisplayName -SamAccountName $SAMAccountName `
        -Path ($Source.DistinguishedName -split ",",2)[1] -UserPrincipalName $UserPrincipalName -AccountPassword $Script:Pwd
    $Script:User=Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $SAMAccountName
}
if($null -ne $Script:User){
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        if((-not [System.String]::IsNullOrWhiteSpace($GivenName)) -or(-not [System.String]::IsNullOrWhiteSpace($Surname))){
            Set-ADUser -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User -GivenName $GivenName -Surname $Surname
        }
        if($ChangePasswordAtLogon -eq $true){
            Set-ADUser -PasswordNeverExpires $false -ChangePasswordAtLogon $true -CannotChangePassword $false -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User
        }
        if($CopyGroupMemberships){
            $exists = Get-ADPrincipalGroupMembership -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $NewUsername
            $Groups = Get-ADPrincipalGroupMembership -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $SourceUsername `
                      |  Where-Object SID -ne $exists.SID # remove domain users
            Add-ADPrincipalGroupMembership -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $NewUserName -memberOf $Groups
        }
    }
    else {
        if((-not [System.String]::IsNullOrWhiteSpace($GivenName)) -or(-not [System.String]::IsNullOrWhiteSpace($Surname))){
            Set-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User -GivenName $GivenName -Surname $Surname
        }
        if($ChangePasswordAtLogon -eq $true){
            Set-ADUser -PasswordNeverExpires $false -ChangePasswordAtLogon $true -CannotChangePassword $false -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User
        }
        if($CopyGroupMemberships){
            $exists = Get-ADPrincipalGroupMembership -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $NewUsername
            $Groups = Get-ADPrincipalGroupMembership -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $SourceUsername `
                      |  Where-Object SID -ne $exists.SID # remove domain users
            Add-ADPrincipalGroupMembership -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $NewUserName -memberOf $Groups
        }
    }
    $res=@()
    $res += $Script:User | Format-List
    $res += "User $($NewUserName) created" 
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $res
    } 
    else {
        Write-Output $res
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "User $($SourceUserName) not copied"
    }    
    Throw "User $($SourceUserName) not copied"
}