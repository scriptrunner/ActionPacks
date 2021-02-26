#Requires -Version 5.0

<#
    .SYNOPSIS
        Retrieves the scopes where the specified operation is permitted
    
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

    .Parameter Operations
        [sr-en] Operation to query, comma separated
        [sr-de] Abzufragende Operationen, Komma getrennt

    .Parameter QueryOperations
        [sr-en] Operations to query, find by the Query _\QUERY_\QUY_Get-CTXOperations
        [sr-de] Abzufragende Operationen, durch die Query _\QUERY_\QUY_Get-CTXOperations abgefragt

    .Parameter Annotate
        [sr-en] Annotates each result with the operation it relates to
        [sr-de] Kommentiert jedes Ergebnis mit der Operation, auf die es sich bezieht
#>

param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [string]$Operations,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByQuery',HelpMessage = "ASRDisplay(Multiline)")]
    [string[]]$QueryOperations,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'ByQuery')]
    [string]$SiteServer,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'ByQuery')]
    [switch]$Annotate
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    if($PSCmdlet.ParameterSetName -eq 'Default'){
        $QueryOperations = $Operations.Split(',')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Operation' = $QueryOperations
                            } 
    if($Annotate.IsPresent -eq $true){
        $cmdArgs.Add('Annotate',$Annotate)
    }

    $ret = Test-AdminAccess @cmdArgs | Select-Object  @('Operation','ScopeName','ScopeId')
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