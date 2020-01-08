#Requires -Version 4.0
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
        Azure Active Directory Powershell Module v1
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/Users

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