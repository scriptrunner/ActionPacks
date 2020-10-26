#Requires -Version 5.0
#Requires -Modules Az.Billing

<#
    .SYNOPSIS
        Generates a report with usage details of the subscription
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az
        Requires Library script AzureAzLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Billing  

    .Parameter MaxCount
        [sr-en] Determine the maximum number of records to return     
        [sr-de] Maximale Anzahl der zurückzugebenden Datensätze

    .Parameter BillingPeriodName
        [sr-en] Name of a specific billing period to get the usage details that associate with
        [sr-de] Name eines bestimmten Abrechnungszeitraums

    .Parameter StartDate
        [sr-en] The start date of the usages to filter
        [sr-de] Das Startdatum der Verwendungen

    .Parameter EndDate
        [sr-en] The end date of the usages to filter
        [sr-de] Das Enddatum der Verwendungen
#>

param( 
    [string]$BillingPeriodName,
    [int]$MaxCount = 100,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartDate,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndDate
)

Import-Module Az

try{
    [string[]]$Properties = @('UsageStart','UsageEnd','BillingPeriodName','InstanceName')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'MaxCount' =$MaxCount}
    
    if([System.String]::IsNullOrWhiteSpace($BillingPeriodName) -eq $false){
        $cmdArgs.Add('BillingPeriodName',$BillingPeriodName)
    }
    if(($null -ne $StartDate) -and($StartDate.Year -gt 2000)){
        $cmdArgs.Add('StartDate',$StartDate.ToUniversalTime())
    }
    if(($null -ne $EndDate) -and($EndDate.Year -gt 2000)){
        $cmdArgs.Add('EndDate',$EndDate.ToUniversalTime())
    }

    $ret = Get-AzConsumptionUsageDetail @cmdArgs | Sort-Object Usagestart -Descending | Select-Object $Properties

    if($SRXEnv) {
        ConvertTo-ResultHtml -Result $ret
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}