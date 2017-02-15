<#
    .SYNOPSIS 
    Connect to Exchange Online.

    .PARAMETER cred
    Exchange Online credential

    .Parameter Filelocation
    Path and filename for list
#>

param(
   [PSCredential]$cred,
   $Filelocation

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

    Get-Mailbox -ResultSize Unlimited | Where {$_.name -NotLike '*DiscoverySearchMailbox*'} | Sort Alias | Select UserPrincipalName, DisplayName,Name, Alias,RecipientTypeDetails, EmailAddresses, PrimarySmtpAddress, MicrosoftOnlineServicesID, WindowsLiveID, WindowsEmailAddress | Export-CSV $Filelocation –NoTypeInformation

    
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