#Requires -Version 5.0

<#
    .SYNOPSIS
        Set the properties of a scope
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Administration
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Name
        [sr-en] Scope with the specified name
        [sr-de] Name des Geltungsbereichs

    .Parameter Id
        [sr-en] Id of the scope
        [sr-de] Identifier des Geltungsbereichs

    .Parameter Description
        [sr-en] Description of the scope
        [sr-de] Beschreibung des Geltungsbereichs
#>

param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
    [string]$Id,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'ById')]
    [string]$SiteServer,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'ById')]
    [string]$Description
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','Description','BuiltIn','id')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Change Scope $($Name)" -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingID' = $LogID
                            'PassThru' = $null
                            }    
    
    if($PSCmdlet.ParameterSetName -eq 'ById'){
        $cmdArgs.Add('Id',$Id)
    }
    else{
        $cmdArgs.Add('Name',$Name)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    
    $ret = Set-AdminScope @cmdArgs | Select-Object $Properties
    $success = $true
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}