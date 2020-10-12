#Requires -Version 5.0

<#
.SYNOPSIS
    Lists all actions stored in the database

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires the library script StatisticLib.ps1
    
.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/_QUERY_
#>

[CmdLetBinding()]
Param(
)

$con = $null

try{
    OpenSqlConnection -SqlCon ([ref]$con)
    
    $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlDS = New-Object System.Data.DataSet    
    $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $sqlCmd.CommandText = 'GetActions'
    $sqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure
    $sqlCmd.Connection = $con
    $sqlAdapter.SelectCommand = $sqlCmd
    $sqlAdapter.Fill($sqlDS)
    
    if(($null -ne $sqlDS) -and ($sqlDS.Tables.Count -gt 0) -and ($sqlDS.Tables[0].Rows.Count -gt 0)){
        foreach($row in $sqlDS.Tables[0].Rows){
            if($SRXEnv) {                            
                $null = $SRXEnv.ResultList.Add($row["ActionName"]) # Value
                If(($null -eq $row["ScriptRunnerID"]) -or ($row["ScriptRunnerID"] -lt 0)){                    
                    $null = $SRXEnv.ResultList2.Add($row["ActionName"])
                }
                else {
                    $null = $SRXEnv.ResultList2.Add("$($row["ActionName"]) ($($row["ScriptRunnerID"]))")
                }
            }
            else{
                Write-Output $row["ActionName"]
            }
        }
        $sqlDS.Dispose()
    }
    $sqlAdapter.Dispose()
    $sqlCmd.Dispose()
}
catch{
    throw
}
finally{
    CloseSqlConnection -SqlCon $con
}