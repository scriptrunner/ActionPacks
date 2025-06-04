#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Create a Active Directory computer
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module ActiveDirectory

    .Parameter OUPath
        [sr-en] Active Directory path
        [sr-de] Active Directory Pfad

    .Parameter Computername
        [sr-en] Name of the Active Directory computer
        [sr-de] Name des Computers

    .Parameter Description
        [sr-en] Description of the computer
        [sr-de] Beschreibung des Computers

    .Parameter DisplayName
        [sr-en] Display name of the computer
        [sr-de] Anzeigename des Computers

    .Parameter DNSHostName
        [sr-en] Fully qualified domain name (FQDN) of the computer
        [sr-de] FQDN des Computers

    .Parameter Homepage
        [sr-en] URL of the home page of the computer
        [sr-de] Homepage-URL des Computers

    .Parameter ManagedBy
        [sr-en] User or group that manages the computer
        [sr-de] Benutzer oder Gruppe der den Computer verwaltet

    .Parameter OperationSystem
        [sr-en] Operating system name of the computer
        [sr-de] Betiebssystem des Computers

    .Parameter Enabled
        [sr-en] Computer is enabled
        [sr-de] Computer aktivieren
    
    .Parameter DomainAccount
        [sr-en] Active Directory Credential for remote execution on jumphost without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP        

    .Parameter DomainName
        [sr-en] Name of Active Directory Domain
        [sr-de] Name der Active Directory Domäne
    
    .Parameter AuthType
        [sr-en] Specifies the authentication method to use
        [sr-de] Gibt die zu verwendende Authentifizierungsmethode an
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,  
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Computername,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Description,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DisplayName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DNSHostname,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [bool]$Enabled,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Homepage,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$OperationSystem,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$ManagedBy,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType = "Negotiate" 
)

Import-Module ActiveDirectory

try{  
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AuthType' = $AuthType
                            }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $cmdArgs.Add("Current", 'LocalComputer')
    }
    else {
        $cmdArgs.Add("Identity", $DomainName)
    }
    $Domain = Get-ADDomain @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'AuthType' = $AuthType
                'Name' = $Computername
                'Server' = $Domain.PDCEmulator
                'Path' = $OUPath
                'Confirm' = $false
                'PassThru' = $null
    }    
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    } 
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add("Description", $Description)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add("Enabled", $Enabled)
    }
    if($PSBoundParameters.ContainsKey('DisplayName') -eq $true){
        $cmdArgs.Add("DisplayName", $DisplayName)
    }
    if($PSBoundParameters.ContainsKey('DNSHostname') -eq $true){
        $cmdArgs.Add("DNSHostname", $DNSHostname)
    }
    if($PSBoundParameters.ContainsKey('Homepage') -eq $true){
        $cmdArgs.Add("Homepage", $Homepage)
    }
    if($PSBoundParameters.ContainsKey('OperationSystem') -eq $true){
        $cmdArgs.Add("OperationSystem", $OperationSystem)
    }
    if($PSBoundParameters.ContainsKey('ManagedBy') -eq $true){
        $cmdArgs.Add("ManagedBy", $ManagedBy)
    }

    $cmp = New-ADComputer @cmdArgs
    Write-Output $cmp
}
catch{
    throw
}
finally{
}