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

.PARAMETER Credential
    Credential for authentication @ active directory web services.

.EXAMPLE

    .\GetADUserProperties.ps1 -PrintAvailablePropertyNames

.EXAMPLE

    .\GetADUserProperties.ps1 -UserName 'john.doe'

.EXAMPLE

    .\GetADUserProperties.ps1 -UserName 'john.doe' -Properties SID, UserPrincipalName, SurName

.NOTES
    General notes

    Requires ActiveDirectory module

    Be aware that on remote targets CredSSP must be enabled or ParameterSet 'WithAuthentication' must be used.

    To enable CredSSP folowing 2 steps are : 
        @ remote machine: Enable-WSManCredSSP -Role Server –Force
        @ ScriptRunner Host: Enable-WSManCredSSP -Role Client -DelegateComputer [remote computer name] -Force

#>
    
[CmdLetBinding(DefaultParameterSetName="DefaultProperties")]
param(
    [Parameter(Mandatory=$true, ParameterSetName='DefaultProperties')]
    [Parameter(Mandatory=$true, ParameterSetName='Properties')]
    [Parameter(Mandatory=$true, ParameterSetName='WithAuthentication')]
    [string]$UserName,
    [Parameter(Mandatory=$true, ParameterSetName='Properties')]
    [Parameter(Mandatory=$true, ParameterSetName='WithAuthentication')]
    [string[]]$Properties,
    [Parameter(Mandatory=$true, ParameterSetName='WithAuthentication')]
    [pscredential]$Credential,
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

    if($PSCmdlet.ParameterSetName -eq 'WithAuthentication'){
        if($UserName.Contains('\')){
            $domainName = $UserName.Split('\')[0]
            $UserName = $UserName.Split('\')[1]
            $dnsRoot = Get-ADDomain -Identity $domainName -Credential $Credential | Select-Object -ExpandProperty 'DNSRoot'
        }
        if($UserName.Contains('@')){
            $domainName = $UserName.Split('@')[1]
            $UserName = $UserName.Split('@')[0]
            $dnsRoot = Get-ADDomain -Identity $domainName -Credential $Credential | Select-Object -ExpandProperty 'DNSRoot'
        }

        if($dnsRoot){
            $user = Get-ADUser -Identity $UserName -Properties $Properties -Server $dnsRoot -Credential $Credential
        }
        else {
            $user = Get-ADUser -Identity $UserName -Properties $Properties -Credential $Credential
        }
    }
    else{
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

        if($dnsRoot){
            $user = Get-ADUser -Identity $UserName -Properties $Properties -Server $dnsRoot
        }
        else {
            $user = Get-ADUser -Identity $UserName -Properties $Properties
        }
    }

    $user | Select-Object -Property $Properties | Format-List

    if($SRXEnv) {
        if($user){
            [hashtable]$resultMessage = @{}
            foreach($property in $Properties){
                if($user[$property] -ne $null){
                    $resultMessage.Add($property, $user[$property].Value)
                }
            }
            $SRXEnv.ResultMessage = $resultMessage | Format-Table -HideTableHeaders
        }
        else {
            $SRXEnv.ResultMessage = "No results for '$UserName'."
        }
    }
}
