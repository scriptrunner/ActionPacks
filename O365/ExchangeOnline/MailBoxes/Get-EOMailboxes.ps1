#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Exchange Online and gets the mailboxes
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/MailBoxes

    .Parameter InactiveMailboxOnly
        Specifies whether to include only inactive mailboxes in the results

    .Parameter IncludeInactiveMailbox
        Specifies whether to include inactive mailboxes in the results

    .Parameter ExcludeResources
        Specifies whether to exclude resource mailboxes in the results
#>

param(
    [switch]$InactiveMailboxOnly,
    [switch]$IncludeInactiveMailbox,
    [switch]$ExcludeResources
)

try{
    if($true -eq $InactiveMailboxOnly){
        $box = Get-Mailbox -InactiveMailboxOnly -SortBy DisplayName | `
                Select-Object ArchiveStatus,UserPrincipalName,DisplayName,WindowsEmailAddress,IsInactiveMailbox,IsResource
    }
    elseif($true -eq $IncludeInactiveMailbox){
        $box = Get-Mailbox -IncludeInactiveMailbox -SortBy DisplayName | `
                Select-Object ArchiveStatus,UserPrincipalName,DisplayName,WindowsEmailAddress,IsInactiveMailbox,IsResource
    }
    else{
        $box = Get-Mailbox -SortBy DisplayName | Select-Object ArchiveStatus,UserPrincipalName,DisplayName,WindowsEmailAddress,IsInactiveMailbox,IsResource
    }
    if($null -ne $box){
        if($ExcludeResources){
            $box = $box | Where-Object -Property IsResource -EQ $false
        }
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $box
        } 
        else{
            Write-Output $box 
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "No Mailboxes found"
        } 
        else{
            Write-Output "No Mailboxes found"
        }
    }
}
catch{
    throw
}
finally{
    
}