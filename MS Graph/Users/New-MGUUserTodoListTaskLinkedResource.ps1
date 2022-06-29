#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Creates resource linked to the task

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

    .Parameter TodoTaskListId 
        [sr-en] Id of todo task list
        [sr-de] Todo-Tasklist ID

    .Parameter TodoTaskId 
        [sr-en] Id of todo task
        [sr-de] Task ID

    .Parameter ApplicationName
        [sr-en] App name of the source that is sending the linked resource
        [sr-de] Quell-Anwendungsname die die linked Ressource sendet

    .Parameter DisplayName
        [sr-en] Title of the linked resource
        [sr-de] Anzeigename der linked Ressource

    .Parameter WebUrl
        [sr-en] Deep link to the linked resource
        [sr-de] Link zur Ressource
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$TodoTaskListId,
    [Parameter(Mandatory = $true)]
    [string]$TodoTaskId,
    [Parameter(Mandatory = $true)]
    [string]$ApplicationName,
    [string]$DisplayName,
    [string]$WebUrl
)

Import-Module Microsoft.Graph.Users

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'UserId' = $UserId
                'TodoTaskListId' = $TodoTaskListId
                'TodoTaskId' = $TodoTaskId
                'ApplicationName' = $ApplicationName
                'Confirm' = $false
    }
    if($PSBoundParameters.ContainsKey('DisplayName') -eq $true){
        $cmdArgs.Add('DisplayName',$DisplayName)
    }
    if($PSBoundParameters.ContainsKey('WebUrl') -eq $true){
        $cmdArgs.Add('WebUrl',$WebUrl)
    }
    $null = New-MgUserTodoListTaskLinkedResource @cmdArgs

    $result = Get-MgUserTodoListTaskLinkedResource -UserId $UserId -TodoTaskListId $TodoTaskListId -TodoTaskId $TodoTaskId | Sort-Object ApplicationName
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