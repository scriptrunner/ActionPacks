#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
.SYNOPSIS
    Retrieves the VMware PowerCLI proxy configuration and default servers policy

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.VimAutomation.Core

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/PowerCLI

.Parameter Scope
    [sr-en] Scope to filter VMware PowerCLI settings by
    [sr-de] Umfang zum Filtern von VMware PowerCLI-Einstellungen
#>

[CmdLetBinding()]
Param(
    [ValidateSet( "Session", "User","AllUsers")]
    [string]$Scope
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:Output
    if([System.String]::IsNullOrWhiteSpace($Scope) -eq $true){
        $Script:Output = Get-PowerCLIConfiguration -ErrorAction Stop | Format-List
    }
    else {
        $Script:Output = Get-PowerCLIConfiguration -Scope $Scope -ErrorAction Stop | Format-List
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
    }
}
catch{
    throw
}
finally{    
}