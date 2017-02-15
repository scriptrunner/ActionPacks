<#
    .SYNOPSIS 
		Creates a new user using the Active Directory Module.
		It creates a new AD user, you are able to specify SamAccountName to meet your needs.
		The number of User specific attributes is an example. The script can be enhanced with any 
		attribute available to the PS comandlet New-ADUser.

	.PARAMETER RootPath
		OU root (OU=Customer,DC=asr,DC=local)

	.PARAMETER Customer
		Customer/Country

	.PARAMETER Type
		Type of user: Admin, Test, User

	.PARAMETER OUPath
		Enter complete OU Path where to put the new user.

    .PARAMETER SamAccountName
        SamAccountName

    .PARAMETER PWD
        Initial password

	.PARAMETER Firstname
		First Name of the new user

	.PARAMETER Lastname
		Last Name of the new user

	.PARAMETER Company
		Employees Company Name

	.PARAMETER Department
		Employees Department

	.PARAMETER City
		City of User

	.PARAMETER StreetAddress
		Employees Office Street Address

	.PARAMETER userdomain
		@yourdomain.local

	.PARAMETER maildomain
		@yourmaildomain.com

#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, ParameterSetName="Structured OU path")]
  	[string]$RootPath = 'OU=Customer,DC=asr,DC=local',
    [Parameter(Mandatory=$true, ParameterSetName="Structured OU path")]
    [ValidateSet('Austria', 'Germany', 'Poland')]
    [string]$Customer,
    [Parameter(Mandatory=$true, ParameterSetName="Structured OU path")]
    [ValidateSet('ADM', 'TEST', 'USR')]
    [string]$Type,
    [Parameter(Mandatory=$true, ParameterSetName="Enter OU path")]
    [string]$OUPath,
    [Parameter(Mandatory=$true)]
    [string]$SamAccountName,
    [Parameter(Mandatory=$true)]
    [string]$PWD = 'Start123!',
    [Parameter(Mandatory=$true)]
    [string]$Firstname,
    [Parameter(Mandatory=$true)]
    [string]$Lastname,
    [string]$Company,
    [string]$Department,
    [string]$City,
    [string]$StreetAddress,
  	[string]$userdomain = '@asr.local',
	[string]$maildomain = '@scriptrunner.com'
)

if (!$OUPath) {
	$path = ("OU="+$Type), ("OU="+$Customer), $RootPath
	$OUPath = $path -join ','
}
"Creating user '$SamAccountName' in $OUPath..."

try {
	$SRXEnv.ResultMessage = New-ADUser -Name $SamAccountName -PassThru -AccountPassword (ConvertTo-SecureString $PWD -AsPlainText -Force) -AllowReversiblePasswordEncryption $FALSE`
	 -ChangePasswordAtLogon $TRUE -City $City -Company $Company -Department $Department -EmailAddress "$Firstname.$Lastname$maildomain" -Enabled $TRUE`
	 -GivenName $Firstname -PasswordNotRequired $FALSE -Path $OUPath -SamAccountName $SamAccountName -StreetAddress $StreetAddress`
	 -Surname $Lastname -userprincipalname ("$Firstname.$Lastname$userdomain") -DisplayName "$Firstname $Lastname" -Description "$Lastname,$Firstname $SamAccountName"

	$SRXEnv.ResultMessage
}
catch
{
    $SRXEnv.ResultMessage = $_.Exception.Message
    throw
}
