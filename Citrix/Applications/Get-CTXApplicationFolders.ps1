#Requires -Version 5.0

<#
    .SYNOPSIS
        Get the admin folders in this site
    
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

    .Parameter Uid
        [sr-en] Only the admin folder with the specified unique identifier
        [sr-de] Anwendungsordner mit dieser Uid

    .Parameter Name
        [sr-en] Admin folders matching the specified name
        [sr-de] Anwendungsordner, deren Name mit dem angegebenen Name übereinstimmt (Ordnerpfad)
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens

    .Parameter FolderName
        [sr-en] Only the admin folders matching the specified simple folder name.
        [sr-de] Anwendungsordner, mit diesem Namen

    .Parameter ParentAdminFolderUid	
        [sr-en] Admin folders with the specified parent admin folder UID value
        [sr-de] Anwendungsordner, mit der angegebenen UID des übergeordneten Anwendungsordner

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$SiteServer,
    [string]$Uid,
    [string]$Name,
    [string]$FolderName,
    [string]$ParentAdminFolderUid,
    [int]$MaxRecordCount = 250,
    [ValidateSet('*','Name','FolderName','ParentAdminFolderUid','DirectChildApplications','TotalChildApplications','DirectChildAdminFolders','LastChangeId','Uid')]
    [string[]]$Properties = @('Name','FolderName','ParentAdminFolderUid','DirectChildApplications','TotalChildApplications','Uid')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MaxRecordCount' = $MaxRecordCount
                            }
    
    if([System.String]::IsNullOrWhiteSpace($Uid) -eq $false){
        $cmdArgs.Add('Uid',$Uid)
    }
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name',$Name)
    }
    
    if($PSBoundParameters.ContainsKey('FolderName') -eq $true){
        $cmdArgs.Add('FolderName',$FolderName)
    }
    if($PSBoundParameters.ContainsKey('ParentAdminFolderUid') -eq $true){
        $cmdArgs.Add('ParentAdminFolderUid',$ParentAdminFolderUid)
    }

    $ret = Get-BrokerAdminFolder @cmdArgs | Select-Object $Properties | Sort-Object Name

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