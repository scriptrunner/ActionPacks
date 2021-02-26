#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets high level operations ids
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/_QUERY_
        
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
#>

param( 
    [string]$ControllerServer,
    [datetime]$StartTime,
    [datetime]$EndTime,
    [string]$LogSource,
    [bool]$IsSuccessful
)                                                            

try{ 
    [string[]]$Properties = @('Text','StartTime','EndTime','ID')
    StartCitrixSessionAdv -ServerName ([ref]$ControllerServer)
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $ControllerServer
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

    $logs = Get-LogHighLevelOperation @cmdArgs | Select-Object $Properties
    
    foreach($itm in $logs){
        $display = "$($itm.StartTime)-$($itm.EndTime) - $($itm.Text)"
        if($SRXEnv){
            $null = $SRXEnv.ResultList.Add($itm.Id) # value
            $null = $SRXEnv.ResultList2.Add($display) # display
        }
        else{
            Write-Output $display
        }
    }
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}