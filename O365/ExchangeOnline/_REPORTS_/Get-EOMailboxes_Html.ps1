#Requires -Version 4.0

<#
    .SYNOPSIS
        Generates a report with the mailboxes
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/_Reports_

    .Parameter InactiveMailboxOnly
        [sr-en] Specifies whether to include only inactive mailboxes in the results
        [sr-de] Gibt an, ob nur inaktive Postfächer in den Ergebnissen zurückgegeben werden

    .Parameter IncludeInactiveMailbox
        [sr-en] Specifies whether to include inactive mailboxes in the results
        [sr-de] Gibt an, ob inaktive Postfächer in die Ergebnisse einbezogen werden

    .Parameter ExcludeResources
        [sr-en] Specifies whether to exclude resource mailboxes in the results
        [sr-de] Gibt an, ob nur Ressourcen aus den Ergebnissen ausgeschlossen werden
#>

param(
    [switch]$InactiveMailboxOnly,
    [switch]$IncludeInactiveMailbox,
    [switch]$ExcludeResources
)

try{
    [string[]]$Properties = @('DisplayName','WindowsEmailAddress','IsInactiveMailbox','IsResource','ArchiveStatus','UserPrincipalName')

    if($true -eq $InactiveMailboxOnly){
        $boxes = Get-Mailbox -InactiveMailboxOnly -SortBy DisplayName | Select-Object $Properties
    }
    elseif($true -eq $IncludeInactiveMailbox){
        $boxes = Get-Mailbox -IncludeInactiveMailbox -SortBy DisplayName | Select-Object $Properties
    }
    else{
        $boxes = Get-Mailbox -SortBy DisplayName | Select-Object $Properties
    }
    if($null -ne $boxes){
        if($ExcludeResources){
            $boxes = $boxes | Where-Object -Property IsResource -eq $false
        }    
        ConvertTo-ResultHtml -Result $boxes
    }
}
catch{
    throw
}
finally{

}