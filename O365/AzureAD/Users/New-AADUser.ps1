#Requires -Version 5.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and creates a user 
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Azure Active Directory Powershell Module

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Users

    .Parameter UserPrincipalName
        [sr-en] User ID for this user
        [sr-de] UPN des neuen Benutzers

    .Parameter Password
        [sr-en] New password for the user
        [sr-de] Initiales Passwort 

    .Parameter DisplayName
        [sr-en] Display name of the user
        [sr-de] Anzeigename

    .Parameter Enabled
        [sr-en] User is able to log on using their user ID
        [sr-de] Aktiviere Log On 

    .Parameter FirstName
        [sr-en] First name of the user
        [sr-de] Vorname

    .Parameter LastName
        [sr-en] Last name of the user
        [sr-de] Nachname

    .Parameter PostalCode
        [sr-en] Postal code of the user
        [sr-de] Postleitzahl

    .Parameter City
        [sr-en] City of the user
        [sr-de] Ort

    .Parameter Street
        [sr-en] Street address of the user
        [sr-de] Strasse

    .Parameter PhoneNumber
        [sr-en] Phone number of the user
        [sr-de] Telefonnummer

    .Parameter MobilePhone
        [sr-en] Mobile phone number of the user
        [sr-de] Telefonnummer mobil

    .Parameter Department
        [sr-en] Department of the user
        [sr-de] Abteilung

    .Parameter ForceChangePasswordNextLogin
        [sr-en] Forces a user to change their password during their next logon
        [sr-de] Benutzer muss das Passwort beim nächsten LogIn ändern

    .Parameter ShowInAddressList 
        [sr-en] Show this user in the address list
        [sr-de] Benutzer in der Adresslisten anzeigen

    .Parameter UserType 
        [sr-en] Type of the user
        [sr-de] Benutzertyp
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,
    [Parameter(Mandatory = $true)]
    [string]$Password,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [Parameter(Mandatory = $true)]
    [bool]$Enabled,
    [string]$FirstName,
    [string]$LastName,
    [string]$PostalCode,
    [string]$City,
    [string]$Street,
    [string]$PhoneNumber,
    [string]$MobilePhone,
    [string]$Department,
    [bool]$ForceChangePasswordNextLogin,
    [bool]$ShowInAddressList,
    [ValidateSet('Member','Guest')]
    [string]$UserType = 'Member'
)

try{
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $Password
    $PasswordProfile.ForceChangePasswordNextLogin = $ForceChangePasswordNextLogin
    $nick = $UserPrincipalName.Substring(0, $UserPrincipalName.IndexOf('@'))
    $Script:User = New-AzureADUser -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName -AccountEnabled $Enabled -MailNickName $nick -UserType $UserType `
                    -PasswordProfile $PasswordProfile -ShowInAddressList $ShowInAddressList | Select-Object *
    if($null -ne $Script:User){
        if($PSBoundParameters.ContainsKey('FirstName') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -GivenName $FirstName
        }
        if($PSBoundParameters.ContainsKey('LastName') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -Surname $LastName
        }
        if($PSBoundParameters.ContainsKey('PostalCode') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -PostalCode $PostalCode
        }
        if($PSBoundParameters.ContainsKey('City') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -City $City
        }
        if($PSBoundParameters.ContainsKey('Street') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -StreetAddress $Street
        }
        if($PSBoundParameters.ContainsKey('PhoneNumber') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -TelephoneNumber $PhoneNumber
        }
        if($PSBoundParameters.ContainsKey('MobilePhone') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -Mobile $MobilePhone
        }
        if($PSBoundParameters.ContainsKey('Department') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -Department $Department
        }
        $Script:User = Get-AzureADUser | Where-Object {$_.UserPrincipalName -eq $UserPrincipalName} | Select-Object *
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:User
        } 
        else{
            Write-Output $Script:User 
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User not created"
        }    
        Throw "User not created"
    }
}
finally{

}
