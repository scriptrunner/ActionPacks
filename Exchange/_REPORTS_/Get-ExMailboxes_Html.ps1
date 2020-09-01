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
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/_REPORTS_ 

    .Parameter EnabledMailboxOnly
        Specifies whether to include only enabled mailboxes in the results

    .Parameter ExcludeResources
        Specifies whether to exclude resource mailboxes in the results
#>

param(
    [switch]$EnabledMailboxOnly,
    [switch]$ExcludeResources
)

try{
    [string[]]$Properties = @('Name','ArchiveStatus','UserPrincipalName','DisplayName','WindowsEmailAddress','IsMailboxEnabled','IsResource')

    if($EnabledMailboxOnly -eq $true){
        $boxes = Get-Mailbox -SortBy DisplayName | Where-Object -Property IsMailboxEnabled -eq $true | `
                Select-Object $Properties
    }
    else{
        $boxes = Get-Mailbox -SortBy DisplayName | Select-Object $Properties
    }
    
    ConvertTo-ResultHtml -Result $boxes
}
catch{
    throw
}
finally{

}