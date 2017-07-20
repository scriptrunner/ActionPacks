#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and gets list of users from Azure Active Directory
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Directory Powershell Module v1
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter O365Account
        Specifies the credential to use to connect to Azure Active Directory

    .Parameter HasErrorsOnly
        Inidates that this cmdlet returns only users that have validation errors

    .Parameter OnlyDeletedUsers
        Indicates that this cmdlet returns only users in the recycling bin

    .Parameter OnlyUnlicensedUsers
        Indicates that this cmdlet returns only users who are not assigned a license

    .Parameter LicenseReconciliationNeededOnly
        Indicates that this cmdlet filter for only users that require license reconciliation

    .Parameter Filter
        Specifies the filter for enabled or disabled users

    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
#>

param(
<#   
    [Parameter(Mandatory)] 
    [PSCredential]$O365Account,    
 #>
    [switch]$HasErrorsOnly,
    [switch]$OnlyDeletedUsers,
    [switch]$OnlyUnlicensedUsers,
    [switch]$LicenseReconciliationNeededOnly,
    [ValidateSet('All','EnabledOnly', 'DisabledOnly')]
    [string]$Filter='All',
    [guid]$TenantId
)
 
# Import-Module MSOnline

#Clear

#$ErrorActionPreference='Stop'

# Connect-MsolService -Credential $O365Account 

$Script:result = @()
$Script:Users =Get-MsolUser -TenantId $TenantId -ReturnDeletedUsers:$OnlyDeletedUsers -UnlicensedUsersOnly:$OnlyUnlicensedUsers -EnabledFilter $Filter `
    -HasErrorsOnly:$HasErrorsOnly -LicenseReconciliationNeededOnly:$LicenseReconciliationNeededOnly | `
    Select-Object DisplayName, ObjectID,SignInName,UserPrincipalName,IsLicensed -Unique | Sort-Object -Property DisplayName
if($null -ne $Script:Users){
    foreach($usr in $Script:Users){
        $Script:result += $usr
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:result
    } 
    else{
        Write-Output $Script:result
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "No users found"
    }
    else{
        Write-Output "No users found"
    }
}