#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Changes settings for a DFS namespace root server

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
        https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/DFS

    .Parameter ServerName
        [sr-en] Host name or fully qualified domain name (FQDN) for a DFS namespace server
        [sr-de] Hostname oder FQDN des Servers

    .Parameter EnableInsiteReferrals
        [sr-en] Server provides only in-site referrals
        [sr-de] Server unterstützt nur In-Site Verweise

    .Parameter EnableSiteCostedReferrals
        [sr-en] Server can use cost-based selection
        [sr-de] Server unterstützt nur Cost-Based Auswahl

    .Parameter SyncIntervalSec
        [sr-en] Interval, in seconds
        [sr-de] Intervall, in Sekunden
    
    .Parameter LdapTimeoutSec
        [sr-en] Time-out value, in seconds, for Lightweight Directory Access Protocol (LDAP) requests
        [sr-de] Time-Out Wert, in Sekunden, für LDAP Anfragen

    .Parameter PreferLogonDC
        [sr-en] Prefer the logon domain controller in referrals
        [sr-de] Logon-Domänencontroller in Verweisen bevorzugen

    .Parameter UseFqdn
        [sr-en] DFS namespace server uses FQDNs in referrals
        [sr-de] DFS-Namensraumserver verwendet FQDNs in Verweisen

    .Parameter ComputerName
        [sr-en] Name of the DFS computer
        [sr-de] DFS-Server 

    .Parameter AccessAccount
        [sr-en] User account that has permission to perform this action
        [sr-de] Ausreichend berechtigtes Benutzerkonto
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [bool]$EnableInsiteReferrals,
    [bool]$EnableSiteCostedReferrals,
    [bool]$PreferLogonDC,
    [UInt32]$LdapTimeoutSec,
    [UInt32]$SyncIntervalSec,
    [bool]$UseFqdn,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module DFSN

$cimSes = $null
try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        $cmdArgs.Add('ComputerName', $ComputerName)
    }          
    if($null -ne $AccessAccount){
        $cmdArgs.Add('Credential', $AccessAccount)
    }
    $cimSes = New-CimSession @cmdArgs    

    $cmdArgs = @{ErrorAction = 'Stop'
                    'ComputerName' = $ServerName
                    'Confirm' = $false
                    'CimSession' = $cimSes
    }
    if($PSBoundParameters.ContainsKey('EnableInsiteReferrals') -eq $true){
        $cmdArgs.Add('EnableInsiteReferrals',$EnableInsiteReferrals)
    }
    if($PSBoundParameters.ContainsKey('EnableSiteCostedReferrals') -eq $true){
        $cmdArgs.Add('EnableSiteCostedReferrals',$EnableSiteCostedReferrals)
    }
    if($PSBoundParameters.ContainsKey('LdapTimeoutSec') -eq $true){
        $cmdArgs.Add('LdapTimeoutSec',$LdapTimeoutSec)
    }
    if($PSBoundParameters.ContainsKey('SyncIntervalSec') -eq $true){
        $cmdArgs.Add('SyncIntervalSec',$SyncIntervalSec)
    }
    if($PSBoundParameters.ContainsKey('PreferLogonDC') -eq $true){
        $cmdArgs.Add('PreferLogonDC',$PreferLogonDC)
    }
    if($PSBoundParameters.ContainsKey('UseFqdn') -eq $true){
        $cmdArgs.Add('UseFqdn',$UseFqdn)
    }
    $objConfig = Set-DfsnServerConfiguration @cmdArgs | Select-Object *

    if($null -ne $SRXEnv){
        $SRXEnv.ResultMessage = $objConfig
    }
    else{
        Write-Output $objConfig
    }
}
catch{
    throw
}
finally{
    if($null -ne $cimSes){
        Remove-CimSession $cimSes
    }
}