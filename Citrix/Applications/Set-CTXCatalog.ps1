#Requires -Version 5.0

<#
    .SYNOPSIS
        Sets the properties of a catalog
    
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

    .Parameter Name
        [sr-en] Name of the broker catalog
        [sr-de] Name des Maschinen-Katalogs

    .Parameter Description
        [sr-en] Description for this catalog
        [sr-de] Beschreibung der Maschinen-Katalog

    .Parameter IsRemotePC
        [sr-en] Remote PC catalog
        [sr-de] Remote PC Maschinen-Katalog

    .Parameter MinimumFunctionalLevel
        [sr-en] Minimum FunctionalLevel required for machines to register in the site
        [sr-de] Mindest FunctionalLevel, erforderöich für Maschinen zum Registrieren

    .Parameter PvsAddress
        [sr-en] URL of the Provisioning Services server
        [sr-de] URL des Provisioning Services Servers

    .Parameter PvsDomain
        [sr-en] Active Directory domain of the Provisioning Services server
        [sr-de] Active Directory Domäne des Provisioning Services Servers

    .Parameter RemotePCHypervisorConnectionUid
        [sr-en] Hypervisor connection to use for powering on remote PCs in this catalog (only allowed when IsRemotePC is true)
        [sr-de] Hypervisor Verbindung zum Ein-/Ausschalten der Remote-PCs, nur gültig wenn IsRemotePC ist true
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$SiteServer,
    [string]$Description,
    [bool]$IsRemotePC,
    [Validateset('L5','L7','L7_6')]
    [string]$MinimumFunctionalLevel = 'L7_6',
    [string]$PvsAddress,
    [string]$PvsDomain,
    [string]$RemotePCHypervisorConnectionUid
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','Description','IsRemotePC','MinimumFunctionalLevel','PvsAddress','PvsDomain','HypervisorConnectionUid')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Change Catalog $($Name)" -LoggingID ([ref]$LogID)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            'Name' = $Name
                            'PassThru' = $null
                            'MinimumFunctionalLevel' = $MinimumFunctionalLevel
                            }    
    
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('IsRemotePC') -eq $true){
        $cmdArgs.Add('IsRemotePC',$IsRemotePC)
    }
    if($PSBoundParameters.ContainsKey('PvsAddress') -eq $true){
        $cmdArgs.Add('PvsAddress',$PvsAddress)
    }
    if($PSBoundParameters.ContainsKey('PvsDomain') -eq $true){
        $cmdArgs.Add('PvsDomain',$PvsDomain)
    }    
    if($PSBoundParameters.ContainsKey('RemotePCHypervisorConnectionUid') -eq $true){
        $cmdArgs.Add('RemotePCHypervisorConnectionUid',$RemotePCHypervisorConnectionUid)
    }

    $ret = Set-BrokerCatalog @cmdArgs | Select-Object $Properties
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