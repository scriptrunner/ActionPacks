#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and enables oder disables the mailbox
    
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
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox from which to set the enable state

    .Parameter Enable
        Enables or disables the mailbox
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$Enable
)

try{     
    $Script:res=@()
    if($Enable){
        Enable-Mailbox -Identity $MailboxId | Out-Null
        $box = Get-Mailbox -Identity $MailboxId | Select-Object ArchiveState,UserPrincipalName,DisplayName,WindowsEmailAddress
        $Script:res =  $box | Format-List
        $Script:res += "Mailbox $($box.DisplayName) enabled"
    }
    else{
        $box = Get-Mailbox -Identity $MailboxId | Select-Object Database,DisplayName
        if($null -ne $box){
            Disable-Mailbox -Identity $MailboxId -Confirm:$false
        }   
        $Script:res += "Mailbox $($box.DisplayName) disabled"
    }         
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:res
    } 
    else{
        Write-Output $Script:res 
    }
}
catch{
    throw
}
finally{
    
}