#Requires -Version 4.0

<#
.SYNOPSIS
    Starts a system restore on the computer

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
    Specifies the restore point number
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]    
    [int32]$RestorePointID,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        Restore-Computer -RestorePoint $RestorePointID -Confirm:$false -ErrorAction Stop
    }
    else {
        if($null -eq $AccessAccount){            
            Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Restore-Computer -RestorePoint $Using:RestorePointID -Confirm:$false -ErrorAction Stop
            } -ErrorAction Stop
        }
        else {
            Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Restore-Computer -RestorePoint $Using:RestorePointID -Confirm:$false -ErrorAction Stop
            } -ErrorAction Stop
        }
    }      
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Computer restores"
    }
    else{
        Write-Output "Computer restores"
    }
}
catch{
    throw
}
finally{
}