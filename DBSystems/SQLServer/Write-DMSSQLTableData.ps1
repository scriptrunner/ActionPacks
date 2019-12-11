#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Writes data to a table of a SQL database

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
    Specifies the names of the columns match with the values, comma separated e.g. MyID,MyName,MyDescription

.Parameter Values
    Specifies the values written to the table, comma separated e.g. ,Test,Me

.Parameter ValuesCsvFile
    Csv file with the values, see WriteDataValues.csv

.Parameter DatabaseName
    Specifies the name of the database that contains the table
        
.Parameter SchemaName
    Specifies the name of the schema for the table

.Parameter TableName
    Specifies the name of the table from which this cmdlet reads

.Parameter Timeout
    Specifies a time-out value, in seconds, for the write operation
    
.Parameter CsvDelimiter
    Specifies the delimiter that separates the property values in the CSV file

.Parameter FileEncoding
    Specifies the type of character encoding that was used in the CSV file

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "ByString")]   
    [Parameter(Mandatory = $true,ParameterSetName = "ByCsv")]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true,ParameterSetName = "ByString")]   
    [Parameter(Mandatory = $true,ParameterSetName = "ByCsv")]
    [string]$DatabaseName,
    [Parameter(Mandatory = $true,ParameterSetName = "ByString")]   
    [Parameter(Mandatory = $true,ParameterSetName = "ByCsv")] 
    [string]$TableName,
    [Parameter(Mandatory = $true,ParameterSetName = "ByString")]   
    [string]$ColumnNames,
    [Parameter(Mandatory = $true,ParameterSetName = "ByString")]   
    [string]$Values,           
    [Parameter(Mandatory = $true,ParameterSetName = "ByCsv")]   
    [string]$ValuesCsvFile,
    [Parameter(ParameterSetName = "ByString")]   
    [Parameter(ParameterSetName = "ByCsv")] 
    [pscredential]$ServerCredential,
    [Parameter(ParameterSetName = "ByString")]   
    [Parameter(ParameterSetName = "ByCsv")] 
    [string]$SchemaName = "dbo",
    [Parameter(ParameterSetName = "ByString")]   
    [Parameter(ParameterSetName = "ByCsv")] 
    [Int32]$Timeout,
    [Parameter(ParameterSetName = "ByCsv")] 
    [string]$CsvDelimiter= ';',
    [Parameter(ParameterSetName = "ByCsv")] 
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',
    [Parameter(ParameterSetName = "ByString")]   
    [Parameter(ParameterSetName = "ByCsv")] 
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ServerInstance' = $ServerInstance
                            'ConnectionTimeout' = $ConnectionTimeout
                            'DatabaseName' = $DatabaseName
                            'TableName' = $TableName
                            'SchemaName' = $SchemaName
                            'SuppressProviderContextWarning' = $null
                            'Force' = $null
                            }              
    if($Timeout -gt 0){
        $cmdArgs.Add('Timeout',$Timeout)
    } 
    if($null -ne $ServerCredential){
        $cmdArgs.Add('Credential',$ServerCredential)
    }                

    $Script:cols
    $Script:newRow = [ordered]@{}
    [int]$Script:rowCount = 0
    if($PSCmdlet.ParameterSetName -eq "ByString"){
        $Script:cols = $ColumnNames.Split(',')
        $vals = $Values.Split(',')
        for($i=0; $i -lt $Script:cols.Count; $i++){
            $Script:newRow.Add($Script:cols[$i],$vals[$i])
        }
        $null = [PSCustomObject]$Script:newRow | Write-SqlTableData @cmdArgs
        $Script:rowCount ++
    } 
    else {
        if((Test-Path -Path $ValuesCsvFile) -eq $false){
            throw "Csv file: $($ValuesCsvFile) not found"
        }
        $Script:cols = (Get-Content $ValuesCsvFile | Select-Object -First 1).Split($CsvDelimiter) # get Header names
        $csvValues = Import-Csv -Path $ValuesCsvFile -Delimiter $CsvDelimiter -Encoding $FileEncoding -Header $Script:cols -ErrorAction Stop
        foreach($name in $Script:cols){ #  initialize ps object
            $Script:newRow.Add($name,$null)
        }     
        [bool]$first = $false   
        foreach($item in $csvValues){
            if(-not $first){
                $first = $true # skip header line
                continue
            }
            for ($i = 0; $i -lt $Script:cols.Count; $i++) {
                $Script:newRow[$Script:cols[$i]] = $item.psobject.Properties.Item($Script:cols[$i]).Value          
            }
            $null = [PSCustomObject]$Script:newRow | Write-SqlTableData @cmdArgs
            $Script:rowCount ++
        }
    }
    # get result
    $cmdArgs = @{'ErrorAction' = 'Stop'
                'ServerInstance' = $ServerInstance
                'ConnectionTimeout' = $ConnectionTimeout
                'DatabaseName' = $DatabaseName
                'TableName' = $TableName
                'SchemaName' = $SchemaName
                'ColumnOrderType' = 'DESC'
                'SuppressProviderContextWarning' = $null
                'ColumnOrder' = $Script:cols[0]
                'TopN' = $Script:rowCount
                }  
    if($null -ne $ServerCredential){
        $cmdArgs.Add('Credential',$ServerCredential)
    }  
    $result = Read-SqlTableData @cmdArgs

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