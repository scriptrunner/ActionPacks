#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Generates a report with the groups from Azure Active Directory<<
    
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

    .Parameter IsAgentRole
        [sr-en] Specifies that this cmdlet returns only agent groups. This value applies only to partner users
        [sr-de] Nur Agentengruppen 

    .Parameter HasLicenseErrorsOnly
        [sr-en] Specifies whether this cmdlet returns only security groups that have license errors
        [sr-de] Nur Sicherheitsgruppen mit Lizenzfehlern

    .Parameter HasErrorsOnly
        [sr-en] Indicates that this cmdlet returns only groups that have validation errors
        [sr-de] Nur Gruppen mit Validierungsfehlern
    
    .Parameter GroupType
        [sr-en] Specifies the type of groups to get
        [sr-de] Gibt den Typ der Gruppen an

    .Parameter TenantId
        [sr-en] Specifies the unique ID of a tenant
        [sr-de] Die eindeutige ID eines Mandanten
#>

param(
    [switch]$IsAgentRole,
    [switch]$HasLicenseErrorsOnly,  
    [switch]$HasErrorsOnly,
    [ValidateSet('All','Security', 'MailEnabledSecurity','DistributionList')]
    [string]$GroupType='All',
    [guid]$TenantId
)

try{    
    [string[]]$Properties = @('DisplayName','Description','EmailAddress','GroupType','IsSystem','ValidationStatus','CommonName','ObjectID')
    if ($IsAgentRole -eq $true) {
        if([System.String]::IsNullOrWhiteSpace($GroupType -or $GroupType -eq 'All')){
            $Script:Grps = Get-MsolGroup -HasLicenseErrorsOnly:$HasLicenseErrorsOnly.ToBool() -HasErrorsOnly:$HasErrorsOnly -TenantId $TenantId -IsAgentRole
        }
        else {
            $Script:Grps = Get-MsolGroup -HasLicenseErrorsOnly:$HasLicenseErrorsOnly.ToBool() -HasErrorsOnly:$HasErrorsOnly -GroupType $GroupType  -TenantId $TenantId -IsAgentRole
        }
    }
    else {
        if([System.String]::IsNullOrWhiteSpace($GroupType) -or $GroupType -eq 'All'){
            $Script:Grps = Get-MsolGroup -HasLicenseErrorsOnly:$HasLicenseErrorsOnly.ToBool() -HasErrorsOnly:$HasErrorsOnly  -TenantId $TenantId
        }
        else {
            $Script:Grps = Get-MsolGroup -HasLicenseErrorsOnly:$HasLicenseErrorsOnly.ToBool() -HasErrorsOnly:$HasErrorsOnly -GroupType $GroupType  -TenantId $TenantId
        }
    }
    if($null -ne $Script:Grps){
        ConvertTo-ResultHtml -Result ($Script:Grps | Select-Object $Properties | Sort-Object -Property DisplayName)        
    }
    else {
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "No groups found"
        } 
        else{
            Write-Output "No groups found"
        }
    }    
}
catch{
    throw
}