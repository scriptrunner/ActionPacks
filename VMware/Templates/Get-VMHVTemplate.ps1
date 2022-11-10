#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Retrieves the virtual machine templates available on a vCenter Server system

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

    .Parameter TemplateID
        [sr-en] ID of the virtual template
        [sr-de] ID der Vorlage

    .Parameter TemplateName
        [sr-en] Name of the virtual template
        [sr-de] Name der Vorlage

    .Parameter DatastoreName
        [sr-en] Name of the datastore to which the virtual machine templates stored on
        [sr-de] Datastore der neuen Vorlage

    .Parameter NoRecursion
        [sr-en] Disable the recursive behavior of the command
        [sr-de] Rekursives Verhalten deaktivieren
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byDatastore")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byDatastore")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$TemplateID,
    [Parameter(ParameterSetName = "byName")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true,ParameterSetName = "byDatastore")]
    [string]$DatastoreName, 
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [switch]$NoRecursion
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:Output = Get-Template -Server $Script:vmServer -Id $TemplateID -ErrorAction Stop | Select-Object *
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byName"){
        if([System.String]::IsNullOrWhiteSpace($Name) -eq $true){
            $Script:Output = Get-Template -Server $Script:vmServer -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object *
        }
        else{
            $Script:Output = Get-Template -Server $Script:vmServer -Name $TemplateName -ErrorAction Stop | Select-Object *
        }     
    }
    else {
        $Datastore = Get-Datastore -Server $Script:vmServer -Name $DatastoreName -ErrorAction Stop
        $Script:Output = Get-Template -Server $Script:vmServer -Datastore $Datastore -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object *
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
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