#Requires -Version 5.0

<#
    .SYNOPSIS
        Returns the service instances that are registered in the directory
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Sites
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers
#>

param( 
    [string]$SiteServer
)                                                            

try{ 
    [string[]]$Properties = @('Address','ServiceInstanceUid')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }  

    $result = Get-ConfigRegisteredServiceInstance @cmdArgs | Select-Object $Properties
    foreach($itm in $result | Sort-Object Address){
        if($SRXEnv){
            $null = $SRXEnv.ResultList.Add($itm.ServiceInstanceUid) # value
            $null = $SRXEnv.ResultList2.Add($itm.Address) # display
        }
        else{
            Write-Output $itm.Address
        }
    }
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}