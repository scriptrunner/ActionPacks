#ASR Parameter: Identity Type: Choice(ADUsers)

<#
	.SYNOPSIS 
		Change a user's properties.

	.PARAMETER Identity
        User Identity e.g. SamAccountName, UserPrincipalName

    .PARAMETER SearchBase
        AD base path where the search starts.
        e.g. 'OU=DE,DC=devtest,DC=appsphere,DC=com',
    
    .PARAMETER Unlock
		Unlock the user account.

	.PARAMETER Enable
		Enable/Disable the user account (Keep | Enable | Disable).

    .PARAMETER Title
        Change AD property Title 

    .PARAMETER Description
        Change AD property Description 

    .PARAMETER Name
        Change AD property Name

    .PARAMETER DisplayName
        Change AD property DisplayName 

    .PARAMETER GivenName
        Change AD property GivenName

    .PARAMETER Surname
        Change AD property Surname

    .PARAMETER Manager
        Change AD property Manager

    .PARAMETER EmployeeID
        Change AD property EmployeeID

    .PARAMETER Department
        Change AD property Department

    .PARAMETER Division
        Change AD property Division

    .PARAMETER Organization
        Change AD property Organization

    .PARAMETER StreetAddress
        Change AD property StreetAddress

    .PARAMETER PostalCode
        Change AD property PostalCode

    .PARAMETER City
        Change AD property City

    .PARAMETER State
        Change AD property State

    .PARAMETER OfficePhone
        Change AD property OfficePhone 

    .PARAMETER MobilePhone
        Change AD property MobilePhone 

    .PARAMETER HomePhone
        Change AD property HomePhone

    .PARAMETER EmailAddress
        Change AD property EmailAddress

#>


[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]$Identity,
    [string]$SearchBase,
    [Parameter(ParameterSetName="Unlock")]
    [switch]$Unlock,
    [Parameter(ParameterSetName="EnableDisable")]
    [ValidateSet('Keep', 'Enable', 'Disable')]
    [string]$Enable = 'Keep',
    [Parameter(ParameterSetName="Change")]
    [string]$Title,
    [Parameter(ParameterSetName="Change")]
    [string]$Description,
    [Parameter(ParameterSetName="Change")]
    [string]$Name,
    [Parameter(ParameterSetName="Change")]
    [string]$DisplayName,
    [Parameter(ParameterSetName="Change")]
    [string]$GivenName,
    [Parameter(ParameterSetName="Change")]
    [string]$Surname,
    [Parameter(ParameterSetName="Change")]
    [string]$Manager,
    [Parameter(ParameterSetName="Change")]
	[string]$EmployeeID,
    [Parameter(ParameterSetName="Change")]
	[string]$Department,
    [Parameter(ParameterSetName="Change")]
    [string]$Division,
    [Parameter(ParameterSetName="Change")]
    [string]$Organization,
    [Parameter(ParameterSetName="Change")]
	[string]$StreetAddress,
    [Parameter(ParameterSetName="Change")]
    [string]$PostalCode,
    [Parameter(ParameterSetName="Change")]
	[string]$City,
    [Parameter(ParameterSetName="Change")]
    [string]$State,
    [Parameter(ParameterSetName="Change")]
    [string]$OfficePhone,
    [Parameter(ParameterSetName="Change")]
    [string]$MobilePhone,
    [Parameter(ParameterSetName="Change")]
    [string]$HomePhone,
    [Parameter(ParameterSetName="Change")]
    [string]$EmailAddress

)

$ErrorActionPreference = 'Stop'
try {

    Import-Module ActiveDirectory

    if($SearchBase){
        $propertyNames = Get-ADUser -Identity $Identity -Properties '*' -SearchBase $SearchBase | Select-Object -ExpandProperty 'PropertyNames'
    }
    else {
        $propertyNames = Get-ADUser -Identity $Identity -Properties '*' | Select-Object -ExpandProperty 'PropertyNames'
    }

    switch ($PSCmdlet.ParameterSetName) {
        "Unlock" {
            $res = Unlock-ADAccount -Identity $Identity -PassThru
            $message = "User $Identity is unlocked."
        }

        "EnableDisable" {
            if($Enable -ne 'Keep'){
                $Enabled = $Enable -eq 'Enable'
                $res = Set-ADUser -Identity $SamAccountName -Enabled $Enabled -PassThru
            }
            else {
                $state = Get-ADUser -Identity $Identity -Properties 'Enabled' | Select-Object -ExpandProperty 'Enabled'
                if($state -eq $null){
                        $message = "Keep $Identity state unset."
                }
                else{
                    if($state){
                        $message = "Keep $Identity enabled."
                    } else {
                        $message = "Keep $Identity disabled."
                    }
                }
            }
        }

        "Change" {
            $properties = New-Object -TypeName System.Collections.Hashtable
            if($Title){
                $properties.Add('Title', $Title)
            }
            if($Description){
                $properties.Add('Description', $Description)
            }
            if($Name){
                $properties.Add('Name', $Name)
            }
            if($DisplayName){
                $properties.Add('DisplayName', $DisplayName)
            }
            if($GivenName){
                $properties.Add('GivenName', $GivenName)
            }
            if($Surname){
                $properties.Add('Surname', $Surname)
            }
            if($Manager){
                $properties.Add('Manager', $Manager)
            }
            if($EmployeeID){
                $properties.Add('EmployeeID', $EmployeeID)
            }
            if($Department){
                $properties.Add('Department', $Department)
            }
            if($Division){
                $properties.Add('Division', $Division)
            }
            if($Organization){
                $properties.Add('Organization', $Organization)
            }
            if($StreetAddress){
                $properties.Add('StreetAddress', $StreetAddress)
            }
            if($PostalCode){
                $properties.Add('PostalCode', $PostalCode)
            }
            if($City){
                $properties.Add('City', $City)
            }
            if($State){
                $properties.Add('State', $State)
            }
            if($OfficePhone){
                $properties.Add('OfficePhone', $OfficePhone)
            }
            if($MobilePhone){
                $properties.Add('MobilePhone', $MobilePhone)
            }
            if($HomePhone){
                $properties.Add('HomePhone', $HomePhone)
            }
            if($EmailAddress){
                $properties.Add('EmailAddress', $EmailAddress)
            }

            foreach ($key in $properties.Keys)
            {
                if(-not ($propertyNames -contains $key)){
                    $properties.Remove($key)
                    Write-Output "Skip unknown property '$key'."
                }
            }

            if($properties.Count -gt 0){
                $res = Set-ADUser -Identity $Identity -Replace $properties -PassThru
                $message = "Changed $($properties.Count) properties of $Identity."
             }
            else {
                throw "No supported properties specified."
            }
        }
    }
}
catch {
    if($SRXEnv){
        $SRXEnv.ResultMessage = $_.Exception.Message
    }
    throw
}

if($SRXEnv){
    $SRXEnv.ResultMessage = $message 
}

$res



# default message
$SRXEnv.ResultMessage = "Changing " + $replace.Count + " properties of $Identity ..."
$SRXEnv.ResultMessage

