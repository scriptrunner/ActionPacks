#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and gets the mailboxes
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG 

    .COMPONENT       
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/MailBoxes

    .Parameter EnabledMailboxOnly
        Specifies whether to include only enabled mailboxes in the results

    .Parameter ExcludeResources
        Specifies whether to exclude resource mailboxes in the results
#>

param(
    [switch]$EnabledMailboxOnly,
    [switch]$ExcludeResources
)

try{
        if($EnabledMailboxOnly -eq $true){
            $boxes = Get-Mailbox -SortBy DisplayName | Where-Object -Property IsMailboxEnabled -eq $true | `
                    Select-Object ArchiveStatus,UserPrincipalName,DisplayName,WindowsEmailAddress,IsMailboxEnabled,IsResource
        }
        else{
            $boxes = Get-Mailbox -SortBy DisplayName | Select-Object ArchiveStatus,UserPrincipalName,DisplayName,WindowsEmailAddress,IsMailboxEnabled,IsResource
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
finally{

}