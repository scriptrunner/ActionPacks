#Requires -Version 5.0

<#
    .SYNOPSIS
        Moves a folder to another place in the hierarchy, optionally renaming it
    
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
        [sr-en] Name of folder to be moved, with path
        [sr-de] Name des zu verschiebenden Anwendungsordners, mit Pfad

    .Parameter Destination
        [sr-en] Destination folder the folder being moved should end up in
        [sr-de] Zielordner in den der Anwendungsordner verschoben wird

    .Parameter NewName
        [sr-en] Name the new folder should have in the destination folder
        [sr-de] Name den der Anwendungsordner im Zielordner erhalten soll
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [string]$NewName,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','FolderName','ParentAdminFolderUid','DirectChildApplications','TotalChildApplications','Uid')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Move Admin folder $($FolderName) to $($Destination)" -LoggingID ([ref]$LogID)

    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Name' = $FolderName
                            'Destination' = $Destination
                            'PassThru' = $null
                            'LoggingId' = $LogID
                            }

    if($PSBoundParameters.ContainsKey('NewName') -eq $true){
        $cmdArgs.Add('NewName',$NewName)
    }

    $ret = Move-BrokerAdminFolder @cmdArgs | Select-Object $Properties
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