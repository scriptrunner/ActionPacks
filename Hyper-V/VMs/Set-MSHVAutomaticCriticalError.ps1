#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Sets the action to take when the virtual machine encounters a critical error
    
    .DESCRIPTION
        Can only executed on Windows Server 2016 / Windows 10 or newer  

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
    
    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter VMName
        Specifies the virtual machine to be configured

    .Parameter Action
        Specifies the action to take when the VM encounters a critical error, and exceeds the timeout duration

    .Parameter TimeOut
        Specifies the amount of time, in minutes, to wait in critical pause before powering off the virtual machine
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [string]$HostName,
    [PSCredential]$AccessAccount,
    [ValidateSet('None','Pause')]
    [string]$Action="None",
    [int]$TimeOut
)

Import-Module Hyper-V

try {
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
        Set-VM -VM $Script:VM -AutomaticCriticalErrorAction $Action -AutomaticCriticalErrorActionTimeout $Timeout -ErrorAction Stop
        [string[]]$Properties = @('AutomaticCriticalErrorAction','AutomaticCriticalErrorActionTimeout','VMName','VMID','State','PrimaryOperationalStatus','PrimaryStatusDescription','CPUUsage','MemoryDemand','SizeOfSystemFiles','IntegrationServicesVersion')
        if($null -eq $AccessAccount){
            $Script:output = Get-VM -ComputerName $HostName -Name $Script:VM.VMName | Select-Object $Properties
        }
        else {
            $Script:output = Get-VM -CimSession $Script:Cim -Name $Script:VM.VMName | Select-Object $Properties
        } 
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:output
        }    
        else {
            Write-Output $Script:output
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