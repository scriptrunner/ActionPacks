#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Retrieves a list of print jobs in the specified printer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/_QUERY_

.Parameter PrinterName
    Specifies the name of the printer from which to retrieve the print job informations

.Parameter Status
    Specifies the status of the jobs from which to retrieve the print job informations

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the print job informations
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [ValidateSet("All", "Normal", "Paused", "Error", "Deleting", "Spooling", "Printing", "Offline", "Paper Out", "Printed", "Deleted", "Blocked", "User Intervention", "Restart", "Complete", "Retained", "Rendering Locally")]
    [string]$Status="All",
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module PrintManagement

$Script:Cim=$null
[string]$Properties="ID,JobStatus,DocumentName,UserName,SubmittedTime"
try{
    [bool]$Script:result
    function CheckStatus([string] $JobStatus){
        $Script:result = $false
        if($Status -eq "All") {
            $Script:result= $true
        }
        [string[]]$splitted = $JobStatus.Split(",")
        foreach($obj in $splitted){
            if($obj.Trim() -eq $Status){
                $Script:result= $true
            }
        }
    }
    if([System.String]::IsNullOrWhiteSpace($Properties) -or $Properties -eq '*'){
        $Properties=@('*')
    }
    else{
        if($null -eq ($Properties.Split(',') | Where-Object {$_ -like 'ID'})){
            $Properties += ",ID"
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
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    $Script:Jobs =Get-PrintJob -CimSession $Script:Cim -PrinterName $PrinterName -ComputerName $ComputerName  `
        | Select-Object $Script:props | Sort-Object ID 
    foreach($item in $Script:Jobs)
    {
        CheckStatus $item.JobStatus
        if($Script:result -eq $false){
            continue
        }
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.ID.toString()
            $SRXEnv.ResultList2 += "$($item.DocumentName) | $($item.UserName) | $($item.SubmittedTime)"
        }
        else{
            Write-Output "$($item.DocumentName) | $($item.UserName) | $($item.SubmittedTime)"
        }
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