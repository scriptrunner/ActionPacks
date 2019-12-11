#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and removes the mailbox
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/MailBoxes

    .Parameter MailboxId
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox to remove

    .Parameter Permanent
        Specifies the mailbox is permanently removed from the database
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$Permanent 
)

try{
    $box = Get-Mailbox -Identity $MailboxId | Select-Object UserPrincipalName,DisplayName
    if($null -ne $box){
        Remove-Mailbox -Identity $box.UserPrincipalName -Permanent $Permanent.ToBool() -Confirm:$false -Force

        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Mailbox $($box.DisplayName) removed"
        } 
        else{
            Write-Output "Mailbox $($box.DisplayName) removed"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Mailbox not found"
        } 
        Throw  "Mailbox not found"
    }
}
catch{
    throw
}
finally{
    
}