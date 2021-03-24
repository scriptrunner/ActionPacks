#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates an association between user and another object
    
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
        [sr-en] Name of the user to be added
        [sr-de] Name des Benutzers der zu dem Objekt hinzugefügt wird

    .Parameter ApplicationGroup
        [sr-en] Application group to which the user is to be assigned
        [sr-de] Anwendungsgruppe zu der der Benutzer hinzugefügt wird

    .Parameter Application
        [sr-en] Application to which the user is to be assigned
        [sr-de] Anwendung zu der der Benutzer hinzugefügt wird

    .Parameter Machine
        [sr-en] Machine to which the user is to be assigned
        [sr-de] Maschine zu der der Benutzer hinzugefügt wird

    .Parameter PrivateDesktop
        [sr-en] Desktop to which the user is to be assigned
        [sr-de] Desktop zu dem der Benutzer hinzugefügt wird
    #>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'Application')]
    [Parameter(Mandatory = $true,ParameterSetName = 'Application Group')]
    [Parameter(Mandatory = $true,ParameterSetName = 'Machine')]
    [Parameter(Mandatory = $true,ParameterSetName = 'Private Desktop')]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName = 'Application')]
    [string]$Application,
    [Parameter(Mandatory = $true,ParameterSetName = 'Application Group')]
    [string]$ApplicationGroup,
    [Parameter(Mandatory = $true,ParameterSetName = 'Machine')]
    [string]$Machine,
    [Parameter(Mandatory = $true,ParameterSetName = 'Private Desktop')]
    [string]$PrivateDesktop,
    [Parameter(ParameterSetName = 'Application')]
    [Parameter(ParameterSetName = 'Application Group')]
    [Parameter(ParameterSetName = 'Machine')]
    [Parameter(ParameterSetName = 'Private Desktop')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Add user $($Name) to object" -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Name' = $Name
                            'LoggingId' = $LogID
                            }    
    
    if($PSCmdlet.ParameterSetName -eq 'Application'){
        $cmdArgs.Add('Application',$Application)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'Application Group'){
        $cmdArgs.Add('ApplicationGroup',$ApplicationGroup)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'Machine'){
        $cmdArgs.Add('Machine',$Machine)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'Private Desktop'){
        $cmdArgs.Add('PrivateDesktop',$PrivateDesktop)
    }
    
    $ret = Add-BrokerUser @cmdArgs | Select-Object *
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