#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Mail 

<#
    .SYNOPSIS
        Returns collection of rules that apply to the user's Inbox folder
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Mail 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Mail

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter MailFolderId
        [sr-en] Id of the mail folder
        [sr-de] Ordner ID

    .Parameter MessageRuleId
        [sr-en] Id of the message
        [sr-de] Mail ID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$MailFolderId,
    [string]$MessageRuleId
)

Import-Module Microsoft.Graph.Mail 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'UserId' = $UserId
                        'MailFolderId' = $MailFolderId
    }
    if($PSBoundParameters.ContainsKey('MessageRuleId') -eq $true){
        $cmdArgs.Add('MessageRuleId',$MessageRuleId)
    }
    $result = Get-MgUserMailFolderMessageRule @cmdArgs | Select-Object *

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
}