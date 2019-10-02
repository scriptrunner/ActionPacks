#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Runs a script in the guest OS of the specified virtual machine

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
    Specifies the ID of the virtual machine on whose guest operating system you want to run the script

.Parameter VMName
    Specifies the name of the virtual machine on whose guest operating system you want to run the script

.Parameter GuestCredential
    Specifies a PSCredential object containing the credentials you want to use for authenticating with the virtual machine guest OS

.Parameter ScriptText
    Provides the text of the script you want to run

.Parameter ScriptType
    Specifies the type of the script
    
.Parameter ToolsWaitSecs
    Specifies how long in seconds the system waits for connecting to the VMware Tools
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
    [string]$ScriptText,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [pscredential]$GuestCredential,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Validateset('PowerShell', 'Bat','Bash')]
    [string]$ScriptType = "PowerShell",
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$ToolsWaitSecs = 20
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }    
    if($null -eq $GuestCredential){
        $Script:Output = Invoke-VMScript -VM $Script:machine -Server $Script:vmServer -ScriptText $ScriptText -ScriptType $ScriptType `
                             -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
    }
    else {
        $Script:Output = Invoke-VMScript -VM $Script:machine -Server $Script:vmServer -ScriptText $ScriptText -ScriptType $ScriptType `
                            -GuestCredential $GuestCredential -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
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