#Requires -Version 4.0

<#
.SYNOPSIS
    Modifies a scheduled task

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/ScheduledTasks

.Parameter TaskName
    Specifies the name of a scheduled task

.Parameter ComputerName
    Specifies the name of the computer on which to modify the schedule task
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
    
.Parameter AllowDemandStart
    Specifies the task can be started by using either the Run command or the Context menu
    
.Parameter AllowHardTerminate
    Specifies that the task can be terminated by using TerminateProcess
    
.Parameter StartWhenAvailable
    Indicates that Task Scheduler can start the task at any time after its scheduled time has passed
    
.Parameter RestartInterval
    Specifies the amount of time that Task Scheduler attempts to restart the task
    
.Parameter RestartCount
    Specifies the number of times that Task Scheduler attempts to restart the task
    
.Parameter ExecutionTimeLimit
    Specifies the amount of time that Task Scheduler is allowed to complete the task

.Parameter MultipleInstancesRule
    Specifies the policy that defines how Task Scheduler handles multiple instances of the task
    
.Parameter Compatibility
    Indicates which version of Task Scheduler with which a task is compatible
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Win Server 2012 R2, Win Server 2016','Win Vista, Win Server 2008','Win 7, Win Server 2008 R2')]
    [string]$Compatibility = "Win Server 2012 R2, Win Server 2016",
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [bool]$AllowDemandStart,
    [int]$RestartCount,
    [bool]$AllowHardTerminate,
    [bool]$StartWhenAvailable,
    [ValidateSet("1 Minute","5 Minutes","10 Minutes","15 Minutes","30 Minutes","1 Hour","2 Hours")]
    [string]$RestartInterval,
    [ValidateSet("1 Hour","2 Hours","4 Hours","8 Hours","12 Hours","1 Day","3 Days")]
    [string]$ExecutionTimeLimit,
    [ValidateSet("Do not start a new instance","Run a new instance in parallel","Queue a new instance")]
    [string]$MultipleInstancesRule
)

$Script:Cim=$null
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $Script:task = Get-ScheduledTask -CimSession $Script:Cim -TaskName $TaskName -ErrorAction Stop
    $Script:setts = $Script:task | Select-Object -ExpandProperty Settings
    if($PSBoundParameters.ContainsKey("AllowDemandStart") -eq $true){
        $Script:setts.AllowDemandStart = $AllowDemandStart
    }
    if($PSBoundParameters.ContainsKey("AllowHardTerminate") -eq $true){
        $Script:setts.AllowHardTerminate = $AllowHardTerminate
    }
    if($PSBoundParameters.ContainsKey("StartWhenAvailable") -eq $true){
        $Script:setts.StartWhenAvailable = $StartWhenAvailable
    }
    if($PSBoundParameters.ContainsKey("RestartCount") -eq $true){
        $Script:setts.RestartCount = $RestartCount
    }
    switch ($MultipleInstancesRule){
        "Do not start a new instance"{
            $Script:setts.MultipleInstances = "IgnoreNew"
        }
        "Run a new instance in parallel"{
            $Script:setts.MultipleInstances = "Parallel"
        }
        "Queue a new instance"{
            $Script:setts.MultipleInstances = "Queue"
        }
    }
    
    switch ($ExecutionTimeLimit){
        "1 Hour"{
            $Script:setts.ExecutionTimeLimit = "PT1H"
        }
        "2 Hours"{
            $Script:setts.ExecutionTimeLimit = "PT2H"
        }
        "4 Hours"{
            $Script:setts.ExecutionTimeLimit = "PT4H"
        }
        "8 Hours"{
            $Script:setts.ExecutionTimeLimit = "PT8H"
        }
        "12 Hours"{
            $Script:setts.ExecutionTimeLimit = "PT12H"
        }
        "1 Day"{
            $Script:setts.ExecutionTimeLimit = "P1D"
        }
        "3 Days"{
            $Script:setts.ExecutionTimeLimit = "P3D"
        }
    }
    switch ($RestartInterval){
        "1 Minute"{
            $Script:setts.RestartInterval = "PT1M"
        }
        "5 Minutes"{
            $Script:setts.RestartInterval = "PT5M"
        }
        "10 Minutes"{
            $Script:setts.RestartInterval = "PT10M"
        }
        "15 Minutes"{
            $Script:setts.RestartInterval = "PT15M"
        }
        "30 Minutes"{
            $Script:setts.RestartInterval = "PT30M"
        }
        "1 Hour"{
            $Script:setts.RestartInterval = "PT1H"
        }
        "2 Hours"{
            $Script:setts.RestartInterval = "PT1H"
        }
    }
    switch ($Compatibility){
        "Win Server 2012 R2, Win Server 2016"{
            $Script:setts.Compatibility = "Win8"
        }
        "Win Vista, Win Server 2008"{
            $Script:setts.Compatibility = "Vista"
        }
        "Win 7, Win Server 2008 R2"{
            $Script:setts.Compatibility = "Win7"
        }
    }    
    $null = Set-ScheduledTask -CimSession $Script:Cim -TaskName $Script:task.TaskName -TaskPath $Script:task.TaskPath -Settings $Script:setts -ErrorAction Stop
    
    $Script:task = Get-ScheduledTask -CimSession $Script:Cim -TaskName $Script:task.TaskName -TaskPath $Script:task.TaskPath -ErrorAction Stop
    $output = $Script:task | Select-Object -ExpandProperty Settings
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output
    }
    else{
        Write-Output $output
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}