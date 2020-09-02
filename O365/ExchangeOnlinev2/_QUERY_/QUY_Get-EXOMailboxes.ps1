#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Gets the mailbox objects
    
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

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/_QUERY_

    .Parameter Archive
        [sr-en] Returns only mailboxes that have an archive mailbox
        [sr-de] Gibt an, das nur Postfächern, für die ein Archiv aktiv ist, zurückgegeben werden

    .Parameter InactiveMailboxOnly
        [sr-en] Returns only inactive mailboxes
        [sr-de] Gibt an, das nur inaktive Postfächer in den Ergebnissen zurückgegeben werden

    .Parameter IncludeInactiveMailbox
        [sr-en] Include inactive mailboxes in the result
        [sr-de] Gibt an, das inaktive Postfächer in den Ergebnissen zurückgegeben werden

    .Parameter SoftDeletedMailbox
        [sr-en] Inculde soft-deleted mailboxes in the result
        [sr-de] Gibt an, das vorläufig gelöschte Postfächer in den Ergebnissen zurückgegeben werden
#>

param(
    [switch]$Archive,
    [switch]$InactiveMailboxOnly,
    [switch]$IncludeInactiveMailbox,
    [switch]$SoftDeletedMailbox
)

Import-Module ExchangeOnlineManagement

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Archive' = $Archive
                    'InactiveMailboxOnly' = $InactiveMailboxOnly
                    'IncludeInactiveMailbox' = $IncludeInactiveMailbox
                    'SoftDeletedMailbox' = $SoftDeletedMailbox
    }

    $boxes = Get-EXOMailbox @cmdArgs | Select-Object DisplayName,Name | Sort-Object DisplayName
    foreach($itm in $boxes){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($itm.Name) # Value
            $null = $SRXEnv.ResultList2.Add($itm.DisplayName) # Display
        }
        else{
            Write-Output $itm.DisplayName
        }
    }
}
catch{
    throw
}
finally{    
}