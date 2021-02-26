#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds or updates metadata on the given Service
    
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

    .Parameter PropertyName	
        [sr-en] Name of the metadata to be added. The property must be unique for the Service specified. 
        The property cannot contain any of the following characters \/;:#.*?=<>
        [sr-de] Eindeutiger Name für die Eigenschaft
        Folgende Zeichen sind nicht gültig \/;:#.*?=<>

    .Parameter PropertyValue	
        [sr-en] Value for the property
        [sr-de] Eigenschaftswert
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$PropertyName,
    [string]$PropertyValue,
    [string]$ControllerServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$ControllerServer)
    StartLogging -ServerAddress $ControllerServer -LogText "Set log service metadata $($PropertyName)" -LoggingID ([ref]$LogID)
    
    if([System.String]::IsNullOrWhiteSpace($PropertyValue) -eq $true){
        $PropertyValue = ''
    }
    $srvID = Get-LogService -AdminAddress $ControllerServer -ErrorAction Stop | Select-Object ServiceHostId
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $ControllerServer
                            'ServiceHostId' = $srvID.ServiceHostId
                            'Name' = $PropertyName
                            'Value' = $PropertyValue
                            'LoggingId' = $LogID
                            }
    
    $null = Set-LogServiceMetadata @cmdArgs
    $ret = Get-LogService -AdminAddress $ControllerServer -ErrorAction Stop | Select-Object -ExpandProperty MetadataMap
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
    StopLogging -LoggingID $LogID -ServerAddress $ControllerServer -IsSuccessful $success
    CloseCitrixSession
}