#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets the mailboxes
    
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
    [string[]]$Properties = @('PrimarySmtpAddress','UserPrincipalName','DisplayName','WindowsEmailAddress','IsInactiveMailbox','IsResource')
    if($true -eq $InactiveMailboxOnly){
        $boxes = Get-Mailbox -InactiveMailboxOnly -SortBy DisplayName | `
                Select-Object $Properties
    }
    elseif($true -eq $IncludeInactiveMailbox){
        $boxes = Get-Mailbox -IncludeInactiveMailbox -SortBy DisplayName | `
                Select-Object $Properties
    }
    else{
        $boxes = Get-Mailbox -SortBy DisplayName | Select-Object $Properties
    }
    if($null -ne $boxes){        
        if($ExcludeResources){
            $boxes = $boxes | Where-Object -Property IsResource -eq $false
        }
        foreach($itm in  $boxes){
            if($SRXEnv) {            
                $null = $SRXEnv.ResultList.Add($itm.UserPrincipalName) # Value
                $null = $SRXEnv.ResultList2.Add($itm.DisplayName) # DisplayValue            
            }
            else{
                Write-Output $itm.DisplayName 
            }
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