#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a template by cloning an existing template

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

    .Parameter SourceTemplateID
        [sr-en] ID of a existing template
        [sr-de] Id der Quell-Vorlage

    .Parameter SourceTemplateName
        [sr-en] Name of a existing template
        [sr-de] Name der Quell-Vorlage

    .Parameter DiskStorageFormat
        [sr-en] Disk storage format of the new template
        [sr-de] Festplattenformat der neuen Vorlage

    .Parameter Datastore
        [sr-en] Datastore where you want to store the new template
        [sr-de] Datastore der neuen Vorlage

    .Parameter Datacenter
        [sr-en] Name of the datacenter where you want to place the new template
        [sr-de] Datacenter der neuen Vorlage

    .Parameter VMHost 
        [sr-en] Name of the host where you want to store the new template
        [sr-de] Host der neuen Vorlage
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [pscredential]$VICredential, 
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$SourceTemplateID,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$SourceTemplateName,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$Datastore,    
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$Datacenter,  
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VMHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Thin","Thick","EagerZeroedThick")]
    [string]$DiskStorageFormat = "Thick"
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:source = Get-Template -Server $Script:vmServer -Id $SourceTemplateID -ErrorAction Stop
    }
    else{
        $script:source = Get-Template -Name $SourceTemplateName -Server $Script:vmServer -ErrorAction Stop
    }
    $Script:store = Get-Datastore -Name $Datastore -Server $Script:vmServer -ErrorAction Stop
    $Script:center = Get-Datacenter -Name $Datacenter -Server $Script:vmServer -ErrorAction Stop
    $Script:vmhost = Get-VMHost -Server $Script:vmServer -Name $VMHost -ErrorAction Stop

    $result = New-Template -Name $TemplateName -Template $Script:source -Location $Script:center `
                        -VMHost $Script:vmhost -Datastore $Script:store -Confirm:$false -Server $Script:vmServer `
                        -DiskStorageFormat $DiskStorageFormat -ErrorAction Stop | Select-Object *

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