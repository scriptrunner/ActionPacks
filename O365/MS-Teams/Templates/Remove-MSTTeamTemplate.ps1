#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
    .SYNOPSIS
        Deletes a specified Team Template from Microsoft Teams

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
        Requires Library script MSTLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Templates
    
    .Parameter MSTCredential
        [sr-en] Provides the user ID and password for organizational ID credentials
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter ODataId
        [sr-en] Composite URI of the template
        [sr-de] URI der Vorlage

    .Parameter Name
        [sr-en] Name of the template
        [sr-de] Name der Vorlage

    .Parameter TenantID
        [sr-en] Specifies the ID of a tenant
        [sr-de] Identifier des Mandanten
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [pscredential]$MSTCredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]  
    [string]$ODataId,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]  
    [string]$Name,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [string]$TenantID
)

Import-Module microsoftteams

try{
    [string[]]$Properties = @('Name','OdataId')
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID

    if($PSCmdlet.ParameterSetName -eq 'ById'){
        $null = Remove-CsTeamTemplate -OdataId $ODataId -ErrorAction Stop
    }
    else{
        $null = (Get-CsTeamTemplateList -ErrorAction Stop) | Where-Object Name -eq $Name | ForEach-Object {Remove-CsTeamTemplate -OdataId $_.OdataId}
    }

    $result = Get-CsTeamTemplateList -ErrorAction Stop
    if($SRXEnv) {
        $SRXEnv.ResultMessage = ($result | Select-Object $Properties | Sort-Object Name)
    }
    else{
        Write-Output ($result | Select-Object $Properties | Sort-Object Name)
    }
}
catch{
    throw
}
finally{
    DisconnectMSTeams
}