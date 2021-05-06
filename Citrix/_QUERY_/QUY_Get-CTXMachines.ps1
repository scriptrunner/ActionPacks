#Requires -Version 5.0

<#
    .SYNOPSIS
        Returns machines belonging to this site
    
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
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter CatalogName	
        [sr-en] Machines from the catalog with the specific name
        [sr-de] Maschinen dieses Maschinenkatalogs
        
    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse
#>

param(
    [string]$CatalogName,
    [int]$MaxRecordCount = 250,
    [string]$SiteServer
)                                                            

try{ 
    [string[]]$Properties = @('MachineName','Uid')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MaxRecordCount' = $MaxRecordCount
                            }    

    if($PSBoundParameters.ContainsKey('CatalogName') -eq $true){
        $cmdArgs.Add('CatalogName',$CatalogName)
    }

    $ret = Get-BrokerMachine @cmdArgs | Select-Object $Properties
    foreach($machine in $ret){
        if($SRXEnv){
            $null = $SRXEnv.ResultList.Add($machine.Uid) # value
            $null = $SRXEnv.ResultList2.Add($machine.MachineName) # display
        }
        else{
            Write-Output $grp.Name
        }
    }
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}