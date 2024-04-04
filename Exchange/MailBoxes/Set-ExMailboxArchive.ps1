#Requires -Version 5.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and sets the mailbox Archive setting to mailbox
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/MailBoxes

    .Parameter MailboxId
        [sr-en] Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox from which to set archive

    .Parameter Enable
        [sr-en] Enables or disables the archive state of the mailbox

    .Parameter ArchiveDatabase 
        [sr-en] Exchange database that contains the archive that's associated with this mailbox
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$Enable,
    [string]$ArchiveDatabase
)

try{
    $box = Get-Mailbox -Identity $MailboxId | Select-Object Database
    if($null -ne $box){
        if($Enable){
            if([System.String]::IsNullOrWhiteSpace($ArchiveDatabase)){
                $ArchiveDatabase=$box.Database
            }
            Enable-Mailbox -Identity $MailboxId -Archive -ArchiveDatabase $ArchiveDatabase -Confirm:$false | Out-Null
        }
        else{
            Disable-Mailbox -Identity $MailboxId -Archive -Confirm:$false
        }
        $res =  Get-Mailbox -Identity $MailboxId | Select-Object ArchiveState,UserPrincipalName,DisplayName,WindowsEmailAddress
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $res | Format-List
        } 
        else{
            Write-Output $res | Format-List 
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