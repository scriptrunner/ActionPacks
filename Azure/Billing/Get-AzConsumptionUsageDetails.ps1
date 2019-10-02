#Requires -Version 5.0
#Requires -Modules Az.Billing

<#
    .SYNOPSIS
        Get usage details of the subscription
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure        

    .Parameter AzureCredential
        The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

    .Parameter Tenant
        Tenant name or ID

    .Parameter MaxCount
        Determine the maximum number of records to return      
        
    .Parameter Tag
        The tag of the usages to filter

    .Parameter BillingPeriodName
        Name of a specific billing period to get the usage details that associate with

    .Parameter IncludeMeterDetails
        Include meter details in the usages

    .Parameter IncludeAdditionalProperties
        Include additional properties in the usages

    .Parameter StartDate
        The start date of the usages to filter.

    .Parameter EndDate
        The end date of the usages to filter.

    .Parameter InstanceName
        The instance name of the usages to filter

#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [string]$BillingPeriodName,
    [switch]$IncludeMeterDetails,
    [switch]$IncludeAdditionalProperties,
    [int]$MaxCount,
    [string]$Tag,
    [datetime]$StartDate,
    [datetime]$EndDate,
    [string]$InstanceName,
    [string]$Tenant
)

Import-Module Az

try{
  #  ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant

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

    $ret = Get-AzConsumptionUsageDetail @cmdArgs | Sort-Object Usagestart -Descending

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
  #  DisconnectAzure -Tenant $Tenant
}