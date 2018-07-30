#Requires -Version 4.0

<#
.SYNOPSIS
    Gets the restore points on the computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Clients/ComputerRestore

.Parameter RestorePointID
    Specifies the restore point number, the value 0 returns all restore points

.Parameter LastStatus
    Gets the status of the most recent system restore operation

.Parameter Properties
    List of properties to expand, comma separated e.g. SequenceNumber,Description. Use * for all properties
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [int32]$RestorePointID,
    [switch]$LastStatus,
    [string]$Properties = "SequenceNumber,Description,CreationTime",
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($Properties) -eq $true){
        $Properties = '*'
    }
    [string[]]$Script:props=$Properties.Replace(' ','').Split(',')

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($LastStatus -eq $true){
            $Script:output = Get-ComputerRestorePoint -LastStatus -ErrorAction Stop
        }
        elseif ($RestorePointID -gt 0) {
            $Script:output = Get-ComputerRestorePoint -RestorePoint $RestorePointID -ErrorAction Stop | Select-Object $Script:props
        }
        else {
            $Script:output = Get-ComputerRestorePoint -ErrorAction Stop | Select-Object $Script:props
        }
    }
    else {
        if($null -eq $AccessAccount){
            if($LastStatus -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-ComputerRestorePoint -LastStatus -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif ($RestorePointID -gt 0) {
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-ComputerRestorePoint -RestorePoint $Using:RestorePointID -ErrorAction Stop | Select-Object $Using:props
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-ComputerRestorePoint -ErrorAction Stop | Select-Object $Using:props
                } -ErrorAction Stop
            }
        }
        else {
            if($LastStatus -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-ComputerRestorePoint -LastStatus -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif ($RestorePointID -gt 0) {
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-ComputerRestorePoint -RestorePoint $Using:RestorePointID -ErrorAction Stop | Select-Object $Using:props
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-ComputerRestorePoint -ErrorAction Stop | Select-Object $Using:props
                } -ErrorAction Stop
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