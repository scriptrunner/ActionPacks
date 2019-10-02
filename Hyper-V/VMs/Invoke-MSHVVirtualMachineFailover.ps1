#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Invokes a failover command for the virtual machine from the Hyper-V host.
        The acceptable commands are: Start, Stop, Complete
    
    .DESCRIPTION  
        Use "Win2K12R2 or Win8.x" for execution on Windows Server 2012 R2 or on Windows 8.1,
        when execute on Windows Server 2016 / Windows 10 or newer, use "Newer Systems"

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Hyper-V

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/VMs

    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter VMName
        Specifies the name or identifier of the virtual machine to be retrieved

    .Parameter Command
        Specifies the command that executed on the virtual machine 

    .Parameter RecoverySnapshot
        Specifies the recovery snapshot to use during a failover

    .Parameter TestIt
        Creates a test virtual machine using the chosen recovery point. You can use a test virtual machine to validate a Replica virtual machine

    .Parameter Prepare
        Starts the planned failover on the primary virtual machine and replicates any pending changes
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [ValidateSet('Start','Stop','Complete')]
    [string]$Command,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$RecoverySnapshot,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$TestIt,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$Prepare
)

Import-Module Hyper-V

try {
    $Script:output
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    if($null -eq $AccessAccount){
        $Script:VM = Get-VM -ComputerName $HostName -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $Script:VM = Get-VM -CimSession $Script:Cim -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }        
    if($null -ne $Script:VM){
        if($Command -eq 'Start'){
            if($TestIt -eq $true){
                Start-VMFailover -VM $Script:VM -AsTest -ErrorAction Stop
            }
            elseif($Prepare -eq $true){
                Start-VMFailover -VM $Script:VM -Prepare -ErrorAction Stop
            }
            elseif(-not [System.String]::IsNullOrWhiteSpace($RecoverySnapshot)) {
                Get-VMSnapshot $Script:VM -Name $RecoverySnapshot  -ErrorAction Stop | Start-VMFailover  -ErrorAction Stop
            }
            else {
                Start-VMFailover -VM $Script:VM -ErrorAction Stop          
            }
        }
        elseif($Command -eq 'Stop'){
            Stop-VMFailover -VM $Script:VM -ErrorAction Stop
        }
        elseif($Command -eq 'Complete'){
            Complete-VMFailover -VM $Script:VM -ErrorAction Stop
        } 
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Virtual machine $($VMName) not found"
        }    
        Throw "Virtual machine $($VMName) not found"
    }
}
catch {
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}