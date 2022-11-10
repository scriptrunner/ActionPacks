#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a new host user account using the provided parameters

    .DESCRIPTION

    .NOTESd
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter Id
        [sr-en] ID for the new host account
        [sr-de] Id des Benutzerkontos

    .Parameter Password
        [sr-en] Password for the new host account
        [sr-de] Kennwort

    .Parameter Description
        [sr-en] Description of the new host account
        [sr-de] Beschreibung des Benutzerkontos

    .Parameter GrantShellAccess
        [sr-en] New account is allowed to access the ESX shell 
        [sr-de] ESX shell Benutzerkonto
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Id,
    [Parameter(Mandatory = $true)]
    [securestring]$Password,
    [string]$Description,
    [switch]$GrantShellAccess
)

Import-Module VMware.VimAutomation.Core

try{   
    if([System.String]::IsNullOrWhiteSpace($Description) -eq $true){
        $Description = " "
    } 
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $result = New-VMHostAccount -Server $Script:vmServer -UserAccount -Id $Id -Password $Password `
                    -Description $Description -GrantShellAccess:$GrantShellAccess -Confirm:$false -ErrorAction Stop | Select-Object *
                    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
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