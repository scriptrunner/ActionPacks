#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Get multi-geo region for users or groups

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 2.2.0 or greater
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Members

.Parameter ObjectId
    [sr-en] Group or user Id
    [sr-de] Gruppen oder Benutzer ID

.Parameter ObjectType
    [sr-en] Group or user
    [sr-de] Gruppen oder Benutzer
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ObjectId,
    [Parameter(Mandatory = $true)]   
    [ValidateSet('Group','User')]
    [string]$ObjectType
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'EntityId' = $ObjectId
                            'EntityType' = $ObjectType
                            }  

    $result = Get-MultiGeoRegion @cmdArgs | Select-Object *
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}