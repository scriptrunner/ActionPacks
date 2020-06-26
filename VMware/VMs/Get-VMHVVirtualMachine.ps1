#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the virtual machines on a vCenter Server system

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VMs

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VMId
    Specifies the ID of the virtual machine you want to retrieve

.Parameter VMName
    Specifies the name of the virtual machine you want to retrieve, is the parameter empty all virtual machines retrieved

.Parameter Datastore
    Specifies the datastore or datastore cluster to which the virtual machine that you want to retrieve are associated

.Parameter NoRecursion
    Indicates that you want to disable the recursive behavior

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,PowerState. Use * for all properties
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
    [string]$VMId,
    [Parameter(Mandatory = $true,ParameterSetName = "byDatastore")]
    [string]$Datastore,    
    [Parameter(ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [switch]$NoRecursion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [ValidateSet('*','Name','Id','PowerState','NumCpu','Notes','Guest','GuestId','MemoryMB','UsedSpaceGB','ProvisionedSpaceGB','Folder')]
    [string[]]$Properties = @('Name','Id','PowerState','NumCpu','Notes','Guest','GuestId','MemoryMB','UsedSpaceGB','ProvisionedSpaceGB','Folder')
)

Import-Module VMware.PowerCLI

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'NoRecursion' = $NoRecursion}

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $cmdArgs.Add('Id',$VMId)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byName"){
        $cmdArgs.Add('Name',$VMName)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byDatastore"){
        $cmdArgs.Add('Datastore',$Datastore)
    }
    $result = Get-VM @cmdArgs | Select-Object $Properties

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