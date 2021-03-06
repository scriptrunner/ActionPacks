﻿#Requires -Version 5.0

<#
    .SYNOPSIS
        Exports Configuration Logging data into a HTML report
    
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
        [sr-en] Start time of the earliest operation to include
        [sr-de] Startzeit der frühesten Operation

    .Parameter EndDateRange	
        [sr-en] End time of the earliest operation to include
        [sr-de] Endzeit der frühesten Operation

    .Parameter OutputDirectory
        [sr-en] Path to a directory where the HTML report files will will be saved 
        [sr-de] Verzeichnis in dem der Html Report gespeichert wird
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,
    [string]$ControllerServer,
    [datetime]$StartDateRange,
    [datetime]$EndDateRange
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$ControllerServer)
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $ControllerServer
                            'OutputDirectory' = $OutputDirectory
                            }
    
    if($PSBoundParameters.ContainsKey('StartDateRange') -eq $true){
        $cmdArgs.Add('StartDateRange',$StartDateRange)
    }       
    if($PSBoundParameters.ContainsKey('EndDateRange') -eq $true){
        $cmdArgs.Add('EndDateRange',$EndDateRange)
    }

    $ret = Export-LogReportHtml @cmdArgs | Select-Object *
    if(($null -ne $SRXEnv) -and (Test-Path -Path "$($OutputDirectory)\Summary.html") -eq $true){
        $SRXEnv.ResultHtml = (Get-Content -Path "$($OutputDirectory)\Summary.html")
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
    CloseCitrixSession
}