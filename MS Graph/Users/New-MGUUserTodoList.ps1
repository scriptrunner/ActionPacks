#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Creates task list in the users mailbox
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter DisplayName
        [sr-en] Name of the task list
        [sr-de] Name der Liste

    .Parameter IsOwner
        [sr-en] User is owner of the given task list
        [sr-de] Benutzer ist Besitzer der Liste

    .Parameter IsShared
        [sr-en] Task list is shared with other users
        [sr-de] Liste ist freigegeben für andere Benutzer 

    .Parameter WellknownListName
        [sr-en] Wellknown list name
        [sr-de] Wellknown Listname
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [switch]$IsOwner,
    [switch]$IsShared,
    [string]$WellknownListName
)

Import-Module Microsoft.Graph.Users

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'UserId' = $UserId
                'DisplayName' = $DisplayName
                'Confirm' = $false
    }
    if($IsOwner.IsPresent -eq $true){
        $cmdArgs.Add('IsOwner',$null)
    }
    if($IsShared.IsPresent -eq $true){
        $cmdArgs.Add('IsShared',$null)
    }
    if($PSBoundParameters.ContainsKey('WellknownListName') -eq $true){
        $cmdArgs.Add('WellknownListName',$WellknownListName)
    }
    $null = New-MgUserTodoList @cmdArgs
    
    $result = Get-MgUserTodoList -UserId $UserId | Select-Object *
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }    
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}