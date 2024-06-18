#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Get media content for the navigation property attachments from users
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
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
        [sr-en] Unique identifier of todoTask
        [sr-de] Eindeutige ID des Tasks

    .Parameter AttachmentId
        [sr-en] Identifier of attachment
        [sr-de] ID des Attachments

    .Parameter Outfile
        [sr-en] Path to write output file to
        [sr-de] Pfad und Name der Datei in die der Inhalt geschrieben wird
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$TodoTaskListId,
    [Parameter(Mandatory = $true)]
    [string]$TodoTaskId,
    [Parameter(Mandatory = $true)]
    [string]$AttachmentId,
    [Parameter(Mandatory = $true)]
    [string]$Outfile
)

Import-Module Microsoft.Graph.Users

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'UserId' = $UserId
                'TodoTaskListId' = $TodoTaskListId
                'TodoTaskId' = $TodoTaskId
                'AttachmentBaseId' = $AttachmentId
                'Outfile' = $Outfile
    }
    $result = Get-MgUserTodoTaskAttachmentContent @cmdArgs -PassThru | Select-Object *
    
    if($null -ne $SRXEnv) {
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
}