<#
    .SYNOPSIS
        Connect to Exchange Online and gets the mailboxes
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals 
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

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

#Clear
#$ErrorActionPreference='Stop'

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
finally{
    
}