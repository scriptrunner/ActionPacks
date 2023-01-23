#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Generates a report with the information about the folders in a specified mailbox
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Requires PS Module ExchangeOnlineManagement
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/_Reports_

    .Parameter Identity
        [sr-en] Specifies name, Alias or SamAccountName of the mailbox
        [sr-de] Name, Guid oder UPN des Postfachs
    
    .Parameter Folderscope
        [sr-en] Specifies the scope of the search by folder type
        [sr-de] Gibt den Bereich für die Suche nach dem Postfachtyp an

    .Parameter Archive
        [sr-en] Specifies whether to return the usage statistics of the archive mailbox that's associated with the mailbox or mail user
        [sr-de] Gibt an, ob die Verwendungsstatistiken des Archivpostfachs zurückgegeben werden

    .Parameter IncludeOldestAndNewestItems
        [sr-en] Specifies whether to return the dates of the oldest and newest items in each folder
        [sr-de] Gibt an, ob die Datumsangaben der ältesten und neuesten Elemente in jedem Ordner zurückgegeben werden

    .Parameter IncludeSoftDeletedRecipients
        [sr-en] Specifies whether to include soft-deleted mailboxes in the results
        [sr-de] Gibt an, ob vorläufig gelöschte Postfächer in die Ergebnisse einbezogen werden
    
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Identity,
    [ValidateSet('All','Archive','Calendar','Clutter','Contacts','ConversationHistory','DeletedItems','Drafts','Inbox','Journal','JunkEmail','LegacyArchiveJournals','ManagedCustomFolder','NonIpmRoot','Notes','Outbox','Personal','RecoverableItems','RssSubscriptions','SentItems','SyncIssues','Tasks')]
    [string]$Folderscope = 'All',
    [switch]$Archive,
    [switch]$IncludeOldestAndNewestItems,
    [switch]$IncludeSoftDeletedRecipients,    
    [ValidateSet('*','Name','LastModifiedTime','ItemsInFolder','DeletedItemsInFolder','FolderAndSubfolderSize','FolderSize','FolderType','FolderPath','Identity')]
    [string[]]$Properties =  @('Name','LastModifiedTime','ItemsInFolder','DeletedItemsInFolder','FolderAndSubfolderSize','FolderType','FolderPath') 
)

Import-Module ExchangeOnlineManagement

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Identity' = $Identity
                    'Folderscope' = $Folderscope
                    'Archive' = $Archive
                    'IncludeOldestAndNewestItems' = $IncludeOldestAndNewestItems
                    'IncludeSoftDeletedRecipients' = $IncludeSoftDeletedRecipients
    }

    $result = Get-EXOMailboxFolderStatistics @cmdArgs | Select-Object $Properties 
    ConvertTo-ResultHtml -Result $result    
}
catch{
    throw
}
finally{
    
}