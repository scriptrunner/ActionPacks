#Requires -Version 5.0

<#
    .SYNOPSIS
        Generates a chart report about the executions

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
        Requires Library Script SRReportsLib from the Action Pack Reporting\_LIB_
        
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

    .Parameter ReportLanguage
        [sr-en] Display language and Datie formation culture
        [sr-de] Anzeige-Sprache und Datums-Formatierung
#>

[CmdLetBinding()]
Param(
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartDate,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndDate,
    [string]$ActionName,
    [string]$TargetName,
    [ValidateSet('en','de','fr','es','it','hu')]
    [string]$ReportLanguage = 'en'
)

$con = $null
[int]$colCount = 5 # charts in a row
[string]$Script:ReductionColor = '#FFAE4C' # color of reducation
[string]$Script:ReductionBorderColor = '#FF9719'
[string]$Script:DurationColor = '#4C81B5' # color of duration
[string]$Script:DurationBorderColor = '#195DA0'
try{
    $Script:rep = New-Object 'System.Collections.Generic.List[System.Object]'
    
    function CreateChart(){
        <#
            .SYNOPSIS
                Generates a bar chart

            .Parameter ActionName
                Name of the action

            .Parameter DurationSum
                Durations sum

            .Parameter ReductionSum
                Reductions sum

            .Parameter Column
                Column number
        #>

        param(
            [string]$ActionName,
            [int]$DurationSum,
            [int]$ReductionSum,
            [int]$Column
        )

        if($Column -eq 1){
            $Script:rep.Add((Open-BarChartLine)) # open row
        }
        
        $bars = New-Object System.Collections.Generic.Queue[BarChartProperties]
        $bars.Enqueue(([BarChartProperties]::New('Sum of cost reduction', $DurationSum,$Script:DurationColor,$Script:DurationBorderColor)))
        $bars.Enqueue(([BarChartProperties]::New('Sum of ScriptRunner duration',$ReductionSum,$Script:ReductionColor,$Script:ReductionBorderColor)))
        $Script:rep.Add((Get-BarChart -Bars $bars -LabelXAxis $ActionName -WidthPx 300 -HeightPx 300 -LabelYAxis 'Sec.' -MultiData))
    }

    OpenSqlConnection -SqlCon ([ref]$con)

    if($null -eq $StartDate){
        $StartDate = Get-Date -Year 2019 -Month 1 -Day 1
    }
    if($null -eq $EndDate){
        $EndDate = Get-Date
    }

    $rep.Add((Open-REPDocument -Language $ReportLanguage)) # Get Html Code open document 
    [hashtable]$cmdArgs = @{
                        'ActionName' = $SRXEnv.SRXDisplayName
                        'StartedBy' =  $SRXEnv.SRXStartedBy
                        'TimeStamp' = $SRXEnv.SRXStarted   
                        'DateTimeCulture' = $ReportLanguage
    }    
    if($PSBoundParameters.ContainsKey('ActionName') -eq $true){
        $cmdArgs.Add("Action filter:",$ActionName)
    }
    if($PSBoundParameters.ContainsKey('TargetName') -eq $true){
        $cmdArgs.Add("Target filter:",$TargetName)
    }
    $rep.Add((GET-REPHeader @cmdArgs)) # get header html 

    # execute stored procedure
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
    $null = $sqlAdapter.Fill($sqlDS) # fill dataset

    if(($null -ne $sqlDS) -and ($sqlDS.Tables.Count -gt 0) -and ($sqlDS.Tables[0].Rows.Count -gt 0)){
        [int]$col = 0
        $acGrouped = ($sqlDS.Tables[0].rows | Sort-Object ActionName | Group-Object Action | Select-Object Name)
        # create bar charts
        foreach($item in $acGrouped){
            $col ++            
            $acObj = $sqlDS.Tables[0].rows | Where-Object {$_.Action -eq $item.Name}
            CreateChart -ActionName ($acObj | Select-Object -ExpandProperty ActionName -Unique) `
                -DurationSum ($acObj | Measure-Object -Property Duration -Sum).Sum `
                -ReductionSum ($acObj | Measure-Object -Property CostReduction -Sum).Sum `
                -Column $col
            if($col -ge $colCount){                                    
                $col = 0
                $Script:rep.Add((Close-BarChartLine)) # close bar chart line
            }                              
        }
        $Script:rep.Add((Close-BarChartLine)) # close bar chart line when open
        $sqlDS.Dispose()
    }
    $sqlAdapter.Dispose()
    $sqlCmd.Dispose()

    $Script:rep.Add((Close-REPDocument)) # close documents tags
    if($SRXEnv){
        $SRXEnv.ResultHTML = $Script:rep | Out-String
    }
    else {
        Write-Output "Not running on ScriptRunner PowerShell Host"
    }
}
catch{
    throw
}
finally{
    CloseSqlConnection -SqlCon $con
}