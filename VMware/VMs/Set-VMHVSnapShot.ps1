#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Modifies the specified virtual machine snapshot

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
    Specifies the ID of the virtual machine you want the snapshot retrieve

.Parameter VMName
    Specifies the name of the virtual machine you want the snapshot retrieve

.Parameter SnapShotName
    Specifies the name of the snapshot

.Parameter NewName
    Provide a new name of the new snapshot

.Parameter NewDescription
    Provide a new description of the new snapshot
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
    [string]$VMId,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$SnapShotName, 
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$NewName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$NewDescription
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @('Name','Created','PowerState','SizeGB','Description','IsCurrent','Id')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }
    $Script:snapshot = Get-Snapshot -Server $Script:vmServer -VM $Script:machine -Name $SnapShotName -ErrorAction Stop
    $Script:Output = $Script:snapshot
    if($PSBoundParameters.ContainsKey('NewName') -eq $true){
        $Script:Output = Set-Snapshot -Snapshot $Script:snapshot -Name $NewName -Confirm:$false `
                        -ErrorAction Stop  | Select-Object $Properties
    }
    if($PSBoundParameters.ContainsKey('NewDescription') -eq $true){
        $Script:Output = Set-Snapshot -Snapshot $Script:snapshot -Description $NewDescription -Confirm:$false `
                        -ErrorAction Stop  | Select-Object $Properties
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