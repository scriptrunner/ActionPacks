#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets operations logged within time intervals inside a date range
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Logging
        
    .Parameter ControllerServer
        [sr-en] Address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter StartDateRange	
        [sr-en] Start of the summary period date range
        [sr-de] 

    .Parameter EndDateRange	
        [sr-en] End of the summary period date range
        [sr-de] 

    .Parameter GetLowLevelOperations
        [sr-en] Return low level operation summary counts
        [sr-de] 

    .Parameter IncludeIncomplete
        [sr-en] Incomplete operations should be included in the returned summary counts
        [sr-de] 

    .Parameter OperationType
        [sr-en] Type of logged operations to include. 
        [sr-de] 
#>

param( 
    [string]$ControllerServer,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartDateRange,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndDateRange,
    [switch]$GetLowLevelOperations,
    [switch]$IncludeIncomplete,
    [ValidateSet('AdminActivity','ConfigurationChange')]
    [string]$OperationType
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$ControllerServer)
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $ControllerServer
                            'GetLowLevelOperations' = $GetLowLevelOperations
                            'IncludeIncomplete' = $IncludeIncomplete
                            }
    
    if($PSBoundParameters.ContainsKey('StartDateRange') -eq $true){
        $cmdArgs.Add('StartDateRange',$StartDateRange)
    }       
    if($PSBoundParameters.ContainsKey('EndDateRange') -eq $true){
        $cmdArgs.Add('EndDateRange',$EndDateRange)
    }
    if($PSBoundParameters.ContainsKey('OperationType') -eq $true){
        $cmdArgs.Add('OperationType',$OperationType)
    }

    $ret = Get-LogSummary @cmdArgs | Select-Object *
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