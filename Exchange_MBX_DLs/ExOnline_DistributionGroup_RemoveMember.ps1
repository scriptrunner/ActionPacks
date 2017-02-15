<#
    .SYNOPSIS 
    Connect to Exchange Online.

    .PARAMETER cred
    Exchange Online credential

    .PARAMETER DistGroupName
    Name of the Distribution Group

    .PARAMETER UserName
    Username of the member to remove

   
#>

param(
   [PSCredential]$cred,
   $DistGroupName,
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


    Remove-DistributionGroupMember -Identity $DistGroupName -Member $UserName -confirm:$false
    

   
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