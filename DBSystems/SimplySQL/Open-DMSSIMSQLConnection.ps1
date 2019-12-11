#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    Open a connection to a SQL Server

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

.Parameter ServerName
    The datasource for the connection

.Parameter DatabaseName
    Database catalog connecting to

.Parameter CommandTimeout
    The default command timeout to be used for all commands executed against this connection
 
.Parameter ConnectionName
    The name to associate with the newly created connection, default is SRConnection

.Parameter SQLCredential
    Credential object containing the SQL user/password, is the parameter empty authentication is Integrated Windows Authetication
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerName, 
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName, 
    [PSCredential]$SQLCredential,
    [int32]$CommandTimeout = 30,
    [string]$ConnectionName = "SRConnection"
)

Import-Module SimplySQL

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ConnectionName' = $ConnectionName
                            'Server' = $ServerName
                            'CommandTimeout' = $CommandTimeout
                            'Database' = $DatabaseName}
                            
    if($null -ne $SQLCredential){
        $cmdArgs.Add("Credential", $SQLCredential)
    }
    $Script:output = Open-SqlConnection @cmdArgs

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