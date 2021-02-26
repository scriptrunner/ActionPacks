#Requires -Version 5.0

<#
    .SYNOPSIS
        Rename a role
    
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
        [sr-en] Role with the specified name
        [sr-de] Name der Rolle

    .Parameter Id
        [sr-en] Id of the role
        [sr-de] Identifier der Rolle

    .Parameter NewName
        [sr-en] New name of the role
        [sr-de] Neuer Name der Rolle
#>

param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
    [string]$Id,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
    [string]$NewName,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'ById')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','Description','Id')
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
    $role = Get-AdminRole @cmdArgs

    StartLogging -ServerAddress $SiteServer -LogText "Rename custom role $($role.Name) to $($NewName)" -LoggingID ([ref]$LogID)

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'AdminAddress' = $SiteServer
                'LoggingID' = $LogID
                'PassThru' = $null
                'InputObject' = $role
                'NewName' = $NewName
                }    
    
    $ret = Rename-AdminRole @cmdArgs | Select-Object $Properties
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