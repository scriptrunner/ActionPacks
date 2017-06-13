#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
Gets the properties of the Active Directory account, or all available property names.

.DESCRIPTION
Gets the properties of the Active Directory account, or all available property names.

.PARAMETER SAMAccountName
The sAMAccountName of the user or UserPrincipalName or Down-Level logon name

.PARAMETER Properties
List of properties to expand.Default is '*'

.PARAMETER PrintAvailablePropertyNames
Show all available property names

.EXAMPLE

    .\GetADUserProperties.ps1 -PrintAvailablePropertyNames

.EXAMPLE

    .\GetADUserProperties.ps1 -SAMAccountName 'hans.wurst'

.EXAMPLE

    .\GetADUserProperties.ps1 -SAMAccountName 'hans.wurst' -Properties SID, UserPrincipalName

.NOTES
General notes
Requires ActiveDirectory module

#>
    
[CMDLetBinding()]
param(
    [Parameter(Mandatory=$true, ParameterSetName='SAMAccountName')]
    [string]$SAMAccountName,
    [Parameter(ParameterSetName='SAMAccountName')]
    [string[]]$Properties = '*',
    [Parameter(Mandatory=$true, ParameterSetName='PropertyNames')]
    [switch]$PrintAvailablePropertyNames
)

Import-Module ActiveDirectory


if($PrintAvailablePropertyNames.IsPresent){
    Get-ADUser -Filter '*' -Properties '*' -ResultSetSize 1 | Select-Object -ExpandProperty 'PropertyNames'
}
else{
    if($SAMAccountName.Contains('\')){
        $domainName = $SAMAccountName.Split('\')[0]
        $SAMAccountName = $SAMAccountName.Split('\')[1]
        $dnsRoot = Get-ADDomain -Identity $domainName | Select-Object -ExpandProperty 'DNSRoot'
    }
    if($SAMAccountName.Contains('@')){
        $domainName = $SAMAccountName.Split('@')[1]
        $SAMAccountName = $SAMAccountName.Split('@')[0]
        $dnsRoot = Get-ADDomain -Identity $domainName | Select-Object -ExpandProperty 'DNSRoot'
    }

    if($Properties -eq '*'){
        if($dnsRoot){
            Get-ADUser -Filter { SAMAccountName -eq $SAMAccountName } -Properties $Properties -Server $dnsRoot -ResultSetSize 1
        }
        else {
            Get-ADUser -Identity $SAMAccountName -Properties $Properties
        }
    }
    else{
        if($dnsRoot){
            Get-ADUser -Filter { SAMAccountName -eq $SAMAccountName } -Properties $Properties -Server $dnsRoot -ResultSetSize 1 | Select-Object -Property $Properties | Format-List
        }
        else {
            Get-ADUser -Identity $SAMAccountName -Properties $Properties | Select-Object -Property $Properties | Format-List
        }
    }

}
