#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Retrieving teams with particular properties/information

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams
#>

[CmdLetBinding()]
Param(
)

Import-Module microsoftteams

try{
    $teams = Get-Team -ErrorAction Stop | Sort-Object -Property DisplayName    
    foreach($itm in  $teams){
        if($SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.GroupId) # Value
            $null = $SRXEnv.ResultList2.Add($itm.DisplayName) # DisplayValue            
        }
        else{
            Write-Output $itm.DisplayName 
        }
    }
}
catch{
    throw
}
finally{
}