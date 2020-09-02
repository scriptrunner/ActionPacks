#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Gets the folder-level permissions in mailboxes
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Requires PS Module ExchangeOnlineManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/MailBoxes

    .Parameter Identity
        [sr-en] Specifies name, Alias or SamAccountName of the mailbox
        [sr-de] Name, Guid oder UPN des Postfachs
    
    .Parameter FolderName
        [sr-en] Specifies the mailbox folder that you want to view
        [sr-de] Gibt den Ordnernamen an, dessen Berechtigungen zurückgegeben werden

    .Parameter GroupMailbox
        [sr-en] Is required to return Microsoft 365 Groups in the results
        [sr-de] Gibt an, ob Microsoft 365-Gruppen in den Ergebnissen zurückzugeben werden

    .Parameter User
        [sr-en] Filters the results by the user, that's granted permission to the mailbox folder. (Name, Alias or Guid)
        [sr-de] Filtert die Ergebnisse nach dem dem E-Mail-Benutzer, der eine Berechtigung für den Postfachordner erteilt hat
        (Name, Alias oder Guid)
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Identity,
    [Parameter(Mandatory=$true)]
    [string]$FolderName,
    [switch]$GroupMailbox,
    [string]$User 
)

Import-Module ExchangeOnlineManagement

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Identity' = "$($Identity):\$($FolderName)"
                    'GroupMailbox' = $GroupMailbox
    }
    
    if($PSBoundParameters.ContainsKey('User') -eq $true){
        $cmdArgs.Add('User',$User)
    }

    $box = Get-EXOMailboxFolderPermission @cmdArgs | Select-Object *
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $box
    } 
    else{
        Write-Output $box 
    }
}
catch{
    throw
}
finally{
    
}