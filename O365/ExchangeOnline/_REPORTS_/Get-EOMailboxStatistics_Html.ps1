#Requires -Version 4.0

<#
    .SYNOPSIS
        Generates a report with the mailbox statistics for the mailboxes
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT  
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/_REPORTS_

    .Parameter Archive
        [sr-en] Specifies whether to return mailbox statistics for the archive mailbox associated with the specified mailbox
        [sr-de] Gibt an, ob die Postfachstatistiken für das verbundene Archivpostfach zurückgegeben werden
#>

param(
    [switch]$Archive
)

try{
    [string[]]$Properties = @('DisplayName','ItemCount','TotalItemSize','DeletedItemCount','TotalDeletedItemSize','DatabaseIssueWarningQuota','DatabaseProhibitSendQuota','DatabaseProhibitSendReceiveQuota','IsArchiveMailbox','LastInteractionTime','IsValid')
    $boxes = Get-Mailbox -Identity $MailboxId -ErrorAction Stop
    if($null -ne $boxes){
        $res = $boxes |  Get-MailboxStatistics -Archive:$Archive | Select-Object $Properties
        ConvertTo-ResultHtml -Result $res
    }
    else{
        Throw  "Mailboxes not found"
    }
}
catch{
    throw
}
finally{
    
}