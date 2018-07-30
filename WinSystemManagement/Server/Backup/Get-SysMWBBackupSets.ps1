#Requires -Version 5.1

<#
.SYNOPSIS
    Gets backups for a server from a location that you specify

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/Backup

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. BackupTime,Volume. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [string]$Properties = "BackupTime,BackupSetId,RecoverableItems,BackupTarget,Volume"
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($Properties) -eq $true){
        $Properties = "*"
    }
    [string[]]$Script:props = $Properties.Split(',')
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Get-WBBackupSet | Select-Object $Using:props
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                Get-WBBackupSet | Select-Object $Using:props
            } -ErrorAction Stop
        }
    }
    else {
        $Script:output = Get-WBBackupSet | Select-Object $Script:props
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