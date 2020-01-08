#Requires -Version 5.1

<#
.SYNOPSIS
    Removes a backup from a target catalog, a system catalog, or both

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


.Parameter BackupSetID
    Specifies the id of an backup set 

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$BackupSetID,   
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                $bSet = Get-WBBackupSet -ErrorAction Stop | Where-Object -Property BackupSetID -eq $Using:BackupSetID;
                $null = Remove-WBBackupSet -BackupSet $bSet -Force -ErrorAction Stop
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                $bSet = Get-WBBackupSet -ErrorAction Stop | Where-Object -Property BackupSetID -eq $Using:BackupSetID;
                $null = Remove-WBBackupSet -BackupSet $bSet -Force -ErrorAction Stop
            } -ErrorAction Stop
        }
    }
    else {
        $bSet = Get-WBBackupSet -ErrorAction Stop | Where-Object -Property BackupSetID -eq $BackupSetID
        $null = Remove-WBBackupSet -BackupSet $bSet -Force -ErrorAction Stop
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Backup successfully deleted"
    }
    else{
        Write-Output "Backup successfully deleted"
    }
}
catch{
    throw
}
finally{
}