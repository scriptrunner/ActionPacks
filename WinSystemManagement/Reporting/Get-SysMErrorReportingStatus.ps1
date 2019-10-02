#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves the Windows Error Reporting status

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Reporting
#>

[CmdLetBinding()]
Param(
)

Import-Module WindowsErrorReporting

try{
    [string]$Script:Msg
    $result = Get-WindowsErrorReporting -ErrorAction Stop
    if($result -eq $true){
        $Script:Msg = "Windows Error Reporting enabled"
    }
    else {
        $Script:Msg = "Windows Error Reporting disabled"
    }   
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Msg 
    }
    else{
        Write-Output $Script:Msg
    }
}
catch{
    throw
}
finally{
}