#Requires -Version 5.0

<#
    .SYNOPSIS
        Removes an admin folder
    
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

    .Parameter FolderName
        [sr-en] Folder name of the folder
        [sr-de] Name der Anwendungsordners

    .Parameter FolderUid
        [sr-en] Uid of the folder
        [sr-de] Uid der Anwendungsordners
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$FolderName,
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$FolderUid,
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
        $cmdArgs.Add('FolderName',$FolderName)
    }
    else{
        $cmdArgs.Add('Uid',$FolderUid)
    }
    $folder = Get-BrokerAdminFolder @cmdArgs
    StartLogging -ServerAddress $SiteServer -LogText "Remove Admin folder $($folder.Name)" -LoggingID ([ref]$LogID)
    
    $cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Name' = $folder.Name
                            'LoggingId' = $LogID
                            }

    $null = Remove-BrokerAdminFolder @cmdArgs
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
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}