<#
	.SYNOPSIS 
		Export the selected properties of users from ActiveDirectory, that match the given SearchFilter to a csv file.

    .Parameter SearchBase
        Active Directory base path where the search starts.
        e.g. 'OU=DE,DC=devtest,DC=appsphere,DC=com',

    .PARAMETER SearchFilter
        A search filter e.g. '{(mail -eq "*") -and (sn -eq "Smith")}'
    
    .PARAMETER ExportFilePath
        FilePath for .csv result file. If no ExportFilePath is specified the export will be written to $env:TEMP.

    .PARAMETER Properties
        List of properties, that will be exported.
        e.g. @('Enabled', 'Name', 'GivenName', 'Surname', 'SamAccountName', 'UserPrincipalName', 'SID')

    .PARAMETER Enabled
        Property Enabled will be exported.

    .PARAMETER Name
        Property Name will be exported.

    .PARAMETER GivenName
        Property GivenName will be exported.

    .PARAMETER SurName
        Property SurName will be exported.

    .PARAMETER SamAccountName
        Property SamAccountName will be exported.

    .PARAMETER UserPrincipalName
        Property UserPrincipalName will be exported.

    .PARAMETER SID
        Property SID will be exported.

#>

[CmdletBinding()]
Param
(
    [string]$SearchBase = 'OU=DE,DC=devtest,DC=appsphere,DC=com',
    [string]$SearchFilter = '*',
    [switch]$Export,
    [string]$ExportFilePath,
    [Parameter(Mandatory= $true, ParameterSetName = "PropertyList")]
    [string[]]$Properties,
    [Parameter(ParameterSetName = "PropertySwitch")]
    [switch]$Enabled,
    [Parameter(ParameterSetName = "PropertySwitch")]
    [switch]$Name,
    [Parameter(ParameterSetName = "PropertySwitch")]
    [switch]$GivenName,
    [Parameter(ParameterSetName = "PropertySwitch")]
    [switch]$Surname,
    [Parameter(ParameterSetName = "PropertySwitch")]
    [switch]$SamAccountName,
    [Parameter(ParameterSetName = "PropertySwitch")]
    [switch]$UserPrincipalName,
    [Parameter(ParameterSetName = "PropertySwitch")]
    [switch]$SID
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

if(-not $ExportFilePath){
    $timeStamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $basePath = $SearchBase.Replace(',', '_').Replace('=', [string]::Empty).Replace('OU', [string]::Empty).Replace('DC', [string]::Empty).Replace(' ', [string]::Empty)
    $ExportFilePath = Join-Path -Path $env:TEMP -ChildPath "ExportADUser_$($basePath)_$($timeStamp).csv"
}

$selectedProperties = New-Object -TypeName 'System.Collections.ArrayList'
switch ($PSCmdlet.ParameterSetName) {
    "PropertyList" {
        $propertyNames = Get-ADUser -Filter '*' -Properties '*' -SearchScope Subtree -ResultSetSize 1 | Select-Object -ExpandProperty 'PropertyNames'
        $selectedProperties = New-Object -TypeName 'System.Collections.ArrayList'
        foreach ($property in $Properties)
        {
            if($propertyNames -contains $property)
            {
                $null = $selectedProperties.Add($property)
            }
            else
            {
                Write-Output "Skip unknown property '$property'."
            }
        }
    }
    "PropertySwitch" {

        if($Enabled.IsPresent){
            $null = $selectedProperties.Add('Enabled')
        }
        if($GivenName.IsPresent){
            $null = $selectedProperties.Add('GivenName')
        }
        if($SurName.IsPresent){
            $null = $selectedProperties.Add('SurName')
        }
        if($Name.IsPresent){
            $null = $selectedProperties.Add('Name')
        }
        if($SamAccountName.IsPresent){
            $null = $selectedProperties.Add('SamAccountName')
        }
        if($UserPrincipalName.IsPresent){
            $null = $selectedProperties.Add('UserPrincipalName')
        }
        if($SID.IsPresent){
            $null = $selectedProperties.Add('SID')
        }
    }
}

if($selectedProperties.Count -eq 0){
    Write-Output "No property selected. Select default property 'UserPrincipalName'."
    $null = $selectedProperties.Add('UserPrincipalName')
}

Write-Output "Selected properties: '$selectedProperties'"

# https://technet.microsoft.com/en-us/library/ee617241.aspx
$users = Get-ADUser -Filter $SearchFilter -SearchBase $SearchBase -Properties $selectedProperties

if($Export.IsPresent){
    Write-Output "Exporting $($users.Count) ADUsers form '$SearchBase' with Filter '$SearchFilter' to '$ExportFilePath' ..."
    $users | Select-Object -Property $selectedProperties | Export-CSV -Path $ExportFilePath -Delimiter ';' -Encoding 'UTF8' -Force
    $resultMessage = "$($users.Count) Users from AD path '$SearchBase' that match filter '$SearchFilter' are exported to '$ExportFilePath'."
}
else {
    $users | Select-Object -Property $selectedProperties | Format-Table -AutoSize
    $resultMessage = "Found $($users.Count) Users from AD path '$SearchBase' that match filter '$SearchFilter'."
}

if($SRXEnv)
{
    $SRXEnv.ResultMessage = $resultMessage
}
else
{
    Write-Output $resultMessage
}
