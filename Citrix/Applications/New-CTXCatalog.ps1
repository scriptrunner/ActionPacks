#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds a new catalog to the site
    
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
        [sr-en] Name of the new broker catalog
        [sr-de] Name des neuen Maschinen-Katalogs

    .Parameter AllocationType
        [sr-en] How machines in the catalog are assigned to users
        [sr-de] Wie Maschinen im Katalog den Benutzern zugeordnet werden

    .Parameter ProvisioningType
        [sr-en] ProvisioningType for the catalog
        [sr-de] Provisioningsmethode für den Maschinen-Katalog

    .Parameter SessionSupport	
        [sr-en] Single or multi-session capable
        [sr-de] Einzel- oder Multisession-fähig

    .Parameter PersistUserChanges	
        [sr-en] How user changes are persisted on machines in the catalog
        [sr-de] Wie Benutzeränderungen auf den Rechnern im Maschinen-Katalog gespeichert werden

    .Parameter Description 
        [sr-en] Description for this catalog
        [sr-de] Beschreibung der Maschinen-Katalog

    .Parameter IsRemotePC	
        [sr-en] Remote PC catalog
        [sr-de] Remote PC Maschinen-Katalog

    .Parameter MachinesArePhysical	
        [sr-en] Machines in the catalog can be power-managed by the Citrix Broker Service
        [sr-de] Maschinen im Maschinen-Katalog können über den Citrix Broker Service verwaltet werden

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

    .Parameter TenantId	
        [sr-en] Identity of tenant associated with catalog
        [sr-de] Mandant des Maschinen-Katalogs
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [Validateset('Static','Permanent','Random')]
    [string]$AllocationType,
    [Parameter(Mandatory = $true)]
    [Validateset('Manual','PVS','MCS')]
    [string]$ProvisioningType,
    [Parameter(Mandatory = $true)]
    [Validateset('SingleSession','MultiSession')]
    [string]$SessionSupport,
    [Parameter(Mandatory = $true)]
    [Validateset('OnLocal','Discard','OnPvd')]
    [string]$PersistUserChanges,
    [string]$SiteServer,
    [string]$Description,
    [bool]$IsRemotePC,
    [bool]$MachinesArePhysical = $true,
    [Validateset('L5','L7','L7_6','L7_7','L7_8','L7_9','L7_20','L7_25')]
    [string]$MinimumFunctionalLevel = 'L7_6',
    [string]$PvsAddress,
    [string]$PvsDomain,
    [string]$RemotePCHypervisorConnectionUid,
    [string]$TenantId
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','AllocationType','Description','IsRemotePC','MachinesArePhysical','SessionSupport','ProvisioningType','MinimumFunctionalLevel','PersistUserChanges','PvsAddress','PvsDomain','HypervisorConnectionUid','Uid')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Create Catalog $($Name)" -LoggingID ([ref]$LogID)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            'Name' = $Name
                            'AllocationType' = $AllocationType
                            'ProvisioningType' = $ProvisioningType
                            'SessionSupport' = $SessionSupport
                            'PersistUserChanges' = $PersistUserChanges
                            'MinimumFunctionalLevel' = $MinimumFunctionalLevel
                            'MachinesArePhysical' = $MachinesArePhysical
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
    if(($IsRemotePC -eq $true) -and ($PSBoundParameters.ContainsKey('RemotePCHypervisorConnectionUid') -eq $true)){
        $cmdArgs.Add('RemotePCHypervisorConnectionUid',$RemotePCHypervisorConnectionUid)
    }
    if($PSBoundParameters.ContainsKey('TenantId') -eq $true){
        $cmdArgs.Add('TenantId',$TenantId)
    }

    $ret = New-BrokerCatalog @cmdArgs | Select-Object $Properties
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