#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets the service instances that are registered in the directory
    
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

    .Parameter ServiceUid  
        [sr-en] Unique identifier for the service instance
        [sr-de] Uid der Service Instanz

    .Parameter ServiceGroupName	
        [sr-en] Name for the service group to which the service instance belongs
        [sr-en] Name der Service-Gruppe, zu der die Service Instanz gehört

    .Parameter ServiceType
        [sr-en] Service type for the service instance
        [sr-de] Typ der Service Instanz

    .Parameter InterfaceType
        [sr-en] Interface type for the service instance
        [sr-de] Interface-Typ der Service Instanz

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$SiteServer,
    [string]$ServiceUid ,
    [string]$ServiceGroupName ,
    [string]$ServiceType ,
    [string]$InterfaceType ,
    [int]$MaxRecordCount = 250,
    [ValidateSet('*','Address','Binding','InterfaceType','ServiceAccount','ServiceGroupName','ServiceType','Version')]
    [string[]]$Properties = @('Address','Binding','InterfaceType','ServiceAccount','ServiceGroupName','ServiceType')
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
    if($PSBoundParameters.ContainsKey('ServiceUid') -eq $true){
        $cmdArgs.Add('ServiceUid',$ServiceUid)
    }
    if($PSBoundParameters.ContainsKey('ServiceGroupName') -eq $true){
        $cmdArgs.Add('ServiceGroupName',$ServiceGroupName)
    }
    if($PSBoundParameters.ContainsKey('ServiceType') -eq $true){
        $cmdArgs.Add('ServiceType',$ServiceType)
    }
    if($PSBoundParameters.ContainsKey('InterfaceType') -eq $true){
        $cmdArgs.Add('InterfaceType',$InterfaceType)
    }

    $ret = Get-ConfigRegisteredServiceInstance @cmdArgs | Select-Object $Properties
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