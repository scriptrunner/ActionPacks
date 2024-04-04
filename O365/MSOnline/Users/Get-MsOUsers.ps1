#Requires -Version 5.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and gets list of users from Azure Active Directory
    
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

    .Parameter HasErrorsOnly
        [sr-en] Only users that have validation errors

    .Parameter OnlyDeletedUsers
        [sr-en] Only users in the recycling bin

    .Parameter OnlyUnlicensedUsers
        [sr-en] Only users who are not assigned a license

    .Parameter LicenseReconciliationNeededOnly
        [sr-en] Filter for only users that require license reconciliation

    .Parameter Filter
        [sr-en] Filter for enabled or disabled users

    .Parameter TenantId
        [sr-en] Unique ID of the tenant on which to perform the operation
#>

param(
    [switch]$HasErrorsOnly,
    [switch]$OnlyDeletedUsers,
    [switch]$OnlyUnlicensedUsers,
    [switch]$LicenseReconciliationNeededOnly,
    [ValidateSet('All','EnabledOnly', 'DisabledOnly')]
    [string]$Filter='All',
    [guid]$TenantId
)
 
try{
    $Script:result = @()
    $Script:Users = Get-MsolUser -TenantId $TenantId -ReturnDeletedUsers:$OnlyDeletedUsers -UnlicensedUsersOnly:$OnlyUnlicensedUsers -EnabledFilter $Filter `
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
}
catch{
    throw
}