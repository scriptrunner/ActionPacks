#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Returns all team templates available to your tenant

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 1.1.1 or greater
    Requires .NET Framework Version 4.7.2.
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_QUERY_
 
.Parameter PublicTemplateLocale
    [sr-en] The language and country code of templates localization for Microsoft team templates
    [sr-de] Die Sprache und der Ländercode der Microsoft-Teamvorlagen
#>

[CmdLetBinding()]
Param(
    [string]$PublicTemplateLocale
)

Import-Module microsoftteams

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    if($PSBoundParameters.ContainsKey('PublicTemplateLocale') -eq $true){
        $cmdArgs.Add("PublicTemplateLocale", $PublicTemplateLocale)
    }

    $templates = Get-CsTeamTemplateList @cmdArgs

    foreach($itm in  ($templates | Sort-Object Name)){
        if($SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.OdataId) # Value
            $null = $SRXEnv.ResultList2.Add($itm.Name) # DisplayValue            
        }
        else{
            Write-Output $itm.Name 
        }
    }
}
catch{
    throw
}
finally{
}