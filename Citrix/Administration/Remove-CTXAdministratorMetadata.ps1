#Requires -Version 5.0

<#
    .SYNOPSIS
        Removes metadata from the given administrator
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Name
        [sr-en] Name of the administrator
        [sr-de] Name des Administrators

    .Parameter SID
        [sr-en] SID of the administrator
        [sr-de] SID des Administrators

    .Parameter PropertyName	
        [sr-en] Name of the metadata to be deleted
        [sr-de] Name der Eigenschaft die gelöscht wird
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$SID,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$PropertyName,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'ById')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                        }

    if($PSCmdlet.ParameterSetName -eq 'ByName'){
        $cmdArgs.Add('Name',$Name)
    }   
    else{
        $cmdArgs.Add('Sid',$SID)
    }                     
    $admin = Get-AdminAdministrator @cmdArgs

    StartLogging -ServerAddress $SiteServer -LogText "Remove administrator metadata $($PropertyName)" -LoggingID ([ref]$LogID)
    [hashtable]$delArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer                            
                            'InputObject' = $admin
                            'Name' = $PropertyName
                            'LoggingId' = $LogID
                            }
    
    $null = Remove-AdminAdministratorMetadata @delArgs
    $success = $true
    $ret = Get-AdminAdministrator @cmdArgs | Select-Object -ExpandProperty MetadataMap
    Write-Output $ret
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}