#Requires -Version 5.1
#Requires -Modules AzureAD

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
        Azure Active Directory Powershell Module v2
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/_REPORTS_

    .Parameter UserObjectId
        [sr-en] Specifies the unique ID of the user from which to get properties
        [sr-en] Eindeutige ID des Benutzers

    .Parameter UserName
        [sr-en] Specifies the Display name or user principal name of the user from which to get properties
        [sr-en] Anzeigename oder UPN des Benutzers
    
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]
    [guid]$UserObjectId,
    [Parameter(ParameterSetName = "User name")]
    [string]$UserName,
    [ValidateSet('*','DisplayName','GivenName','Surname','Mail','ObjectId','AccountEnabled','Department','City','StreetAddress','TelephoneNumber','Country','CompanyName')]
    [string[]]$Properties = @('DisplayName','Surname','GivenName','Mail','AccountEnabled')
)

try{
    $Script:result = @()
    $Script:Usr
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:Usr = Get-AzureADUser -ObjectId $UserObjectId -ErrorAction Stop | Select-Object $Properties
    }
    else{
        $Script:Usr = Get-AzureADUser -All $true -ErrorAction Stop | Select-Object $Properties
        if([System.String]::IsNullOrWhiteSpace($UserName) -eq $false){
            $Script:Usr = $Script:Usr | Where-Object {($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)}             
        }
    }
    
    ConvertTo-ResultHtml -Result $Script:Usr
}
catch{
    throw
}
finally{ 
}