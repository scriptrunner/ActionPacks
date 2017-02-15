<#
    .SYNOPSIS 
    Connect to Exchange Online.

    .PARAMETER cred
    Exchange Online credential

    .PARAMETER Identity
    Mailbox to set "Send as" Permissions

    .PARAMETER Identity2
    Trustee for "Send as" Permission

#>

param(
   [PSCredential]$cred,
   $Identity,
   $Identity2

)

###################################################################
# Exchange Online Remote PowerShell
# Requires .Net Framework 4.5
# no addional install!
# Create Session to Exchange Online
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection -ErrorAction Stop -Verbose

try 
{
    'Session created!'
    Import-PSSession $session -DisableNameChecking

    Remove-RecipientPermission -Identity $Identity -Trustee $Identity2 -AccessRights SendAs -Confirm:$False

   
}
finally 
{
    'finally:'
    Get-PSSession
    if ($session) 
    {
        'Removing Session...'
        Remove-PSSession -Session $session 
    }
}