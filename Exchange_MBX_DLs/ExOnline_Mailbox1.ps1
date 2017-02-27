<#
    .SYNOPSIS 
    Connect to Exchange Online.

#>

[CmdletBinding()]
param(
#   [PSCredential]$cred,
    [Parameter(ParameterSetName='default')]
    $Identity = $null
)

###################################################################
# Exchange Online Remote PowerShell
# Requires .Net Framework 4.5
# no addional install!
# Create Session to Exchange Online
#$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection -ErrorAction Stop -Verbose

#    Import-PSSession $session -DisableNameChecking
    Get-Variable | Where-Object -Property 'Name' -EQ -Value 'SRXEnv' | Select-Object -Property 'Value' | Select-Object -Property '*'
    
    if($Identity){
        $mb = Get-Mailbox -Identity $Identity
    }
    else {
        $mb = Get-Mailbox
        
    }
    if($mb){
        $SRXEnv.ResultMessage = $mb
        $mb
    }
