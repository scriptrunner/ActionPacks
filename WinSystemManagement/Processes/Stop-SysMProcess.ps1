#Requires -Version 4.0

<#
.SYNOPSIS
    Stops an running process

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
    Computer on which the process is running. The default is the local computer

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action

.Parameter ProcessID
    Specifies the process by process ID (PID)

.Parameter ProcessName
    Specifies the process by process name
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName ="ById")]
    [int32]$ProcessID,
    [Parameter(Mandatory = $true, ParameterSetName ="ByName")]
    [string]$ProcessName,
    [Parameter(ParameterSetName ="ById")]
    [Parameter(ParameterSetName ="ByName")]
    [string]$ComputerName,
    [Parameter(ParameterSetName ="ById")]
    [Parameter(ParameterSetName ="ByName")]
    [PSCredential]$AccessAccount
)

try{
    $Script:process
    if([System.String]::IsNullOrWhiteSpace($ProcessName) -eq $true){
        $ProcessName = '*'
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){            
            if($ProcessID -le 0){
                $Script:process = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ Get-Process -Name $Using:ProcessName } -ErrorAction Stop
                if($null -ne $Script:process){
                    $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ Stop-Process -Name $Using:ProcessName -Confirm:$false -Force -ErrorAction Stop }
                    $Script:output = "Process $($ProcessName) stopped"
                }
                else {                
                    throw "Process $($ProcessName) not found"
                }
            }
            else {
                $Script:process = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ Get-Process -ID $Using:ProcessID } -ErrorAction Stop 
                if($null -ne $Script:process){
                    $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ Stop-Process -ID $Using:ProcessID -Confirm:$false -Force -ErrorAction Stop }
                    $Script:output = "Process $($ProcessID) stopped"
                }
                else {                
                    throw "Process $($ProcessID) not found"
                }
            }
        }
        else {            
            if($ProcessID -le 0){
                $Script:process = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ Get-Process -Name $Using:ProcessName  } -ErrorAction Stop
                if($null -ne $Script:process){
                    $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ Stop-Process -Name $Using:ProcessName -Confirm:$false -Force -ErrorAction Stop }
                    $Script:output = "Process $($ProcessName) stopped"
                }
                else {                
                    throw "Process $($ProcessName) not found"
                }
            }
            else {
                $Script:process = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ Get-Process -ID $Using:ProcessID  } -ErrorAction Stop
                if($null -ne $Script:process){
                    $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ Stop-Process -ID $Using:ProcessID -Confirm:$false -Force -ErrorAction Stop }
                    $Script:output = "Process $($ProcessID) stopped"
                }
                else {                
                    throw "Process $($ProcessID) not found"
                }
            }
        }
    }
    else {        
        if($ProcessID -le 0){
            $Script:process = Get-Process -Name $ProcessName -ErrorAction Stop
            if($null -ne $Script:process){
                $null = Stop-Process -InputObject $Script:process -Confirm:$false -Force -ErrorAction Stop
                $Script:output = "Process $($ProcessName) stopped"
            }
            else {                
                throw "Process $($ProcessName) not found"
            }
        }
        else {
            $Script:process = Get-Process -ID $ProcessID -ErrorAction Stop
            if($null -ne $Script:process){
                $null = Stop-Process -InputObject $Script:process -Confirm:$false -Force -ErrorAction Stop
                $Script:output = "Process $($ProcessID) stopped"
            }
            else {                
                throw "Process $($ProcessID) not found"
            }
        }
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