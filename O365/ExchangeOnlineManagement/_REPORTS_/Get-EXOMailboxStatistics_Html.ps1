#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Generates a report with the information about a mailbox
    
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

    .Parameter Archive
        [sr-en] Specifies whether to return mailbox statistics for the archive mailbox associated with the specified mailbox
        [sr-de] Gibt an, ob die Postfachstatistiken für das mit dem angegebenen Postfach verbundene Archivpostfach zurückgegeben wird

    .Parameter IncludeSoftDeletedRecipients
        [sr-en] Specifies whether to include soft-deleted mailboxes in the results
        [sr-de] Vorläufig gelöschte Postfächer in den Ergebnissen zurückgeben

    .Parameter PropertySet
        [sr-en] Specifies a logical grouping of properties
        [sr-de] Gibt eine logische Gruppierung von Eigenschaften an
    
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Identity,
    [switch]$Archive,
    [switch]$IncludeSoftDeletedRecipients,    
    [ValidateSet('All','Minimum')]
    [string]$PropertySet = 'Minimum',
    [ValidateSet('*','DisplayName','DeletedItemCount','ItemCount','TotalDeletedItemSize','TotalItemSize','LastLogonTime','LastLogoffTime','SystemMessageSizeWarningQuota')]
    [string[]]$Properties =  @('DisplayName','DeletedItemCount','ItemCount','TotalDeletedItemSize','TotalItemSize') 
)

Import-Module ExchangeOnlineManagement

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Identity' = $Identity
                    'Archive' = $Archive
                    'PropertySet' = $PropertySet
                    'IncludeSoftDeletedRecipients' = $IncludeSoftDeletedRecipients
    }

    $result = Get-EXOMailboxStatistics @cmdArgs | Select-Object $Properties 
    ConvertTo-ResultHtml -Result $result    
}
catch{
    throw
}
finally{
    
}