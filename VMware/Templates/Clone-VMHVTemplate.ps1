#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

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
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Templates

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter TemplateName
    Specifies the name of the new template

.Parameter SourceTemplateID
    Specifies the ID of a existing template

.Parameter SourceTemplateName
    Specifies the name of a existing template

.Parameter DiskStorageFormat
    Specifies the disk storage format of the new template

.Parameter Datastore
    Specifies the datastore where you want to store the new template

.Parameter Datacenter
    Specifies the name of the datacenter where you want to place the new template

.Parameter VMHost 
    Specifies the name of the host where you want to store the new template
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

Import-Module VMware.PowerCLI

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