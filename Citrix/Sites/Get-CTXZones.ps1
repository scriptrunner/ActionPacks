#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets zones configured for this site
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Sites
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter ZoneName
        [sr-en] Name of the zone
        [sr-de] Name der Zone

    .Parameter ControllerName
        [sr-en] Zone that contains a specified Controller identified by Name
        [sr-de] Zone die diesen Controller (Name) beinhalten

    .Parameter ControllerSid
        [sr-en] Zone that contains a specified Controller identified by SID
        [sr-de] Zone die diesen Controller (SID) beinhalten

    .Parameter ExternalUid
        [sr-en] External Uid of the zone
        [sr-de] Externe Uid der Zone

    .Parameter IsPrimary 
        [sr-en] Zones with IsPrimary true/false
        [sr-de] Primäre Zonen J/N

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter TenantId	
        [sr-en] Identity of tenant associated with zone
        [sr-de] Mandant der Zone

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$ZoneName,
    [string]$SiteServer,
    [string]$ControllerName,
    [string]$ControllerSid,
    [string]$ExternalUid,
    [bool]$IsPrimary,
    [int]$MaxRecordCount = 250,
    [string]$TenantId,
    [ValidateSet('*','Name','Description','IsPrimary','ExternalUid','ControllerNames','ControllerSids','Uid','TenantId')]
    [string[]]$Properties = @('Name','Description','IsPrimary','ExternalUid','ControllerNames','Uid')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    if($Properties -contains '*'){
        $Properties = @('*')
    }
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MaxRecordCount' = $MaxRecordCount
                            }    
    
    if($PSBoundParameters.ContainsKey('ZoneName') -eq $true){
        $cmdArgs.Add('Name',$ZoneName)
    }   
    if($PSBoundParameters.ContainsKey('ControllerName') -eq $true){
        $cmdArgs.Add('ControllerName',$ControllerName)
    }
    if($PSBoundParameters.ContainsKey('ControllerSid') -eq $true){
        $cmdArgs.Add('ControllerSid',$ControllerSid)
    }
    if($PSBoundParameters.ContainsKey('IsPrimary') -eq $true){
        $cmdArgs.Add('IsPrimary',$IsPrimary)
    }
    if($PSBoundParameters.ContainsKey('ExternalUid') -eq $true){
        $cmdArgs.Add('ExternalUid',$ExternalUid)
    }
    if($PSBoundParameters.ContainsKey('TenantId') -eq $true){
        $cmdArgs.Add('TenantId',$TenantId)
    }

    $ret = Get-ConfigZone @cmdArgs | Select-Object $Properties
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