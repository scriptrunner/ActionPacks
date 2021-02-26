#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates a new admin folder
    
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
        [sr-en] Simple name of the new folder
        [sr-de] Name des Anwendungsordners

    .Parameter ParentFolder
        [sr-en] Name or UID of the parent folder
        [sr-de] Name oder Uid des übergeordneten Anwendungsordner, falls vorhanden
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [string]$ParentFolder,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','FolderName','ParentAdminFolderUid','DirectChildApplications','TotalChildApplications','Uid')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Create Admin folder $($FolderName)" -LoggingID ([ref]$LogID)

    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'FolderName' = $FolderName
                            'LoggingId' = $LogID
                            }
    
    if($PSBoundParameters.ContainsKey('ParentFolder') -eq $true){
        $cmdArgs.Add('ParentFolder',$FolderName)
    }

    $ret = New-BrokerAdminFolder @cmdArgs | Select-Object $Properties
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