#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Generates a report with the properties of all virtual machines from the Hyper-V host
    
    .DESCRIPTION  
        Supports the execution on Windows Server 2016 / Windows 10 or newer

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Hyper-V
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/_REPORTS_

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter VMState
        Specifies the state of the virtual machines
#>

param(
    [string]$HostName,
    [PSCredential]$AccessAccount,
    [ValidateSet('All', 'Running', 'Off', 'Stopping', 'Saved', 'Paused', 'Starting', 'Reset', 'Saving', 'Pausing', 'Resuming',
        'FastSaved', 'FastSaving', 'RunningCritical', 'OffCritical', 'StoppingCritical', 'SavedCritical', 'PausedCritical',
        'StartingCritical', 'ResetCritical', 'SavingCritical', 'PausingCritical', 'ResumingCritical', 'FastSavedCritical',
        'FastSavingCritical', 'Other')]
    [string]$VMState ="All"
)

Import-Module Hyper-V

try {
    $Script:output
    [string[]]$Properties = @('VMName','VMID','State','PrimaryOperationalStatus','PrimaryStatusDescription','CPUUsage','MemoryDemand','SizeOfSystemFiles')
    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }      
    
    if($null -eq $AccessAccount){
        if($VMState -eq 'All'){
            $Script:output = Get-VM -ComputerName $HostName -ErrorAction Stop | Select-Object $Properties
        }
        else {
            $Script:output = Get-VM -ComputerName $HostName -ErrorAction Stop | Where-Object {$_.State -eq $VMState} `
                | Select-Object $Properties
        }
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        if($VMState -eq 'All'){
            $Script:output = Get-VM -CimSession $Script:Cim -ErrorAction Stop | Select-Object $Properties
        }
        else {
            $Script:output = Get-VM -CimSession $Script:Cim -ErrorAction Stop | Where-Object {$_.State -eq $VMState} `
                | Select-Object $Properties
        }
    }   
    
    ConvertTo-ResultHtml -Result $Script:output
}
catch {
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}