#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Updates task in this task list
    
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

    .Parameter Title
        [sr-en] Brief description of the task
        [sr-de] Beschreibung der Aufgabe

    .Parameter IsReminderOn
        [sr-en] Set alert to remind the user of the task
        [sr-de] Alarm einstellen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$TodoTaskListId ,
    [Parameter(Mandatory = $true)]
    [string]$TodoTaskId,
    [string]$Title,
    [switch]$IsReminderOn
)

Import-Module Microsoft.Graph.Users

try{
    [string[]]$Properties = @('Title','Id','LastModifiedDateTime','Status')
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'UserId' = $UserId
                'TodoTaskListId' = $TodoTaskListId
                'TodoTaskId' = $TodoTaskId
                'Confirm' = $false
                'PassThru' = $null
    }
    if($PSBoundParameters.ContainsKey('Title') -eq $true){
        $cmdArgs.Add('Title',$Title)
    }
    if($IsReminderOn.IsPresent -$true){
        $cmdArgs.Add('IsReminderOn',$null)
    }
    $null = Update-MgUserTodoListTask @cmdArgs

    $result = Get-MgUserTodoListTask -UserId $UserId -TodoTaskListId $TodoTaskListId | Sort-Object Title | Select-Object $Properties    
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