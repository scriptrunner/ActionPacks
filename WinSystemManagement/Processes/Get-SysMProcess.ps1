#Requires -Version 4.0

<#
.SYNOPSIS
    Gets one or all processes that are running on the local computer or a remote computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Processes

.Parameter ComputerName
    Gets the active processes on the specified computer. The default is the local computer

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action

.Parameter ProcessID
    Specifies the process by process ID (PID)

.Parameter ProcessName
    Specifies the process by process name

.Parameter FileVersionInfo
    Indicates that this cmdlet gets the file version information for the program that runs in the process.

.Parameter IncludeUserName
    Indicates that the UserName value of the Process object is returned with results of the command

.Parameter Module
    Indicates that this cmdlet gets the modules that have been loaded by the processes
    
.Parameter Properties
    List of properties to expand, comma separated e.g. Name,ID. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName ="ById")]
    [int32]$ProcessID,
    [Parameter(Mandatory = $true, ParameterSetName ="ByName")]
    [string]$ProcessName,
    [Parameter(ParameterSetName ="All")]
    [Parameter(ParameterSetName ="ById")]
    [Parameter(ParameterSetName ="ByName")]
    [string]$ComputerName,
    [Parameter(ParameterSetName ="All")]
    [Parameter(ParameterSetName ="ById")]
    [Parameter(ParameterSetName ="ByName")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName ="All")]
    [Parameter(ParameterSetName ="ById")]
    [Parameter(ParameterSetName ="ByName")]
    [switch]$IncludeUserName ,
    [Parameter(ParameterSetName ="All")]
    [Parameter(ParameterSetName ="ById")]
    [Parameter(ParameterSetName ="ByName")]
    [switch]$FileVersionInfo ,
    [Parameter(ParameterSetName ="All")]
    [Parameter(ParameterSetName ="ById")]
    [Parameter(ParameterSetName ="ByName")]
    [switch]$Module ,
    [Parameter(ParameterSetName ="All")]
    [Parameter(ParameterSetName ="ById")]
    [Parameter(ParameterSetName ="ByName")]
    [ValidateSet('*','Name','ID','FileVersion','UserName','PagedMemorySize','PrivateMemorySize','VirtualMemorySize','TotalProcessorTime','Path','CPU','StartTime')]
    [string[]]$Properties = @('Name','ID','FileVersion','UserName','PagedMemorySize','PrivateMemorySize','VirtualMemorySize','TotalProcessorTime','Path','CPU','StartTime')
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ProcessName) -eq $true){
        $ProcessName = '*'
    }
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    else{
        if($null -eq ($Properties | Where-Object {$_ -like 'Name'})){
            $Properties += "Name"
        }
    }

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            if($IncludeUserName -eq $true){
                if($ProcessID -le 0){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ 
                        Get-Process -Name $Using:ProcessName -IncludeUserName | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ 
                        Get-Process -ID $Using:ProcessID -IncludeUserName | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
            }
            elseif($FileVersionInfo -eq $true){
                if($ProcessID -le 0){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ 
                        Get-Process -Name $Using:ProcessName -FileVersionInfo | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ 
                        Get-Process -ID $Using:ProcessID -FileVersionInfo | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
            }
            elseif($Module -eq $true){
                if($ProcessID -le 0){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ 
                        Get-Process -Name $Using:ProcessName -Module | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ 
                        Get-Process -ID $Using:ProcessID -Module | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
            }
            else{
                if($ProcessID -le 0){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ 
                        Get-Process -Name $Using:ProcessName | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ 
                        Get-Process -ID $Using:ProcessID | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
            }
        }
        else {
            if($IncludeUserName -eq $true){
                if($ProcessID -le 0){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ 
                        Get-Process -Name $Using:ProcessName -IncludeUserName | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ 
                        Get-Process -ID $Using:ProcessID -IncludeUserName | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
            }
            elseif($FileVersionInfo -eq $true){
                if($ProcessID -le 0){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ 
                        Get-Process -Name $Using:ProcessName -FileVersionInfo | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ 
                        Get-Process -ID $Using:ProcessID -FileVersionInfo | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
            }
            elseif($Module -eq $true){
                if($ProcessID -le 0){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ 
                        Get-Process -Name $Using:ProcessName -Module | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ 
                        Get-Process -ID $Using:ProcessID -Module | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
            }
            else{
                if($ProcessID -le 0){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ 
                        Get-Process -Name $Using:ProcessName | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ 
                        Get-Process -ID $Using:ProcessID | Select-Object $Using:Properties 
                    } -ErrorAction Stop
                }
            }
        }
    }
    else {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
        if($ProcessID -le 0){
            $cmdArgs.Add('Name', $ProcessName)
        }
        else {
            $cmdArgs.Add('ID', $ProcessID)
        }
        if($IncludeUserName -eq $true){
            $cmdArgs.Add('IncludeUserName',$null)            
        }
        elseif($FileVersionInfo -eq $true){
            $cmdArgs.Add('FileVersionInfo',$null)
        }
        elseif($Module -eq $true){
            $cmdArgs.Add('Module',$null)
        }
        $Script:output = Get-Process @cmdArgs | Select-Object $Properties
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}