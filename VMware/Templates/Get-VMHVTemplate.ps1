#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

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
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Templates

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter TemplateID
    Specifies the ID of the virtual machine template you want to retrieve

.Parameter TemplateName
    Specifies the name of the virtual machine template you want to retrieve, 
    is the parameter empty all virtual machine templates retrieved

.Parameter DatastoreName
    Specifies the name of the datastore to which the virtual machine templates stored on

.Parameter NoRecursion
    Indicates that you want to disable the recursive behavior of the command
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

Import-Module VMware.PowerCLI

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