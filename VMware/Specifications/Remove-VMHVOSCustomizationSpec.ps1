#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
.SYNOPSIS
    Removes the OS customization specifications

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
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$SpecName
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' =  $Script:vmServer
                        }

    $spec = $null                        
    if($PSCmdlet.ParameterSetName -eq 'ById'){
        $spec = Get-OSCustomizationSpec @cmdArgs -ID $ID
    }
    else {
        $spec = Get-OSCustomizationSpec @cmdArgs -Name $SpecName
    }                

    $null = Remove-OSCustomizationSpec @cmdArgs -OSCustomizationSpec $spec -Confirm:$false
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "OS customization specifications successful removed"
    }
    else{
        Write-Output "OS customization specifications successful removed"
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