#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Exchange Online and gets the mailbox properties
    
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

    .Parameter MailboxId
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox from which to get properties

    .Parameter Properties
        List of properties to expand. Use * for all properties
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [ValidateSet('*','DisplayName','FirstName','LastName','Office', 'Phone','WindowsEmailAddress','AccountDisabled','DistinguishedName','Alias','Guid','ResetPasswordOnNextLogon','UserPrincipalName')]
    [string[]]$Properties=@('DisplayName','FirstName','LastName','Office','Phone','WindowsEmailAddress','AccountDisabled','DistinguishedName','Alias','Guid','ResetPasswordOnNextLogon','UserPrincipalName')
)

try{
    $res = Get-Mailbox -Identity $MailboxId | Select-Object $Properties 
    if($null -ne $res){        
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $res
        }
        else{
            Write-Output $res
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