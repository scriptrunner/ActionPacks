#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    Executes a query and returns number of record affected

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
    Requires Library script DMSSimplySQL.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/SimplySQL

.Parameter ServerName
    The datasource for the connection

.Parameter DatabaseName
    Database catalog connecting to
 
.Parameter UpdateQuery
    SQL statement to run

.Parameter ConnectionTimeout
    The default command timeout to be used for all commands executed against this connection

.Parameter CommandTimeout
    The timeout, in seconds, for this SQL statement, defaults (-1) to the command timeout for the SqlConnection

.Parameter ConnectionName
    User defined name for the connection, default is SRConnection

.Parameter SQLCredential
    Credential object containing the SQL user/password, is the parameter empty authentication is Integrated Windows Authetication

.Parameter UseTransaction
    Starts a sql transaction before execute the query and rollback the transaction on error
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerName, 
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName, 
    [Parameter(Mandatory = $true)]
    [string]$UpdateQuery,
    [string]$ConnectionName = "SRConnection",
    [Parameter(Mandatory = $true)]
    [PSCredential]$SQLCredential,
    [int32]$ConnectionTimeout = 30,
    [int32]$CommandTimeout = -1,
    [switch]$UseTransaction
)

Import-Module SimplySQL

try{
    if($PSCmdlet.ParameterSetName  -eq "Connection available"){
        if((Test-SqlConnection -ConnectionName $ConnectionName) -eq $true){
            $Script:conn = Get-SqlConnection -ConnectionName $ConnectionName -ErrorAction Stop
        }
        else{
            Throw "Connection $($ConnectionName) not found"
        }
    }
    else{
        if($null -eq $SQLCredential){
            $Script:conn = Open-SqlConnection -Server $ServerName -Database $DatabaseName -CommandTimeout $ConnectionTimeout -ConnectionName $ConnectionName -ErrorAction Stop
        }
        else{
            $Script:conn = Open-SqlConnection -Server $ServerName -Database $DatabaseName -CommandTimeout $ConnectionTimeout -Credential $SQLCredential -ConnectionName $ConnectionName -ErrorAction Stop
        }
    }
        
    if($UseTransaction -eq $true){
        try{
            Start-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
            $Script:result = Invoke-SqlUpdate -ConnectionName $ConnectionName -Query $UpdateQuery -CommandTimeout $CommandTimeout -ErrorAction Stop
            Complete-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
        }
        catch{
            Undo-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
            throw
        }
    }
    else{
        $Script:result = Invoke-SqlUpdate -ConnectionName $ConnectionName -Query $UpdateQuery -CommandTimeout $CommandTimeout -ErrorAction Stop
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
    if($PSCmdlet.ParameterSetName  -eq "Open connection"){
        Close-SqlConnection -ConnectionName $ConnectionName 
    }
}