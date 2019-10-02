#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    Lists the specified or all SqlConnections

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module SimplySQL

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/SimplySQL
 
.Parameter ShowAll
    Returns all active SqlConnections

.Parameter ConnectionName
    User defined name for the connection, default is SRConnection
#>

[CmdLetBinding()]
Param(
    [switch]$ShowAll,
    [string]$ConnectionName = "SRConnection"
)

Import-Module SimplySQL

try{
    if($ShowAll -eq $true){
        $Script:result = Show-SqlConnection -All -ErrorAction Stop | Get-SqlConnection 
    }
    else {
        $Script:result = Show-SqlConnection -ConnectionName $ConnectionName -ErrorAction Stop | Get-SqlConnection        
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:result
    }
    else{
        Write-Output $Script:result
    }
}
catch{
    throw
}
finally{
}