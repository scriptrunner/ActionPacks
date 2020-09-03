#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Generates a report with a list of users from Azure Active Directory
    
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
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/_REPORTS_

    .Parameter HasErrorsOnly
        [sr-en] Inidates that this cmdlet returns only users that have validation errors
        [sr-de] Nur Benutzer mit Validierungsfehlern

    .Parameter OnlyDeletedUsers
        [sr-en] Indicates that this cmdlet returns only users in the recycling bin
        [sr-de] Nur gelöschte Benutzer

    .Parameter OnlyUnlicensedUsers
        [sr-en] Indicates that this cmdlet returns only users who are not assigned a license
        [sr-de] Nur Benutzer denen keine Lizenz zugewiesen wurde

    .Parameter LicenseReconciliationNeededOnly
        [sr-en] Indicates that this cmdlet filter for only users that require license reconciliation
        [sr-de] Nur Benutzer die eine Lizenzabstimmung benötigen

    .Parameter Filter
        [sr-en] Specifies the filter for enabled or disabled users
        [sr-de] Filter für aktivierte oder deaktivierte Benutzer

    .Parameter TenantId
        [sr-en] Specifies the unique ID of a tenant
        [sr-de] Die eindeutige ID eines Mandanten
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
    [string[]]$Properties = @('DisplayName','ObjectID','SignInName','UserPrincipalName','IsLicensed')
    
    $Script:Users = Get-MsolUser -TenantId $TenantId -ReturnDeletedUsers:$OnlyDeletedUsers -UnlicensedUsersOnly:$OnlyUnlicensedUsers -EnabledFilter $Filter `
                                -HasErrorsOnly:$HasErrorsOnly -LicenseReconciliationNeededOnly:$LicenseReconciliationNeededOnly | `
                                Select-Object $Properties -Unique | Sort-Object -Property DisplayName
    if($null -ne $Script:Users){
        ConvertTo-ResultHtml -Result $Script:Users
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