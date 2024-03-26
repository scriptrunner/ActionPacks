#Requires -Version 5.0

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

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/_QUERY_
#>

param(
)

try{
    [string[]]$Properties = @('ArchiveStatus','UserPrincipalName','DisplayName','WindowsEmailAddress','IsMailboxEnabled','IsResource','PrimarySmtpAddress')
    $boxes = Get-Mailbox -SortBy DisplayName | Select-Object $Properties
  
    foreach($box in $boxes){
        if($null -ne $SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($box.PrimarySmtpAddress) # Value
            $null = $SRXEnv.ResultList2.Add("$($box.DisplayName) ($($box.PrimarySmtpAddress)") # DisplayValue            
        }
        else{
            Write-Output $box.PrimarySmtpAddress
        }        
    }
}
catch{
    throw
}
finally{
}