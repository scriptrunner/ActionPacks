#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
.SYNOPSIS
    Retrieves the OS customization specifications available on a vCenter Server system

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
    [sr-en] Name of the OS customization specification
    [sr-de] Name der Spezifikation

.Parameter ID
    [sr-en] ID of the OS customization specification
    [sr-de] ID der Spezifikation

.Parameter SpecificationType
    [sr-en] Type of the OS customization specifications
    [sr-de] Typ der Spezifikationen

.Parameter Properties
    [sr-en] List of properties to expand. Use * for all properties
    [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [pscredential]$VICredential,    
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$ID,   
    [Parameter(ParameterSetName = 'ByName')]
    [string]$SpecName, 
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'ById')]
    [ValidateSet("Persistent","NonPersistent")]
    [string]$SpecificationType,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'ById')]
    [ValidateSet('*','Name','Type','Server','LastUpdate','DomainAdminUsername','DomainUsername','Description','AutoLogonCount','ChangeSid','DeleteAccounts','DnsServer','DnsSuffix','Domain','FullName','NamingScheme','OrgName','OSType','ProductKey','TimeZone','Workgroup','LicenseMode','LicenseMaxConnections','Id','Uid')]
    [string[]]$Properties = @('Name','Type','Server','LastUpdate','DomainAdminUsername','DomainUsername','Description','Domain','FullName','OSType','LicenseMode','LicenseMaxConnections','Id')
)

Import-Module VMware.VimAutomation.Core

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' =  $Script:vmServer
    }

    if($PSCmdlet.ParameterSetName -eq 'ById'){
        $cmdArgs.Add('Id',$ID)
    }
    else {
        If($PSBoundParameters.ContainsKey('SpecName') -eq $true){
            $cmdArgs.Add('Name',$SpecName)
        }
    }
    If($PSBoundParameters.ContainsKey('SpecificationType') -eq $true){
        $cmdArgs.Add('Type',$SpecificationType)
    }

    $output = Get-OSCustomizationSpec @cmdArgs | Select-Object $Properties
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