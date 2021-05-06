#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
    .SYNOPSIS
        Retrieving details of a team template available to your tenant

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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Templates

    .Parameter ODataId
        [sr-en] A composite URI of a template
        [sr-de] URI einer Vorlage

    .Parameter Name
        [sr-en] Name of the template
        [sr-de] Name der Vorlage
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]  
    [string]$ODataId,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]  
    [string]$Name
)

Import-Module microsoftteams

try{
    if($PSCmdlet.ParameterSetName -eq 'ById'){
        $Script:tmp = Get-CsTeamTemplate -OdataId $ODataId -ErrorAction Stop
    }
    else{
        $Script:tmp = (Get-CsTeamTemplateList -ErrorAction Stop) | Where-Object Name -eq $Name | ForEach-Object {Get-CsTeamTemplate -OdataId $_.OdataId}
    }

    $result = $Script:tmp | Select-Object *

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