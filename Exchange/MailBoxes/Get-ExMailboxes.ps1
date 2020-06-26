#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and gets the mailboxes
    
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

    .Parameter EnabledMailboxOnly
        Specifies whether to include only enabled mailboxes in the results

    .Parameter ExcludeResources
        Specifies whether to exclude resource mailboxes in the results

    .Parameter Properties
        List of properties to expand. Use * for all properties
#>

param(
    [switch]$EnabledMailboxOnly,
    [switch]$ExcludeResources,
    [Validateset('*','ArchiveStatus','UserPrincipalName','DisplayName','WindowsEmailAddress','IsMailboxEnabled','IsResource')]
    [string[]]$Properties = @('ArchiveStatus','UserPrincipalName','DisplayName','WindowsEmailAddress','IsMailboxEnabled','IsResource')
)

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    if($EnabledMailboxOnly -eq $true){
        $boxes = Get-Mailbox -SortBy DisplayName | Where-Object -Property IsMailboxEnabled -eq $true | `
                Select-Object $Properties
    }
    else{
        $boxes = Get-Mailbox -SortBy DisplayName | Select-Object $Properties
    }
    if($null -ne $boxes){
        if($ExcludeResources){
            $boxes = $boxes | Where-Object -Property IsResource -EQ $false
        }
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $boxes
        } 
        else{
            Write-Output $boxes
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "No Mailboxes found"
        } 
        else{
            Write-Output  "No Mailboxes found"
        }
    }
}
catch{
    throw
}
finally{

}