#Requires -Version 5.1

<#
.SYNOPSIS
    Sets the current schedule for backups

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Server/Backup

.Parameter Times
    Specifies the times of day to create a backup. Time values are formatted as HH:MM and separated by a comma

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Times,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    [string[]]$Script:schedules = $Times.Split(",")
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                Set-WBSchedule -Policy $pol -Schedule $Using:schedules -ErrorAction Stop
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                Set-WBSchedule -Policy $pol -Schedule $Using:schedules -ErrorAction Stop
            } -ErrorAction Stop
        }
    }
    else {
        $pol = Get-WBPolicy -Editable -ErrorAction Stop
        $Script:output = Set-WBSchedule -Policy $pol -Schedule $Script:schedules -ErrorAction Stop
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