#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets the mailbox send as permissions
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/_QUERY_

    .Parameter MailboxId
        [sr-en] User principal name of the mailbox
        [sr-de] UPN des Postfachs
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId
)

try{
    $users = Get-RecipientPermission -Identity $MailboxId | Select-Object -ExpandProperty Trustee | Get-Mailbox -SortBy DisplayName -ErrorAction SilentlyContinue | Select-Object DisplayName,UserPrincipalName
    foreach($itm in  $users){
        if($SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.UserPrincipalName) # Value
            $null = $SRXEnv.ResultList2.Add($itm.DisplayName) # DisplayValue            
        }
        else{
            Write-Output $itm.DisplayName 
        }
    }
}
catch{
    throw
}
finally{
    
}