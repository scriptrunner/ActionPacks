#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates a report with high level operations
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/_REPORTS_
        
    .Parameter ControllerServer
        [sr-en] Address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter StartTime	
        [sr-en] High level operations with the specified start time
        [sr-de] High Level Operationen mit der angegebenen Startzeit

    .Parameter EndTime
        [sr-en] High level operations with the specified end time
        [sr-de] High Level Operationen mit der angegebenen Endzeit

    .Parameter LogSource
        [sr-en] High level operations with the specified source
        [sr-de] Source der High Level Operationen

    .Parameter IsSuccessful
        [sr-en] Successful or unsuccessful high level operations
        [sr-de] Erfolgreiche oder nicht erfolgreiche High Level Operationen

    .Parameter User	
        [sr-en] High level operations logged by the specified user
        [sr-de] High Level Operationen dieses Benutzers

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse
#>

param( 
    [string]$ControllerServer,
    [datetime]$StartTime,
    [datetime]$EndTime,
    [string]$LogSource,
    [bool]$IsSuccessful,
    [string]$User,
    [int]$MaxRecordCount = 250
)                                                            

try{ 
    [string[]]$Properties = @('Text','StartTime','EndTime','IsSuccessful','User','Source')
    StartCitrixSessionAdv -ServerName ([ref]$ControllerServer)
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $ControllerServer
                            'MaxRecordCount' = $MaxRecordCount
                            'SortBy' = '-StartTime'
                            }
    
    if($PSBoundParameters.ContainsKey('StartTime') -eq $true){
        $cmdArgs.Add('StartTime',$StartTime)
    }       
    if($PSBoundParameters.ContainsKey('EndTime') -eq $true){
        $cmdArgs.Add('EndTime',$EndTime)
    }    
    if($PSBoundParameters.ContainsKey('LogSource') -eq $true){
        $cmdArgs.Add('Source',$LogSource)
    }    
    if($PSBoundParameters.ContainsKey('IsSuccessful') -eq $true){
        $cmdArgs.Add('IsSuccessful',$IsSuccessful)
    }  
    if($PSBoundParameters.ContainsKey('User') -eq $true){
        $cmdArgs.Add('User',$User)
    }

    $logs = Get-LogHighLevelOperation @cmdArgs | Select-Object $Properties
    ConvertTo-ResultHtml -result $logs     
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}