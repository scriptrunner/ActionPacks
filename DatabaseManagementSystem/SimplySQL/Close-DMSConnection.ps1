#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    Closes an existing connection

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module SimplySQL

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DatabaseManagementSystem/SimplySQL
 
.Parameter ConnectionName
    User defined name for the connection, default is SRConnection
#>

[CmdLetBinding()]
Param(
    [string]$ConnectionName = "SRConnection"
)

Import-Module SimplySQL

try{
    $Script:result = "Connection $($ConnectionName) not found"
    if((Test-SqlConnection -ConnectionName $ConnectionName) -eq $true){
        Close-SqlConnection -ConnectionName $ConnectionName 
        $Script:result = "Connection $($ConnectionName) closed"
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