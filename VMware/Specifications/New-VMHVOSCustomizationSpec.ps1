#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
.SYNOPSIS
    Creates a new OS customization specifications

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.VimAutomation.Core

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Specifications

.Parameter VIServer
    [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
    [sr-de] IP Adresse oder Name des vSphere Servers

.Parameter VICredential
    [sr-en] PSCredential object that contains credentials for authenticating with the server
    [sr-de] Benutzerkonto um diese Aktion durchzuführen

.Parameter SpecName
    [sr-en] Name for new the OS customization specification
    [sr-de] Name der neuen Spezifikation

.Parameter AdminPassword
    [sr-en] The new OS administrator's password
    [sr-de] Neues Administrator Kennwort

.Parameter AutoLogonCount
    [sr-en] Number of times the virtual machine should automatically login as an administrator
    [sr-de] Anzahl wie oft sich die virtuelle Maschine automatisch als Administrator anmelden soll

.Parameter DeleteAccounts
    [sr-en] Delete all user accounts
    [sr-de] Alle Benutzerkonten löschen

.Parameter Description
    [sr-en] New description for the specification
    [sr-de] Neue Beschreibung der Spezifikation

.Parameter DNSServer
    [sr-en] DNS server
    [sr-de] DNS Server

.Parameter Domain
    [sr-en] Domain name
    [sr-de] Domänenname

.Parameter DomainCredentials
    [sr-en] Credential for authentication with the specified domain
    [sr-de] Benutzerkonto für die Authentifizierung mit der angegebenen Domäne

.Parameter DomainUsername
    [sr-en] Username for authentication with the specified domain
    [sr-de] Benutzername für die Authentifizierung mit der angegebenen Domäne

.Parameter DomainPassword
    [sr-en] Password for authentication with the specified domain
    [sr-de] Kennwort für die Authentifizierung mit der angegebenen Domäne

.Parameter AdminFullName
    [sr-en] Administrator's full name
    [sr-de] Voller Name des Administrators

.Parameter NamingScheme
    [sr-en] Naming scheme for the virtual machine
    [sr-de] Namensschema der VM

.Parameter OrgName
    [sr-en] Name of the organization to which the administrator belongs
    [sr-de] Name der Organisation, zu der der Administrator gehört

.Parameter ProductKey
    [sr-en] MS product key
    [sr-de] MS Produkt-Schlüssel

.Parameter SpecificationType
    [sr-en] Type of the OS customization specifications
    [sr-de] Typ der Spezifikationen

.Parameter TimeZone
    [sr-en] Name of the time zone for a Windows guest OS
    [sr-de] name der Zeitzone für das Windows OS

.Parameter Workgroup
    [sr-en] Workgroup, applies only to Windows operating systems
    [sr-de] Workgroup, betrifft nur für Windows-Betriebssysteme
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,    
    [Parameter(Mandatory = $true)]
    [string]$SpecName,
    [Parameter(Mandatory = $true)]
    [string]$AdminFullName,
    [Parameter(Mandatory = $true)]
    [string]$OrgName,
    [string]$Description,
    [bool]$DeleteAccounts,
    [int]$AutoLogonCount,
    [string]$DNSServer,
    [string]$AdminPassword,
    [ValidateSet("Custom","Fixed","Prefix","Vm")]
    [string]$NamingScheme,
    [string]$ProductKey, 
    [ValidateSet("Persistent","NonPersistent")]
    [string]$SpecificationType,
    [string]$Domain,
    [pscredential]$DomainCredentials,
    [string]$DomainUsername,
    [string]$DomainPassword,
    [ValidateSet('W. Europe','E. Europe','Central Europe','Central European','Central (U.S. and Canada)','Central America','Eastern (U.S. and Canada)','GMT (Greenwich Mean Time)','GMT Greenwich','EET (Athens, Istanbul, Minsk)','EET (Helsinki, Riga, Tallinn)')]
    [string]$TimeZone,
    [string]$Workgroup
)

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('Name','Type','Server','LastUpdate','DomainAdminUsername','DomainUsername','Description','Domain','FullName','OSType','LicenseMode','LicenseMaxConnections','Id')
    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' =  $Script:vmServer 
                            'Confirm' = $false
                            'FullName' = $AdminFullName
                            'OrgName' = $OrgName
    }
    If($PSBoundParameters.ContainsKey('SpecName') -eq $true){
        $cmdArgs.Add('Name',$SpecName)
    } 
    If($PSBoundParameters.ContainsKey('AutoLogonCount') -eq $true){
        $cmdArgs.Add('AutoLogonCount',$AutoLogonCount)
    } 
    If($PSBoundParameters.ContainsKey('AdminPassword') -eq $true){
        $cmdArgs.Add('AdminPassword',$AdminPassword)
    }  
    If($PSBoundParameters.ContainsKey('DeleteAccounts') -eq $true){
        $cmdArgs.Add('DeleteAccounts',$DeleteAccounts)
    } 
    If($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    If($PSBoundParameters.ContainsKey('DNSServer') -eq $true){
        $cmdArgs.Add('DNSServer',$DNSServer)
    }
    If($PSBoundParameters.ContainsKey('Domain') -eq $true){
        $cmdArgs.Add('Domain',$Domain)
    }
    If($PSBoundParameters.ContainsKey('DomainUsername') -eq $true){
        $cmdArgs.Add('DomainUsername',$DomainUsername)
    }
    If($PSBoundParameters.ContainsKey('DomainPassword') -eq $true){
        $cmdArgs.Add('DomainPassword',$DomainPassword)
    }
    If($PSBoundParameters.ContainsKey('DomainCredentials') -eq $true){
        $cmdArgs.Add('DomainCredentials',$DomainCredentials)
    }
    If($PSBoundParameters.ContainsKey('NamingScheme') -eq $true){
        $cmdArgs.Add('NamingScheme',$NamingScheme)
    }
    If($PSBoundParameters.ContainsKey('ProductKey') -eq $true){
        $cmdArgs.Add('ProductKey',$ProductKey)
    }
    If($PSBoundParameters.ContainsKey('TimeZone') -eq $true){
        $cmdArgs.Add('TimeZone',$TimeZone)
    }
    If($PSBoundParameters.ContainsKey('SpecificationType') -eq $true){
        $cmdArgs.Add('Type',$SpecificationType)
    }
    If($PSBoundParameters.ContainsKey('Workgroup') -eq $true){
        $cmdArgs.Add('Workgroup',$Workgroup)
    }

    $output = New-OSCustomizationSpec @cmdArgs | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output 
    }
    else{
        Write-Output $output
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}