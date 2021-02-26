#Requires -Version 5.0

<#
    .SYNOPSIS
        Add application group to a desktop group
    
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

    .Parameter ApplicationGroup
        [sr-en] Name for the application group
        [sr-de] Name der neuen Anwendungsgruppe

    .Parameter DesktopGroup	
        [sr-en] Desktop group with which the application groups should be associated
        [sr-de] Desktop-Gruppe, mit der die Anwendungsgruppen verbunden werden soll

    .Parameter Priority
        [sr-en] Priority of the mapping between the application group and desktop group. 
        Lower numbers imply higher priority with zero being highest.
        [sr-de] Priorität der Zuordnung zwischen der Anwendungsgruppe und der Desktop-Gruppe. 
        Niedrigere Zahlen bedeuten höhere Priorität, Null ist die höchste
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$ApplicationGroup,
    [Parameter(Mandatory = $true)]
    [string]$DesktopGroup,
    [int]$Priority,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','Description','Enabled','AssociatedDesktopGroupUids')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Add Application Group $($ApplicationGroup) to Desktop group $($DesktopGroup)" -LoggingID ([ref]$LogID)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            'Name' = $ApplicationGroup
                            'DesktopGroup' = $DesktopGroup
                            'Priority' = $Priority
                            }

    $null = Add-BrokerApplicationGroup @cmdArgs
    $success = $true
    $tmp = Get-BrokerApplicationGroup -Name $ApplicationGroup -ErrorAction Stop | Select-Object $Properties
    [PSCustomObject]$ret = @{
        'ApplicationGroup' = $tmp.Name
        'Description' = $tmp.Description
        'Enabled' = $tmp.Enabled
    }
    [int]$counter = 1
    foreach($desGrp in $tmp.AssociatedDesktopGroupUids){
        $tmp = Get-BrokerDesktopGroup -Uid $desGrp -AdminAddress $SiteServer
        $ret.Add("DesktopGroup_$($counter)",$tmp.Name)
        $counter++
    }

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