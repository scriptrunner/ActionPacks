#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Register a new template

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Templates

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter TemplateName
        [sr-en] Name of the virtual template
        [sr-de] Name der Vorlage

    .Parameter TemplateFilePath
        Specifies the datastore path to the file you want to use to register the new template

    .Parameter FolderName
        Specifies the name of the folder where you want to place the new template

    .Parameter VMHost 
        Specifies the name of the host where you want to create the new template
#>

[CmdLetBinding()]
Param(
    [string]$VIServer,
    [pscredential]$VICredential, 
    [string]$TemplateName,
    [string]$TemplateFilePath,
    [string]$FolderName,    
    [string]$VMHost
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:vmhost = Get-VMHost -Server $Script:vmServer -Name $VMHost -ErrorAction Stop
    $Script:folder = Get-Folder -Name $FolderName -Server $Script:vmServer -ErrorAction Stop
    
    $result = New-Template -Name $TemplateName -TemplateFilePath $TemplateFilePath -Location $Script:folder `
                        -VMHost $Script:vmhost -Confirm:$false -Server $Script:vmServer `
                        -ErrorAction Stop | Select-Object *

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