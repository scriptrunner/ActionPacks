<#
	.SYNOPSIS 
		Change a user's properties.
     
    .PARAMETER SamAccountName
        Enter the SamAccountName of the user to change.

	.PARAMETER Unlock
		Unlock the user account.

	.PARAMETER Enable
		Enable/Disable the user account (Keep | Enable | Disable).

	.PARAMETER City
		Change the city (AD 'l' property)

	.PARAMETER Department
		Change the department (AD 'department' property)

	.PARAMETER StreetAddress
		Change the office street address (AD 'streetAddress' property)

	.PARAMETER OPhone
        Change the office phone number (AD 'telephoneNumber' property)

#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]$SamAccountName,
    [Parameter(Mandatory=$false, ParameterSetName="Unlock")]
    [switch]$Unlock,
    [Parameter(Mandatory=$false, ParameterSetName="EnableDisable")]
    [ValidateSet('Keep', 'Enable', 'Disable')]
    [string]$Enable = 'Keep',
    [Parameter(Mandatory=$false, ParameterSetName="Change")]
	[string]$City,
    [Parameter(Mandatory=$false, ParameterSetName="Change")]
	[string]$Department,
    [Parameter(Mandatory=$false, ParameterSetName="Change")]
	[string]$StreetAddress,
    [Parameter(Mandatory=$false, ParameterSetName="Change")]
    [string]$OPhone
)

$replace = @{}
if ($City) { $replace['l'] = $City }
if ($Department) { $replace['department'] = $Department }
if ($StreetAddress) { $replace['streetAddress'] = $StreetAddress }
if ($OPhone) { $replace['telephoneNumber'] = $OPhone }

# default message
$SRXEnv.ResultMessage = "Changing " + $replace.Count + " properties of $SamAccountName ..."
$SRXEnv.ResultMessage

try {
    if ($replace.Count -gt 0) {
	    $a = Set-ADUser -Identity $SamAccountName -Replace $replace -PassThru 
    }
    if ($Enable -like 'Enable') {
        "User is being enabled!"
	    $a = Set-ADUser -Identity $SamAccountName -Enabled $true -PassThru
    } 
    if ($Enable -like 'Disable') {
        "User is being disabled!"
	    $a = Set-ADUser -Identity $SamAccountName -Enabled $false -PassThru
    }
    if ($Unlock) {
        "User is being unlocked!"
        $a = Unlock-ADAccount -Identity $SamAccountName -PassThru
    }
    $a
    $SRXEnv.ResultMessage = $a
}
catch {
    $SRXEnv.ResultMessage = $_.Exception.Message
    throw
}
