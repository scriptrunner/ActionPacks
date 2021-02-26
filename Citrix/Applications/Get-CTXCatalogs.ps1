#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets catalogs configured for this site
    
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

    .Parameter Uid
        [sr-en] Uid of the broker catalog
        [sr-de] Uid des Maschinen-Katalogs

    .Parameter AllocationType
        [sr-en] Gets catalogs that are of the specified allocation type
        [sr-de] Maschinen-Kataloge dieses Typs

    .Parameter AppDnaAnalysisState	
        [sr-en] Catalogs that have of the specified AppDNA Analysis State
        [sr-de] Maschinen-Kataloge dieses AppDNA Analyse Status

    .Parameter IsRemotePC
        [sr-en] Catalogs with the specified IsRemotePC value
        [sr-de] Maschinen-Kataloge mit Remote PC J/N

    .Parameter MinimumFunctionalLevel
        [sr-en] Catalogs with the specified FunctionalLevel
        [sr-de] Maschinen-Kataloge mit diesem FunctionalLevel

    .Parameter PersistUserChanges	
        [sr-en] Catalogs with the specified behavior when persisting changes made by the end user
        [sr-de] Maschinen-Kataloge mit diesem Typ wie Benutzeränderungen gespeichert werden

    .Parameter ProvisioningType
        [sr-en] Catalogs with the specified ProvisioningType
        [sr-de] Maschinen-Kataloge mit dieser Provisioningsmethode

    .Parameter PvsAddress
        [sr-en] Catalogs containing machines provided by the Provisioning Services server with the specified address
        [sr-de] Maschinen-Kataloge die vom Server der Bereitstellungsdienste bereitgestellte Rechner mit der angegebenen Adresse enthalten

    .Parameter PvsDomain
        [sr-en] Catalogs containing machines provided by the Provisioning Services server with the specified domain
        [sr-de] Maschinen-Kataloge die vom Server der Bereitstellungsdienste bereitgestellte Rechner mit der angegebenen Domäne enthalten

    .Parameter HypervisorConnectionUid
        [sr-en] Catalogs associated with the specified hypervisor connection
        [sr-de] Maschinen-Kataloge mit dieser Hypervisor Verbindung

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter TenantId	
        [sr-en] Catalogs associated with the specified tenant identity
        [sr-de] Maschinen-Kataloge, des angegebenen Mandanten

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [string]$Name,
    [string]$SiteServer,
    [Validateset('Static','Permanent','Random')]
    [string]$AllocationType,
    [Validateset('None','Capturing','Canceled','Ready','Failed','Importing')]
    [string]$AppDnaAnalysisState,
    [Validateset('L5','L7','L7_6')]
    [string]$MinimumFunctionalLevel,
    [Validateset('OnLocal','Discard','OnPvd')]
    [string]$PersistUserChanges,
    [Validateset('Manual','PVS','MCS')]
    [string]$ProvisioningType,
    [bool]$IsRemotePC,
    [string]$PvsAddress,
    [string]$PvsDomain,
    [string]$HypervisorConnectionUid,
    [int]$MaxRecordCount = 250,
    [string]$TenantId,
    [string]$Uid,
    [ValidateSet('*','Name','AllocationType','AppDnaAnalysisState','Description','IsRemotePC','MachinesArePhysical','SessionSupport','ProvisioningType','MinimumFunctionalLevel','PersistUserChanges','PvsAddress','PvsDomain','HypervisorConnectionUid','Uid','ZoneName','TenantID')]
    [string[]]$Properties = @('Name','AllocationType','Description','IsRemotePC','MachinesArePhysical','SessionSupport','ProvisioningType','MinimumFunctionalLevel','PersistUserChanges','PvsAddress','PvsDomain','HypervisorConnectionUid','Uid')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }    
    
    if($PSBoundParameters.ContainsKey('Uid') -eq $true){
        $cmdArgs.Add('Uid',$Uid)
    }
    else{
        $cmdArgs.Add('MaxRecordCount',$MaxRecordCount)
        if($PSBoundParameters.ContainsKey('Name') -eq $true){
            $cmdArgs.Add('Name',$Name)
        }
        if($PSBoundParameters.ContainsKey('AllocationType') -eq $true){
            $cmdArgs.Add('AllocationType',$AllocationType)
        }
        if($PSBoundParameters.ContainsKey('AppDnaAnalysisState') -eq $true){
            $cmdArgs.Add('AppDnaAnalysisState',$AppDnaAnalysisState)
        }
        if($PSBoundParameters.ContainsKey('MinimumFunctionalLevel') -eq $true){
            $cmdArgs.Add('MinimumFunctionalLevel',$MinimumFunctionalLevel)
        }
        if($PSBoundParameters.ContainsKey('PersistUserChanges') -eq $true){
            $cmdArgs.Add('PersistUserChanges',$PersistUserChanges)
        }
        if($PSBoundParameters.ContainsKey('ProvisioningType') -eq $true){
            $cmdArgs.Add('ProvisioningType',$ProvisioningType)
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
        if($PSBoundParameters.ContainsKey('HypervisorConnectionUid') -eq $true){
            $cmdArgs.Add('HypervisorConnectionUid',$HypervisorConnectionUid)
        }
        if($PSBoundParameters.ContainsKey('TenantId') -eq $true){
            $cmdArgs.Add('TenantId',$TenantId)
        }
    }
    
    $ret = Get-BrokerCatalog @cmdArgs | Select-Object $Properties
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
    CloseCitrixSession
}