#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
Gets the properties of the Active Directory account, or all available property names.

.DESCRIPTION
Gets the properties of the Active Directory account, or all available property names.

.PARAMETER UserName
The SAMAccountName or UserPrincipalName or Down-Level logon name of the user account

.PARAMETER Properties
List of properties to expand. e.g. * or SID, UserPrincipalName, SurName

.PARAMETER PrintAvailablePropertyNames
Show all available property names

.EXAMPLE

    .\GetADUserProperties.ps1 -PrintAvailablePropertyNames

.EXAMPLE

    .\GetADUserProperties.ps1 -UserName 'john.doe'

.EXAMPLE

    .\GetADUserProperties.ps1 -UserName 'john.doe' -Properties SID, UserPrincipalName, SurName

.NOTES
General notes
Requires ActiveDirectory module

#>
    
[CmdLetBinding(DefaultParameterSetName="DefaultProperties")]
param(
    [Parameter(Mandatory=$true, ParameterSetName='DefaultProperties')]
    [Parameter(Mandatory=$true, ParameterSetName='Properties')]
    [string]$UserName,
    [Parameter(Mandatory=$true, ParameterSetName='Properties')]
    [string[]]$Properties,
    [Parameter(Mandatory=$true, ParameterSetName='PropertyNames')]
    [switch]$PrintAvailablePropertyNames
)

Import-Module ActiveDirectory

if($PSCmdlet.ParameterSetName -eq 'PropertyNames'){
    Get-ADUser -Filter '*' -Properties '*' -ResultSetSize 1 | Select-Object -ExpandProperty 'PropertyNames'
}
else{
    if($PSCmdlet.ParameterSetName -eq 'DefaultProperties'){
        $Properties = @('Name', 'GivenName', 'Surname', 'DisplayName', 'Description', 'Office', 'EmailAddress', 'OfficePhone', 'Title', 'Department', 'Company', 'Street', 'PostalCode', 'City', 'SAMAccountName')
    }
    if($UserName.Contains('\')){
        $domainName = $UserName.Split('\')[0]
        $UserName = $UserName.Split('\')[1]
        $dnsRoot = Get-ADDomain -Identity $domainName | Select-Object -ExpandProperty 'DNSRoot'
    }
    if($UserName.Contains('@')){
        $domainName = $UserName.Split('@')[1]
        $UserName = $UserName.Split('@')[0]
        $dnsRoot = Get-ADDomain -Identity $domainName | Select-Object -ExpandProperty 'DNSRoot'
    }

    if($Properties -eq '*'){
        if($dnsRoot){
            Get-ADUser -Filter { SAMAccountName -eq $UserName } -Properties $Properties -Server $dnsRoot -ResultSetSize 1
        }
        else {
            Get-ADUser -Identity $UserName -Properties $Properties
        }
    }
    else{
        if($dnsRoot){
            Get-ADUser -Filter { SAMAccountName -eq $UserName } -Properties $Properties -Server $dnsRoot -ResultSetSize 1 | Select-Object -Property $Properties | Format-List
        }
        else {
            Get-ADUser -Identity $UserName -Properties $Properties | Select-Object -Property $Properties | Format-List
        }
    }

}
