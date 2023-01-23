#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Gets the permissions on a mailbox
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/MailBoxes

    .Parameter Identity
        [sr-en] Specifies name, Alias or SamAccountName of the mailbox
        [sr-de] Name, Guid oder UPN des Postfachs

    .Parameter Owner
        [sr-en] Returns the owner information for the mailbox
        [sr-de] Gibt Informationen zu dem Benutzer zurück, der über die Berechtigungen des angegebenen Postfachs verfügt

    .Parameter SoftDeletedMailbox
        [sr-en] Return soft-deleted mailboxes in the results
        [sr-de] Vorläufig gelöschte Postfächer in den Ergebnissen zurückgeben

    .Parameter ResultSize
        [sr-en] Specifies the maximum number of results to return
        [sr-de] Gibt die maximale Anzahl der zurückzugegebenen Ergebnisse an
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Identity,
    [switch]$Owner,
    [switch]$SoftDeletedMailbox,
    [int]$ResultSize = 1000
)

Import-Module ExchangeOnlineManagement

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'ResultSize' = $ResultSize
                    'Owner' = $Owner
                    'Identity' = $Identity
                    'SoftDeletedMailbox' = $SoftDeletedMailbox
    }

    $box = Get-EXOMailboxPermission @cmdArgs
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $box
    } 
    else{
        Write-Output $box 
    }
}
catch{
    throw
}
finally{    
}