#Requires -Version 4.0

<#
    .SYNOPSIS
        Exporting contents of a primary mailbox or archive to a .pst file
    
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

    .Parameter FilePath 
        The FilePath parameter specifies the network share path of the .pst file to which data is exported

    .Parameter IsArchiveBox 
        Specifies that you're exporting from the user's archive
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [switch]$IsArchiveBox
)

try{
    $res = Get-Mailbox -Identity $MailboxId 
    if($null -ne $res){        
        New-MailboxExportRequest -Mailbox $MailboxId -FilePath $FilePath -IsArchive:$IsArchiveBox -ErrorAction Stop
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Mailbox $($MailboxId) exported"
        }
        else{
            Write-Output "Mailbox $($MailboxId) exported"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Mailbox $($MailboxId) not found"
        } 
        Throw  "Mailbox $($MailboxId) not found"
    }
}
catch{
    throw
}
Finally{
}