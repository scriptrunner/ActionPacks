#Requires -Version 5.0

<#
    .SYNOPSIS
        Removes a scope from the site
    
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
        [sr-en] Scope with the specified name
        [sr-de] Name des Geltungsbereichs

    .Parameter Id
        [sr-en] Id of the scope
        [sr-de] Identifier des Geltungsbereichs
#>

param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
    [string]$Id,
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
        $cmdArgs.Add('Id',$Id)
    }                     
    $scope = Get-AdminScope @cmdArgs
    StartLogging -ServerAddress $SiteServer -LogText "Remove Scope $($scope.Name)" -LoggingID ([ref]$LogID)

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'AdminAddress' = $SiteServer
                'LoggingID' = $LogID
                'Force' = $null
                'InputObject' = $scope
                }    
    
    $ret = Remove-AdminScope @cmdArgs
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