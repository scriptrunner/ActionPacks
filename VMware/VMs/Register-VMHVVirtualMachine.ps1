#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Register a new virtual machine

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

.Parameter VMFilePath
    Specifies a path to the virtual machine you want to register

.Parameter HostName
    Specifies the name of the host on which you want to create the new virtual machine

.Parameter VMName
    Specifies a name for the new virtual machine

.Parameter NameOfVM
    Specifies a name for the new virtual machine

.Parameter ClusterName
    Specifies the datastore cluster where you want to place the new virtual machine

.Parameter Notes
    Provides a description of the new virtual machine

.Parameter Location
    Specifies the folder where you want to place the new virtual machine
    
.Parameter DrsAutomationLevel
    Specifies a DRS (Distributed Resource Scheduler) automation level

.Parameter HAIsolationResponse
    Indicates whether the virtual machine should be powered off if a host determines that it is isolated from the rest of the compute resource

.Parameter HARestartPriority
    Specifies the virtual machine HA restart priority
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Default")]
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Default")]
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [pscredential]$VICredential,    
    [Parameter(Mandatory = $true,ParameterSetName = "Default")]
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [string]$HostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Default")]
    [string]$VMName,        
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [string]$NameOfVM,
    [Parameter(Mandatory = $true,ParameterSetName = "Default")]
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]    
    [string]$VMFilePath,  
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [string]$ClusterName, 
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "onCluster")]
    [string]$Notes,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "onCluster")]
    [string]$Location,
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("FullyAutomated", "Manual", "PartiallyAutomated", "AsSpecifiedByCluster","Disabled")]
    [string]$DrsAutomationLevel,
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("AsSpecifiedByCluster", "PowerOff", "DoNothing")]
    [string]$HAIsolationResponse,
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("Disabled", "Low", "Medium", "High", "ClusterRestartPriority")]
    [string]$HARestartPriority
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @('Name','Id','NumCpu','CoresPerSocket','Notes','GuestId','MemoryGB','VMSwapfilePolicy','ProvisionedSpaceGB','Folder')
    if([System.String]::IsNullOrWhiteSpace($Notes) -eq $true){
        $Notes = " "
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'Name' = $VMName 
                            'VMHost' = $Script:vmHost 
                            'Notes' = $Notes 
                            'Confirm' =$false
                            'VMFilePath' = $VMFilePath
                        }

    if($PSCmdlet.ParameterSetName  -eq "onCluster"){
        $Script:store = Get-Cluster -Server $Script:vmServer -Name $ClusterName -ErrorAction Stop
        $cmdArgs['Name'] = $NameOfVM
        $cmdArgs.Add('ResourcePool', $Script:store)
    }
    if([System.String]::IsNullOrEmpty($Location) -eq $false){
        $folder = Get-Folder -Server $Script:vmServer -Name $Location -ErrorAction Stop
        $cmdArgs.Add('Location' ,$Folder)
    }
    $Script:machine = New-VM @cmdArgs
    
    if($PSCmdlet.ParameterSetName  -eq "onCluster"){
        if($PSBoundParameters.ContainsKey('DrsAutomationLevel') -eq $true){
            $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -DrsAutomationLevel $DrsAutomationLevel -Confirm:$False -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('HAIsolationResponse') -eq $true){
            $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -HAIsolationResponse $HAIsolationResponse -Confirm:$False -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('HARestartPriority') -eq $true){
            $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -HARestartPriority $HARestartPriority -Confirm:$False -ErrorAction Stop
        }
    }
    $result = Get-VM -Server $Script:vmServer -Name $VMName | Select-Object $Properties

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