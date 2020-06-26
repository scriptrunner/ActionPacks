#Requires -Version 5.1

<#
.SYNOPSIS
    Gets the history of backup operations on the computer

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

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. NextBackupTime,LastBackupTime. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [ValidateSet('*','NextBackupTime','LastBackupTime','LastSuccessfulBackupTime','DetailedMessage')]
    [string[]]$Properties = @('NextBackupTime','LastBackupTime','LastSuccessfulBackupTime','DetailedMessage')
)

try{
    $Script:output
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Get-WBSummary | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                Get-WBSummary | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
    }
    else {
        $Script:output = Get-WBSummary -ErrorAction Stop | Select-Object 
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