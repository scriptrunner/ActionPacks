#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and creates a user 
        Requirements 
        ScriptRunner Version 4.x or higher
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Directory Powershell Module v2
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter UserPrincipalName
        Specifies the user ID for this user

    .Parameter Password
        Specifies the new password for the user

    .Parameter DisplayName
        Specifies the display name of the user

    .Parameter Enabled
        Specifies whether the user is able to log on using their user ID

    .Parameter FirstName
        Specifies the first name of the user

    .Parameter LastName
        Specifies the last name of the user

    .Parameter PostalCode
        Specifies the postal code of the user

    .Parameter City
        Specifies the city of the user

    .Parameter Street
        Specifies the street address of the user

    .Parameter PhoneNumber
        Specifies the phone number of the user

    .Parameter MobilePhone
        Specifies the mobile phone number of the user

    .Parameter Department
        Specifies the department of the user

    .Parameter ForceChangePasswordNextLogin
        Forces a user to change their password during their next log iny

    .Parameter ShowInAddressList 
        Specifies show this user in the address list
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
    [string]$UserType='Member'
)

try{
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password =$Password
    $PasswordProfile.ForceChangePasswordNextLogin =$ForceChangePasswordNextLogin
    $nick = $UserPrincipalName.Substring(0, $UserPrincipalName.IndexOf('@'))
    $Script:User = New-AzureADUser -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName -AccountEnabled $Enabled -MailNickName $nick -UserType $UserType `
                    -PasswordProfile $PasswordProfile -ShowInAddressList $ShowInAddressList | Select-Object *
    if($null -ne $Script:User){
        if($PSBoundParameters.ContainsKey('FirstName') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -GivenName $FirstName
        }
        if($PSBoundParameters.ContainsKey('LastName') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -Surname $LastName
        }
        if($PSBoundParameters.ContainsKey('PostalCode') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -PostalCode $PostalCode
        }
        if($PSBoundParameters.ContainsKey('City') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -City $City
        }
        if($PSBoundParameters.ContainsKey('Street') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -StreetAddress $Street
        }
        if($PSBoundParameters.ContainsKey('PhoneNumber') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -TelephoneNumber $PhoneNumber
        }
        if($PSBoundParameters.ContainsKey('MobilePhone') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -Mobile $MobilePhone
        }
        if($PSBoundParameters.ContainsKey('Department') -eq $true ){
            Set-AzureADUser -ObjectId $Script:User.ObjectId -Department $Department
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