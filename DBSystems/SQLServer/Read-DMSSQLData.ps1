#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Reads data from a table or a view of a SQL database

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module SQLServer
    Requires the library script DMSSqlServer.ps1
    
.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/SQLServer
 
.Parameter ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.Parameter ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.Parameter ColumnNames
    Specifies the names of columns that this cmdlet returns, comma separated

.Parameter ColumnOrder
    Specifies the names of columns by which this cmdlet sorts the columns that it returns, comma separated

.Parameter ColumnOrderType
    Specifies the order type for columns that this cmdlet returns

.Parameter DatabaseName
    Specifies the name of the database that contains the table
        
.Parameter SchemaName
    Specifies the name of the schema for the table or view

.Parameter TableName
    Specifies the name of the table

.Parameter ViewName
    Specifies the name of the view

.Parameter NumberOfRows 
    Specifies the number of rows of data that returns

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Table")]   
    [Parameter(Mandatory = $true,ParameterSetName = "View")]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true,ParameterSetName = "Table")]   
    [Parameter(Mandatory = $true,ParameterSetName = "View")]   
    [string]$DatabaseName,
    [Parameter(Mandatory = $true,ParameterSetName = "Table")]       
    [string]$TableName,
    [Parameter(Mandatory = $true,ParameterSetName = "View")]   
    [string]$ViewName,
    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [pscredential]$ServerCredential,
    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [string]$SchemaName = "dbo",
    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [string]$ColumnNames,
    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [string]$ColumnOrder,
    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [Int64]$NumberOfRows,
    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [ValidateSet('ASC','DESC')]
    [string]$ColumnOrderType = "ASC",
    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ServerInstance' = $ServerInstance
                            'ConnectionTimeout' = $ConnectionTimeout
                            'DatabaseName' = $DatabaseName
                            'SchemaName' = $SchemaName
                            'ColumnOrderType' = $ColumnOrderType
                            'SuppressProviderContextWarning' = $null
                            }     
    if([System.String]::IsNullOrWhiteSpace($ColumnNames) -eq $false){
        $cmdArgs.Add('ColumnName',$ColumnNames.Split(','))
    } 
    if([System.String]::IsNullOrWhiteSpace($ColumnOrder) -eq $false){
        $cmdArgs.Add('ColumnOrder',$ColumnOrder.Split(','))
    }      
    if($NumberOfRows -gt 0){
        $cmdArgs.Add('TopN',$NumberOfRows)
    } 
    if($null -ne $ServerCredential){
        $cmdArgs.Add('Credential',$ServerCredential)
    }            
    if($PSCmdlet.ParameterSetName -eq 'Table'){
        $cmdArgs.Add('TableName' , $TableName)
        $Script:result = Read-SqlTableData @cmdArgs
    }   
    else {
        $cmdArgs.Add('ViewName' , $ViewName)
        $Script:result = Read-SqlViewData @cmdArgs
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