#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the available resource pools

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/ResourcePool

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter ID
    Specifies the ID of the resource pool you want to retrieve

.Parameter Name
    Specifies the name of the resource pool you want to retrieve, is the parameter empty all hosts retrieved

.Parameter VM
    Specifies the virtual machine whose resource pool you want to retrieve

.Parameter NoRecursion
    Indicates that you want to disable the recursive behavior

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Id. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$ID,
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [string]$VM,
    [Parameter(ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byVM")]
    [switch]$NoRecursion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byVM")]
    [ValidateSet('*','Name','Id','MemReservationGB','MemLimitGB','CpuLimitMHz','CpuReservationMHz')]
    [string[]]$Properties = @('Name','Id','MemReservationGB','MemLimitGB','CpuLimitMHz','CpuReservationMHz')
)

Import-Module VMware.PowerCLI

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'NoRecursion' = $NoRecursion
                            }                            

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $cmdArgs.Add('ID',$ID)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byName"){
        if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
            $cmdArgs.Add('Name',$Name)
        }        
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byVM"){
        $cmdArgs.Add('VM',$VM)
    }
    $result = Get-ResourcePool @cmdArgs | Select-Object $Properties

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