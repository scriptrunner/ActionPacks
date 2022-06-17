#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups 

<#
    .SYNOPSIS
        Gets conversation thread post
    
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
        Requires Modules Microsoft.Graph.Groups 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Groups
        
    .Parameter GroupId
        [sr-en] Group identifier
        [sr-de] Gruppen ID
        
    .Parameter ConversationId
        [sr-en] Conversation identifier
        [sr-de] Konversation ID
        
    .Parameter ConversationThreadId
        [sr-en] Conversation thread identifier
        [sr-de] Konversation Thread ID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [string]$ConversationId,
    [Parameter(Mandatory = $true)]
    [string]$ConversationThreadId,
    [ValidateSet('ReceivedDateTime','Id','CreatedDateTime','HasAttachments','Attachments','LastModifiedDateTime','MultiValueExtendedProperties','Extensions','ChangeKey','Categories')]
    [string[]]$Properties = @('Id','CreatedDateTime','ReceivedDateTime','LastModifiedDateTime','HasAttachments')
)

Import-Module Microsoft.Graph.Groups

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'    
                        'GroupId'= $GroupId
                        'ConversationId' = $ConversationId
                        'ConversationThreadId' = $ConversationThreadId
    }

    $result = Get-MgGroupConversationThreadPost @cmdArgs | Select-Object $Properties
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