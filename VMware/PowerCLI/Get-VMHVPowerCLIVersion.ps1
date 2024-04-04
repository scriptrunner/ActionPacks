#Requires -Version 5.0
# Requires -Module VMware.VimAutomation.Core

<#
.SYNOPSIS
    Retrieves the version of the installed PowerCLI 

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
#>

[CmdLetBinding()]
Param(
)

Import-Module VMware.VimAutomation.Core

try{
    $result =  Get-Module -Name VMware.PowerCLI -ErrorAction Stop | Format-List

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{    
}