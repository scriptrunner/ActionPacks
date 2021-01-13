#Requires -Version 5.0

<#
    .SYNOPSIS
        Removes mailbox delegations
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/MailBoxes

    .Parameter MailboxId
        [sr-en] Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox from which to get properties
        [sr-de] Name, Guid oder UPN des Postfachs

    .Parameter SendAsTrustees
        [sr-en] Specifies the users or groups where removing the permission
        Name, Guid or UPN
        [sr-de] Benutzer oder Gruppen deren Stellvertretung für das Postfach (Name, Guid oder UPN) gelöscht wird

    .Parameter SendOnBehalfTrustees
        [sr-en] Specifies the users or groups where removing SendOnBehalf permission
        Name, Guid or UPN
        [sr-de] Benutzer oder Gruppen der Stellvertretung 'Senden im Auftrag von' für das Postfach (Name, Guid oder UPN) gelöscht wird

    .Parameter FullAccessTrustees
        [sr-en] Specifies the users or groups where removing Full Access permission
        Name, Guid or UPN
        [sr-de] Benutzer oder Gruppen deren Vollzugriff für das Postfach (Name, Guid oder UPN) gelöscht wird
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [string[]]$SendAsTrustees,    
    [string[]]$SendOnBehalfTrustees,    
    [string[]]$FullAccessTrustees
)

try{
    $output = New-Object System.Collections.Generic.Queue[string]

    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            Identity = $MailboxId
                            Confirm = $false
    }
    # send as
    if($PSBoundParameters.ContainsKey('SendAsTrustees') -eq $true){
        foreach ($item in $SendAsTrustees) {
            $null = Remove-RecipientPermission @cmdArgs -AccessRights SendAs -Trustee $item
        }
        $output.Enqueue('Send As')
        $output.Enqueue('---------------')
        $tmp = Get-RecipientPermission -Identity $MailboxId -ErrorAction Stop | Select-Object *
        foreach ($item in $tmp) {
            $output.Enqueue($item.Trustee)
        }
        $output.Enqueue(' ')
    }
    # send on behalf
    if($PSBoundParameters.ContainsKey('SendOnBehalfTrustees') -eq $true){
        $null = Set-Mailbox @cmdArgs -GrantSendOnBehalfTo @{Remove=$SendOnBehalfTrustees} -Force
        $output.Enqueue('Send On Behalf')
        $output.Enqueue('---------------')
        $tmp = Get-Mailbox -Identity $MailboxId -ErrorAction Stop | Select-Object -ExpandProperty GrantSendOnBehalfTo
        foreach ($item in $tmp) {
            $output.Enqueue($item)
        }
        $output.Enqueue(' ')
    }
    # Full Access
    if($PSBoundParameters.ContainsKey('FullAccessTrustees') -eq $true){
        foreach ($item in $FullAccessTrustees) {
            $null = Remove-MailboxPermission @cmdArgs -User $item -AccessRights FullAccess -InheritanceType All
        }            
        $output.Enqueue('Full Access')
        $output.Enqueue('---------------')
        $tmp = Get-MailboxPermission -Identity $MailboxId -ErrorAction Stop | Select-Object *
        foreach ($item in $tmp) {
            $output.Enqueue($item.User)
        } 
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output.ToArray()
    } 
    else{
        Write-Output $output.ToArray()
    }
}
catch{
    throw
}
finally{
}