#Requires -Version 4.0

<#
.SYNOPSIS
    Removes a user remote session on the computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/RemoteDesktop

.Parameter SessionID
    Specifies the id of the user remote session

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [int]$SessionID,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $Script:result = rwinsta $SessionID
    }
    else {
        if($null -eq $AccessAccount){            
            $Script:result = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                rwinsta $Using:SessionID 
            } -ErrorAction Stop
        }
        else {
            $Script:result = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                rwinsta $Using:SessionID
            } -ErrorAction Stop
        }
    }  
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Session removed"
    }
    else{
        Write-Output "Session removed"
    }
}
catch{
    throw
}
finally{
}