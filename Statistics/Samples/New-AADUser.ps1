#Requires -Version 4.0
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
        Azure Active Directory Powershell Module v2
        Requires the library script StatisticLib.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/Samples

    .Parameter UserPrincipalName
        [sr-en] Specifies the user ID for this user
        [sr-de] UPN des neuen Benutzers

    .Parameter Password
        [sr-en] Specifies the new password for the user
        [sr-de] Initiales Passwort 

    .Parameter DisplayName
        [sr-en] Specifies the display name of the user
        [sr-de] Anzeigename

    .Parameter Enabled
        [sr-en] Specifies whether the user is able to log on using their user ID
        [sr-de] Aktiviere Log On 

    .Parameter FirstName
        [sr-en] Specifies the first name of the user
        [sr-de] Vorname

    .Parameter LastName
        [sr-en] Specifies the last name of the user
        [sr-de] Nachname

    .Parameter PostalCode
        [sr-en] Specifies the postal code of the user
        [sr-de] Postleitzahl

    .Parameter City
        [sr-en] Specifies the city of the user
        [sr-de] Ort

    .Parameter Street
        [sr-en] Specifies the street address of the user
        [sr-de] Strasse

    .Parameter PhoneNumber
        [sr-en] Specifies the phone number of the user
        [sr-de] Telefonnummer

    .Parameter MobilePhone
        [sr-en] Specifies the mobile phone number of the user
        [sr-de] Telefonnummer mobil

    .Parameter Department
        [sr-en] Specifies the department of the user
        [sr-de] Abteilung

    .Parameter ForceChangePasswordNextLogin
        [sr-en] Forces a user to change their password during their next logon
        [sr-de] Benutzer muss das Passwort beim nächsten LogIn ändern

    .Parameter ShowInAddressList 
        [sr-en] Specifies show this user in the address list
        [sr-de] Benutzer in der Adresslisten anzeigen

    .Parameter UserType 
        [sr-en] Type of the user
        [sr-de] Benutzertyp

    .Parameter CostReduction
        [sr-en] Cost saving through execution per ScriptRunner, in seconds
        [sr-de] Zeitersparnis, in Sekunden
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
    [int]$CostReduction = 600,
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

        LogExecution -CostSavingsSeconds $CostReduction
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
