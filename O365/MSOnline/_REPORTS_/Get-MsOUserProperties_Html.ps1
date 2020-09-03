#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Generates a report with the properties of the users
    
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

    .Parameter UserObjectId
        [sr-en] Specifies the unique ID of the user
        [sr-de] Gibt die eindeutige ID des Benutzers an

    .Parameter UserName
        [sr-en] Specifies the Display name, Sign-In Name or user principal name of the user from which to get properties
        [sr-de] Gibt den Anzeigenamen, Anmeldenamen oder UPN des Benutzers an

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften

    .Parameter TenantId
        [sr-en] Specifies the unique ID of a tenant
        [sr-de] Die eindeutige ID eines Mandanten
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "User name")]
    [string]$UserName,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]
    [ValidateSet('*','DisplayName','FirstName','LastName','StreetAddress','PostalCode','City','Country','Department','Office','PhoneNumber','Title','IsLicensed','SignInName','UserPrincipalName','PasswordNeverExpires')]
    [string[]]$Properties = @('DisplayName','FirstName','LastName','IsLicensed','UserPrincipalName'),
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]
    [guid]$TenantId
)

try{
    $Script:Usr
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:Usr = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId  | Select-Object $Properties
    }
    else{
        $Script:Usr = Get-MsolUser -TenantId $TenantId | `
                Where-Object {($_.DisplayName -eq $UserName) -or ($_.SignInName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
                Select-Object $Properties
    }
    
    if($null -ne $Script:Usr){
        ConvertTo-ResultHtml -Result $Script:Usr
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User not found"
        }    
        Throw "User not found"
    }
}
catch{
    throw
}