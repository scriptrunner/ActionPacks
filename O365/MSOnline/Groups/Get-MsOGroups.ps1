#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and gets groups from Azure Active Directory
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/Groups

    .Parameter IsAgentRole
        Specifies that this cmdlet returns only agent groups. This value applies only to partner users

    .Parameter HasLicenseErrorsOnly
        Specifies whether this cmdlet returns only security groups that have license errors

    .Parameter HasErrorsOnly
        Indicates that this cmdlet returns only groups that have validation errors
    
    .Parameter GroupType
        Specifies the type of groups to get

    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
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
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:Grps | Sort-Object -Property DisplayName | Format-List -Property DisplayName, Objectid, GroupType  
        } 
        else{
            Write-Output $Script:Grps | Sort-Object -Property DisplayName | Format-List -Property DisplayName, Objectid, GroupType
        }
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