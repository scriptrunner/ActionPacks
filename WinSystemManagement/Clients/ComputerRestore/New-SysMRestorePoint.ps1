#Requires -Version 4.0

<#
.SYNOPSIS
    Creates a system restore point on the computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Clients/ComputerRestore

.Parameter Description
    Specifies a descriptive name for the restore point

.Parameter RestorePointType
    Specifies the type of restore point
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]    
    [string]$Description,
    [ValidateSet("APPLICATION_INSTALL", "APPLICATION_UNINSTALL", "DEVICE_DRIVER_INSTALL", "MODIFY_SETTINGS", "CANCELLED_OPERATION")]
    [string]$RestorePointType = "APPLICATION_INSTALL",
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    [string[]]$Properties = @('SequenceNumber','Description')
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $null = Checkpoint-Computer -Description $Description -RestorePointType $RestorePointType -ErrorAction Stop
        $Script:output = Get-ComputerRestorePoint -ErrorAction Stop | Select-Object -Last 1 -Property $Properties
    }
    else {
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Checkpoint-Computer -Description $Using:Description -RestorePointType $Using:RestorePointType -ErrorAction Stop;
                Get-ComputerRestorePoint -ErrorAction Stop | Select-Object -Last 1 -Property $Using:Properties
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Checkpoint-Computer -Description $Using:Description -RestorePointType $Using:RestorePointType -ErrorAction Stop;
                Get-ComputerRestorePoint -ErrorAction Stop | Select-Object -Last 1 -Property $Using:Properties
            } -ErrorAction Stop
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