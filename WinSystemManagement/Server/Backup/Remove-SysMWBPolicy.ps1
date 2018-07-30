#Requires -Version 5.1

<#
.SYNOPSIS
    Removes the backup policy

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Server/Backup

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Remove-WBPolicy -All -Force -ErrorAction Stop
            } -ErrorAction Stop
        }
        else {
            Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                Remove-WBPolicy -All -Force -ErrorAction Stop
            } -ErrorAction Stop
        }
    }
    else {
        Remove-WBPolicy -All -Force -ErrorAction Stop
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Backup policy removed"
    }
    else{
        Write-Output "Backup policy removed"
    }
}
catch{
    throw
}
finally{
}