<#
    .SYNOPSIS 
    Connect to Exchange Online.

    .PARAMETER cred
    Exchange Online credential

    .Parameter DistGroupName
    Name of the Distribution Group

    .Parameter DisplayName
    Display name of the Distribution Group

    .Parameter AliasName
    Alias name of the Distribution Group

    .Parameter Username
    The manager of the distribution group
#>

param(
   [PSCredential]$cred,
   $DistGroupName,
   $DisplayName,
   $AliasName,
   $UserName

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



    New-DistributionGroup -Name $DistGroupName -DisplayName $DisplayName -Alias $AliasName -ManagedBy $UserName
#    New-DistributionGroup -Name "Sales Wolrd Wide" -DisplayName "World wide Sales mail list" -Alias "SalesWW" -ManagedBy maxm
 
   
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