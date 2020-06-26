#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves information about the history tasks

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Tasks

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter MonthsAgo
    Specifies how many months back

.Parameter DaysAgo
    Specifies how many days back
    
.Parameter HoursAgo
    Specifies how many hours back

.Parameter MinutesAgo
    Specifies how many minutes back

.Parameter MaxResult
    Specifies the maximum number of tasks are retrieved

.Parameter Properties
    List of properties to expand, comma separated e.g. Description,Name. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Months ago")]
    [Parameter(Mandatory = $true,ParameterSetName = "Days ago")]
    [Parameter(Mandatory = $true,ParameterSetName = "Hours ago")]
    [Parameter(Mandatory = $true,ParameterSetName = "Minutes ago")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Months ago")]
    [Parameter(Mandatory = $true,ParameterSetName = "Days ago")]
    [Parameter(Mandatory = $true,ParameterSetName = "Hours ago")]
    [Parameter(Mandatory = $true,ParameterSetName = "Minutes ago")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Months ago")]
    [int32]$MonthsAgo,    
    [Parameter(Mandatory = $true,ParameterSetName = "Days ago")]
    [int32]$DaysAgo,    
    [Parameter(Mandatory = $true,ParameterSetName = "Hours ago")]
    [int32]$HoursAgo,
    [Parameter(Mandatory = $true,ParameterSetName = "Minutes ago")]
    [int32]$MinutesAgo,    
    [Parameter(ParameterSetName = "Months ago")]
    [Parameter(ParameterSetName = "Days ago")]
    [Parameter(ParameterSetName = "Hours ago")]
    [Parameter(ParameterSetName = "Minutes ago")]
    [ValidateRange(1,100)]
    [int32]$MaxResult = 20,
    [Parameter(ParameterSetName = "Months ago")]
    [Parameter(ParameterSetName = "Days ago")]
    [Parameter(ParameterSetName = "Hours ago")]
    [Parameter(ParameterSetName = "Minutes ago")]
    [VaildateSet('*','EntityName','Description','State','Cancelled','StartTime','QueueTime','CompleteTime','Name','DescriptionId')]
    [string[]]$Properties = @('EntityName','Description','State','Cancelled','StartTime','QueueTime','CompleteTime','Name','DescriptionId')
)

Import-Module VMware.PowerCLI

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $sView = Get-View ServiceInstance -Server $Script:vmServer
    $taskMgr = Get-View $sView.Content.TaskManager -Server $Script:vmServer

    $Script:tFilter = New-Object VMware.Vim.TaskFilterSpec
    $Script:tFilter.Time = New-Object VMware.Vim.TaskFilterSpecByTime    
    $Script:tFilter.Time.timeType = [vmware.vim.taskfilterspectimeoption]::startedTime

    if($PSCmdlet.ParameterSetName  -eq "Months ago"){
        $Script:tFilter.Time.beginTime = (Get-Date).AddMonths(-$MonthsAgo)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "Days ago"){
        $Script:tFilter.Time.beginTime = (Get-Date).AddDays(-$DaysAgo)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "Hours ago"){
        $Script:tFilter.Time.beginTime = (Get-Date).AddHours(-$HoursAgo)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "Minutes ago"){
        $Script:tFilter.Time.beginTime = (Get-Date).AddMinutes(-$MinutesAgo)
    }
    $Script:tCollector = Get-View ($taskMgr.CreateCollectorForTasks($Script:tFilter))
    $null = $Script:tCollector.RewindCollector
    $result = $Script:tCollector.ReadNextTasks($MaxResult) | Select-Object $Properties | `
                    Sort-Object -Property StartTime -Descending

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
    if($null -ne $Script:tCollector){
        $Script:tCollector.DestroyCollector()
    }
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}