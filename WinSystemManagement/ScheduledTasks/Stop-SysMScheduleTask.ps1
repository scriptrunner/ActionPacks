#Requires -Version 4.0

<#
.SYNOPSIS
    Stops all running instances of a task

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
    Specifies the name of the computer on which to stop the schedule task
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
[string[]]$Properties = @('TaskName','TaskPath','State','Description','URI','Author')
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
    $task = Get-ScheduledTask -CimSession $Script:Cim -TaskName $TaskName -ErrorAction Stop
    $null = Stop-ScheduledTask -InputObject $task -ErrorAction Stop
    
    $output = Get-ScheduledTask -CimSession $Script:Cim -TaskName $TaskName -ErrorAction Stop | Select-Object $Properties
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