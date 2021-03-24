#Requires -Version 5.0

<#
    .SYNOPSIS
        Remove broker user object from another broker object
    
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
        [sr-de] Name des Benutzers der von dem Objekt entfernt wird

    .Parameter ApplicationGroup
        [sr-en] Application group from which to remove the user
        [sr-de] Anwendungsgruppe von der der Benutzer entfernt wird

    .Parameter Application
        [sr-en] Application from which to remove the user
        [sr-de] Anwendung von der der Benutzer entfernt wird

    .Parameter Machine
        [sr-en] Machine from which to remove the user
        [sr-de] Maschine von der der Benutzer entfernt wird

    .Parameter PrivateDesktop
        [sr-en] Desktop from which to remove the user
        [sr-de] Desktop von dem der Benutzer entfernt wird
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
    StartLogging -ServerAddress $SiteServer -LogText "Remove user $($Name) from object" -LoggingID ([ref]$LogID)

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
    
    $ret = Remove-BrokerUser @cmdArgs | Select-Object *
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