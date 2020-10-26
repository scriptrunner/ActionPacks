#Requires -Version 5.0

<#
    .SYNOPSIS
        Generates a report about the executions

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
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_
        
    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/_REPORTS_

    .Parameter StartDate
        [sr-en] Start date of the report
        [sr-de] Startdatum des Reports

    .Parameter EndDate
        [sr-en] End date of the report
        [sr-de] Endedatum des Reports

    .Parameter ActionName
        [sr-en] Only executions of this action
        [sr-de] Nur Ausführungen dieser Aktion

    .Parameter TargetName
        [sr-en] Only executions on this target
        [sr-de] Nur Ausführungen auf diesem Zielsystem
#>

[CmdLetBinding()]
Param(
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartDate,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndDate,
    [string]$ActionName,
    [string]$TargetName
)

$con = $null

try{
    $result = New-Object System.Collections.Generic.List[PSCustomObject]
    OpenSqlConnection -SqlCon ([ref]$con)
    
    if($null -eq $StartDate){
        $StartDate = Get-Date -Year 2019 -Month 1 -Day 1
    }
    if($null -eq $EndDate){
        $EndDate = Get-Date
    }
    $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlDS = New-Object System.Data.DataSet    
    $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $sqlCmd.CommandText = 'GetExecutions'
    $sqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure
    $null = $sqlCmd.Parameters.AddWithValue('StartDate',$StartDate.Date.ToFileTimeUtc())
    $null = $sqlCmd.Parameters.AddWithValue('EndDate',$EndDate.AddDays(1).Date.ToFileTimeUtc())
    if($PSBoundParameters.ContainsKey('ActionName') -eq $true){
        $null = $sqlCmd.Parameters.AddWithValue('Action',$ActionName)
    }
    if($PSBoundParameters.ContainsKey('TargetName') -eq $true){
        $null = $sqlCmd.Parameters.AddWithValue('Target',$TargetName)
    }
    $sqlCmd.Connection = $con
    $sqlAdapter.SelectCommand = $sqlCmd
    $sqlAdapter.Fill($sqlDS)
    
    [string]$action
    [string]$target
    [UInt64]$sumIt
    if(($null -ne $sqlDS) -and ($sqlDS.Tables.Count -gt 0) -and ($sqlDS.Tables[0].Rows.Count -gt 0)){
        foreach($row in $sqlDS.Tables[0].Rows){ 
            $sumIt += ([uint64]$row['CostReduction'])           
            if($null -eq $row['ActionName']){
                $action = ''
            }
            else{
                $action = $row['ActionName']
            }
            if($null -eq $row['TargetName']){
                $target = ''
            }
            else{
                $target = $row['TargetName']
            }
            $result.Add([PSCustomObject] @{
                        'Reason' = $row['Reason']
                        'Cost reduction (sec)' = $row['CostReduction']
                        'Started' = [System.DateTime]::FromFileTimeUtc($row['Started'])
                        'Ended' = [System.DateTime]::FromFileTimeUtc($row['Ended'])
                        'Duration (sec)' = $row['Duration']
                        'Action' = $action
                        'Target' = $target
                    })
            }
            # total header line
            $result.Insert(0,[PSCustomObject] @{
                'Reason' = 'Total cost reduction'
                'Cost reduction (sec)'= $sumIt
                'Started' = ''
                'Ended' = ''
                'Duration (sec)' = ''
                'Action' = ''
                'Target' = ''
            })
        $sqlDS.Dispose()
    }
    $sqlAdapter.Dispose()
    $sqlCmd.Dispose()

    ConvertTo-ResultHtml -Result $result # call script library function
}
catch{
    throw
}
finally{
    CloseSqlConnection -SqlCon $con
}