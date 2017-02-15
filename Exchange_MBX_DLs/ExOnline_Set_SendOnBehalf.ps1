<#
    .SYNOPSIS 
    Connect to Exchange Online.

    .PARAMETER cred
    Exchange Online credential

    .PARAMETER Identity
    Mailbox to set "Send on Behalf" Permissions

    .PARAMETER Identity2
    Person granted for "Send on Behalf" Permission

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

    Set-Mailbox -Identity $Identity -GrantSendOnBehalfTo $Identity2 

   
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