#Requires -Version 4.0

<#
.SYNOPSIS
    Gets the task definition object of a scheduled task that is registered on the computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/ScheduledTasks

.Parameter TaskName
    Specifies the name of a scheduled task. Use * for all tasks    

.Parameter TaskPath 
    Specifies the path for scheduled task in Task Scheduler namespace. Use * for all paths

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the schedule tasks.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$TaskName = "*",
    [string]$TaskPath = "*",
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$Properties="TaskName,TaskPath,Description,URI,State,Author"
)

$Script:Cim=$null
try{
    if([System.String]::IsNullOrWhiteSpace($TaskName)){
        $TaskName= "*"
    }
    if([System.String]::IsNullOrWhiteSpace($TaskPath)){
        $TaskPath= "*"
    }
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties = '*'
    }
    else{
        if($null -eq ($Properties.Split(',') | Where-Object {$_ -like 'TaskName'})){
            $Properties += ",TaskName"
        }
    }
    [string[]]$Script:props=$Properties.Replace(' ','').Split(',')

    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $Script:Tasks = Get-ScheduledTask -CimSession $Script:Cim -TaskName $TaskName -TaskPath $TaskPath  `
                    | Select-Object $Script:props | Sort-Object TaskName | Format-List
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Tasks 
    }
    else{
        Write-Output $Script:Tasks
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