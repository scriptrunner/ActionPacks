#Requires -Version 5.0

<#
    .SYNOPSIS
        Deletes Tag Metadata from the Tag objects
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Administration
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Name
        [sr-en] Tag name
        [sr-de] Name des Tags

    .Parameter PropertyName	
        [sr-en] Name of the metadata to be deleted
        [sr-de] Name der Eigenschaft die gelöscht wird
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$PropertyName,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Remove tag metadata $($PropertyName)" -LoggingID ([ref]$LogID)
    $tag = Get-BrokerTag -Name $Name -AdminAddress $SiteServer -ErrorAction Stop
    [hashtable]$delArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer                            
                            'InputObject' = $tag
                            'Name' = $PropertyName
                            'LoggingId' = $LogID
                            }
    
    $null = Remove-BrokerTagMetadata @delArgs
    $success = $true
    $ret = Get-BrokerTag -AdminAddress $SiteServer -ErrorAction Stop | Where-Object {$_.Name -eq $Name} | Select-Object -ExpandProperty MetadataMap  
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