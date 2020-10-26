#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    Reports the number of successful and erroneous reports in the specified period

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
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/Samples

.Parameter ServerName
    The datasource for the connection

.Parameter DatabaseName
    Database catalog connecting to
 
.Parameter StartDate
    Start date of the evaluation

.Parameter EndDate
    End date of the evaluation

.Parameter SQLCredential
    Credential object containing the SQL user/password, is the parameter empty authentication is Integrated Windows Authetication

.Parameter ActionName
    Name or part ofthe name from the ScriptRunner Action
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerName, 
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName,
    [Parameter(Mandatory = $true,HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartDate,
    [Parameter(Mandatory = $true,HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndDate,
    [PSCredential]$SQLCredential,
    [string]$ActionName
)

Import-Module SimplySQL

try{
    OpenSQlConnection -ServerName $ServerName -DatabaseName $DatabaseName -SQLCredential $SQLCredential -ErrorAction Stop
        
    if([System.String]::IsNullOrWhiteSpace($ActionName) -eq $true){
        $ActionName = ''
    }

    $query = "SELECT COUNT(IsError) FROM [dbo].[BaseEntities_JobControlSet] WHERE IsError = {0} AND DisplayName LIKE '%$($ActionName)%' 
        AND Created >= DATETIMEFROMPARTS ($($StartDate.Year), $($StartDate.Month), $($StartDate.Day), $($StartDate.Hour), $($StartDate.Minute), $($StartDate.Second),0) 
        AND Created <  DATETIMEFROMPARTS ($($EndDate.Year), $($EndDate.Month), $($EndDate.Day), $($EndDate.Hour), $($EndDate.Minute), $($EndDate.Second),0)"
    
    $iserror = InvokeScalarQuery -ScalarQuery ([System.String]::Format($query,"1")) -ReturnResult
    $isnoterror = InvokeScalarQuery -ScalarQuery ([System.String]::Format($query,"0")) -ReturnResult

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "$($iserror) errors and $($isnoterror) successful reports from $($Startdate) to $($EndDate)"
    }
    else{
        Write-Output "$($iserror) errors and $($isnoterror) successful reports from $($Startdate) to $($EndDate)"
    }
}
catch{
    throw
}
finally{
    CloseConnection -ConnectionName $ConnectionName
}