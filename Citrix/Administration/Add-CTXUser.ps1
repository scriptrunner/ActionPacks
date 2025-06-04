#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates an association between user and another object
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
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
    Write-Output $ret
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}