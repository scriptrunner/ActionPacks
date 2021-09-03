#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
.SYNOPSIS
    Copies the OS customization specifications

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
    [sr-en] Name of the new OS customization specification
    [sr-de] Name der neuen Spezifikation

.Parameter SourceSpecificationId
    [sr-en] ID of the source OS customization specification
    [sr-de] ID der Quell-Spezifikation

.Parameter SpecificationType
    [sr-en] Type of the new OS customization specifications
    [sr-de] Typ der neuen Spezifikationen
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,    
    [Parameter(Mandatory = $true)]
    [string]$SourceSpecificationId,  
    [Parameter(Mandatory = $true)] 
    [string]$SpecName, 
    [ValidateSet("Persistent","NonPersistent")]
    [string]$SpecificationType
)

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('Name','Type','Server','LastUpdate','DomainAdminUsername','DomainUsername','Description','Domain','FullName','OSType','LicenseMode','LicenseMaxConnections','Id')

    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' =  $Script:vmServer
    }
    $spec = Get-OSCustomizationSpec @cmdArgs -ID $SourceSpecificationId
    
    $cmdArgs.Add('Confirm',$false)
    $cmdArgs.Add('Name', $SpecName)
    $cmdArgs.Add('OSCustomizationSpec',$spec)
    If($PSBoundParameters.ContainsKey('SpecificationType') -eq $true){
        $cmdArgs.Add('Type',$SpecificationType)
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