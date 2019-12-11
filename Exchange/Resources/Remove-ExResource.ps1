#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and removes the resource
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/Resources

    .Parameter MailboxId
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the resource to remove
    
    .Parameter Permanent
        Specifies whether to permanently delete the resource from the resources database
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$Permanent
)

try{
    Remove-Mailbox -Identity $MailboxId -Permanent:$Permanent -Force -Confirm:$false
                
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Resource $($MailboxId) removed"
    }
    else{
        Write-Output "Resource $($MailboxId) removed"
    }        
}
catch{
    throw
}
finally{
    
}