#Requires -Version 5.0
#Requires -Modules Az.Billing

<#
    .SYNOPSIS
        Get usage details of the subscription
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Billing

    .Parameter MaxCount
        [sr-en] Determine the maximum number of records to return     
        [sr-de] Maximale Anzahl der zurückzugebenden Datensätze
        
    .Parameter Tag
        [sr-en] The tag of the usages to filter
        [sr-de] Tag der Verwendungen

    .Parameter BillingPeriodName
        [sr-en] Name of a specific billing period to get the usage details that associate with
        [sr-de] Name eines bestimmten Abrechnungszeitraums

    .Parameter IncludeMeterDetails
        [sr-en] Include meter details in the usages
        [sr-de] Zählerdetails der Verwendungen

    .Parameter IncludeAdditionalProperties
        [sr-en] Include additional properties in the usages
        [sr-de] Zusätzliche Eigenschaften der Verwendungen

    .Parameter StartDate
        [sr-en] The start date of the usages to filter
        [sr-de] Das Startdatum der Verwendungen

    .Parameter EndDate
        [sr-en] The end date of the usages to filter
        [sr-de] Das Enddatum der Verwendungen

    .Parameter InstanceName
        [sr-en] The instance name of the usages to filter
        [sr-de] Instanzname der Verwendungen
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$BillingPeriodName,
    [switch]$IncludeMeterDetails,
    [switch]$IncludeAdditionalProperties,
    [int]$MaxCount,
    [string]$Tag,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartDate,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndDate,
    [string]$InstanceName,
    [ValidateSet('*','UsageStart','UsageEnd','BillingPeriodName','InstanceName')]
    [string[]]$Properties = @('UsageStart','UsageEnd','BillingPeriodName','InstanceName')
)

Import-Module Az.Billing

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'IncludeMeterDetails' =$IncludeMeterDetails
                            'IncludeAdditionalProperties' =$IncludeAdditionalProperties}
    
    if($MaxCount -gt 0){
        $cmdArgs.Add('MaxCount',$MaxCount)
    }
    if([System.String]::IsNullOrWhiteSpace($BillingPeriodName) -eq $false){
        $cmdArgs.Add('BillingPeriodName',$BillingPeriodName)
    }
    if([System.String]::IsNullOrWhiteSpace($InstanceName) -eq $false){
        $cmdArgs.Add('InstanceName',$InstanceName)
    }
    if([System.String]::IsNullOrWhiteSpace($Tag) -eq $false){
        $cmdArgs.Add('Tag',$Tag)
    }
    if(($null -ne $StartDate) -and($StartDate.Year -gt 2000)){
        $cmdArgs.Add('StartDate',$StartDate.ToUniversalTime())
    }
    if(($null -ne $EndDate) -and($EndDate.Year -gt 2000)){
        $cmdArgs.Add('EndDate',$EndDate.ToUniversalTime())
    }

    $ret = Get-AzConsumptionUsageDetail @cmdArgs | Sort-Object Usagestart -Descending | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}