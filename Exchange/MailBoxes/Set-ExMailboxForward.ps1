#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and forwards mail from one mailbox to another mailbox
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        On-premises Exchange Server 2016
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/MailBoxes

    .Parameter MailboxId
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox

    .Parameter ForwardTo
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of a recipient to forward the message to

    .Parameter RuleName 
        Specifies a name for the Inbox rule being created
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [Parameter(Mandatory = $true)]
    [string]$ForwardTo,
    [string]$RuleName
)

try{
    $res = Get-Mailbox -Identity $MailboxId | Select-Object Name
    $forto = Get-Mailbox -Identity $ForwardTo | Select-Object Name
    if($null -ne $res -and $null -ne $forto){
        if([System.String]::IsNullOrWhiteSpace($RuleName)){
            $RuleName = "$($res.Name)to$($forto.Name)"
        }
        New-InboxRule -Name $RuleName -Mailbox $res.Name -ForwardTo $forto.Name -Force -ErrorAction Stop
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Mailbox $($MailboxId) forward to $($ForwardTo)"
        }
        else{
            Write-Output "Mailbox $($MailboxId) forward to $($ForwardTo)"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Mailbox $($MailboxId) or $($ForwardTo) not found"
        } 
        Throw  "Mailbox $($MailboxId) or $($ForwardTo) not found"
    }
}
catch{
    throw
}
Finally{
}