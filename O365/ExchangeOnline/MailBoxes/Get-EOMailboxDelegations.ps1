#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets the mailbox delegations
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/MailBoxes

    .Parameter MailboxId
        [sr-en] Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox from which to get properties
        [sr-de] Name, Guid oder UPN des Postfachs
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId
)

try{
    $box = New-Object System.Collections.Generic.Queue[string]
    $box.Enqueue('Send As')
    $box.Enqueue('---------------')
    $tmp = Get-RecipientPermission -Identity $MailboxId -ErrorAction Stop | Select-Object *
    foreach ($item in $tmp) {
        $box.Enqueue($item.Trustee)
    }
    $box.Enqueue(' ')

    $box.Enqueue('Send On Behalf')
    $box.Enqueue('---------------')
    $tmp = Get-Mailbox -Identity $MailboxId -ErrorAction Stop | Select-Object -ExpandProperty GrantSendOnBehalfTo
    foreach ($item in $tmp) {
        $box.Enqueue($item)
    }
    $box.Enqueue(' ')

    $box.Enqueue('Full Access')
    $box.Enqueue('---------------')
    $tmp = Get-MailboxPermission -Identity $MailboxId -ErrorAction Stop | Select-Object *
    foreach ($item in $tmp) {
        $box.Enqueue($item.User)
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $box.ToArray()
    } 
    else{
        Write-Output $box.ToArray()
    }
}
catch{
    throw
}
finally{
}