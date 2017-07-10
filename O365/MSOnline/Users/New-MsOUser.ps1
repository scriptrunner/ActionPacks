#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and creates a user in Azure Active Directory
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Diretory Powershell Module
    
    .DESCRIPTION          

    .Parameter O365Account
        Specifies the credential to use to connect to Azure Active Directory

    .Parameter UserPrincipalName
        Specifies the user ID for this user

    .Parameter Password
        Specifies the new password for the user

    .Parameter DisplayName
        Specifies the display name of the user

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

    .Parameter Office
        Specifies the office of the user

    .Parameter Department
        Specifies the department of the user

    .Parameter ForceChangePassword
        Indicates that the user is required to change their password the next time they sign in

    .Parameter PasswordNeverExpires
        Specifies whether the user password expires periodically

    .Parameter Enabled
        Specifies whether the user is able to log on using their user ID

    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
#>

param(
<#   
    [Parameter(Mandatory = $true)]
    [PSCredential]$O365Account,
#>
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

# Import-Module MSOnline

#Clear
$ErrorActionPreference='Stop'

# Connect-MsolService -Credential $O365Account 

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
    Write-Error "User not created"
}