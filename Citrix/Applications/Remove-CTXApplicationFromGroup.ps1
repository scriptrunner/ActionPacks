#Requires -Version 5.0

<#
    .SYNOPSIS
        Removes application from a desktop group or application group
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Applications
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter ApplicationName
        [sr-en] Name of the application
        [sr-de] Name der Anwendung

    .Parameter ApplicationGroup
        [sr-en] Application group that this application should no longer be associated with
        [sr-de] Anwendungsgruppe, der diese Anwendung zugeordnet ist

    .Parameter DesktopGroup
        [sr-en] Desktop group that this application should no longer be associated with
        [sr-de] Desktopgruppe, der diese Anwendung zugeordnet ist
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ApplicationGroup')]
    [Parameter(Mandatory = $true,ParameterSetName = 'DesktopGroup')]
    [string]$ApplicationName,   
    [Parameter(Mandatory = $true,ParameterSetName = 'ApplicationGroup')]
    [string]$ApplicationGroup,
    [Parameter(Mandatory = $true,ParameterSetName = 'DesktopGroup')]
    [string]$DesktopGroup,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','PublishedName','Description','AssociatedApplicationGroupUids','AssociatedDesktopGroupUids')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Name' = $ApplicationName
                            'Force' = $null
                            }
                            
    [string]$grpType = 'Application group'
    [string]$grp
    if($PSCmdlet.ParameterSetName -eq 'DesktopGroup'){
        $cmdArgs.Add('DesktopGroup',$DesktopGroup)
        $grpType = 'Desktop group'
        $grp = $DesktopGroup
    }
    else{
        $cmdArgs.Add('ApplicationGroup',$ApplicationGroup)
        $grp = $ApplicationGroup
    }
    StartLogging -ServerAddress $SiteServer -LogText "Remove Application $($ApplicationName) from $($grpType) $($grp)" -LoggingID ([ref]$LogID)
    $cmdArgs.Add('LoggingId',$LogID)
    
    $null = Remove-BrokerApplication @cmdArgs
    $ret = Get-BrokerApplication -Name $ApplicationName -AdminAddress $SiteServer -ErrorAction Stop | Select-Object $Properties
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