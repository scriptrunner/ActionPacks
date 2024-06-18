#Requires -Version 5.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and creates a user in Azure Active Directory
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/Users

    .Parameter UserPrincipalName
        [sr-en] User ID for this user

    .Parameter Password
        [sr-en] New password for the user

    .Parameter DisplayName
        [sr-en] Display name of the user

    .Parameter FirstName
        [sr-en] First name of the user

    .Parameter LastName
        [sr-en] Last name of the user

    .Parameter PostalCode
        [sr-en] Postal code of the user

    .Parameter City
        [sr-en] City of the user

    .Parameter Street
        [sr-en] Street address of the user

    .Parameter PhoneNumber
        [sr-en] Phone number of the user

    .Parameter MobilePhone
        [sr-en] Mobile phone number of the user

    .Parameter Office
        [sr-en] Office of the user

    .Parameter Department
        [sr-en] Department of the user

    .Parameter ForceChangePassword
        [sr-en] User is required to change their password the next time they sign in

    .Parameter PasswordNeverExpires
        [sr-en] User password expires periodically

    .Parameter Enabled
        [sr-en] User is able to log on using their user ID

    .Parameter TenantId
        [sr-en] Unique ID of the tenant on which to perform the operation
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,
    [Parameter(Mandatory = $true)]
    [string]$Password,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [string]$FirstName,
    [string]$LastName,
    [string]$PostalCode,
    [string]$City,
    [string]$Street,
    [string]$PhoneNumber,
    [string]$MobilePhone,
    [string]$Office,
    [string]$Department,
    [switch]$ForceChangePassword,
    [switch]$PasswordNeverExpires,
    [switch]$Enabled,
    [guid]$TenantId
)

try{
    $Script:User = New-MsolUser -UserPrincipalName $UserPrincipalName -TenantId $TenantId -DisplayName $DisplayName -BlockCredential (-not $Enabled) `
                            -City $City -Department $Department -FirstName $FirstName -LastName $LastName -MobilePhone -$MobilePhone -PhoneNumber $PhoneNumber `
                            -Office $Office -PasswordNeverExpires $PasswordNeverExpires.ToBool() -PostalCode $PostalCode -StreetAddress $Street -Password $Password `
                            -ForceChangePassword $ForceChangePassword.ToBool() | Select-Object *
    if($null -ne $Script:User){
        $Script:User = Get-MsolUser -TenantId $TenantId | Where-Object {$_.UserPrincipalName -eq $UserPrincipalName} | Select-Object *
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
catch{
    throw
}