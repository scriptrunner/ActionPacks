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

    .PARAMETER UserPassword
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

		#TODO
		mehr Parameter vgl. user list
		Kommentare zu anpassungen
		ResultMessage anpassen
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
    [string]$Firstname,
    [Parameter(Mandatory=$true)]
    [string]$Lastname,
    [string]$UserPassword,
    [string]$Company = 'ScriptRunner',
    [ValidateSet('Software Products', 'Human Resources', 'Sales', 'Marketing', 'Management Board', 'IT Infrastructure', 'Customer Support')]
    [string]$Department = 'Software Products',
    [string]$City = 'Ettlingen',
    [string]$StreetAddress = 'Ludwig-Erhard-Allee 2',
  	[string]$userdomain = '@asr.local',
	[string]$maildomain = '@scriptrunner.com'
)

function CreatePassword {

    param(
        [int]$length = 8
    )

    $numbers = $NULL
    $cLetters = $NULL
    $sLetters = $NULL
    $specialSigns = @('!','"','#','%','&','§','=','+','-','_','<','>','@')
    
    For ($a=48; $a –le 57; $a++) {
         $numbers += ,[char][byte]$a
    }
    For ($a=65; $a –le 90; $a++) {
        $cLetters += ,[char][byte]$a 
    }
    For ($a=97; $a –le 122; $a++) {
        $sLetters += ,[char][byte]$a
    }

    $a = @($numbers, $cLetters, $sLetters, $specialSigns)

    [string]$password = [string]::Empty
    for($i=0; $i -lt $length; $i++){
        $j = Get-Random -Minimum 0 -Maximum 4
        $k = Get-Random -Minimum 0 -Maximum ($a[$j].Length-1)
        $password += "$($a[$j][$k])"
    }
    return $password
}

if(-not $UserPassword){
    $UserPassword = CreatePassword
}

if (-not $OUPath) {
	$path = ("OU="+$Type), ("OU="+$Customer), $RootPath
	$OUPath = $path -join ','
}
"Creating user '$SamAccountName' in $OUPath..."

try {
	$SRXEnv.ResultMessage = New-ADUser -Name $SamAccountName`
     -AccountPassword (ConvertTo-SecureString $UserPassword -AsPlainText -Force )`
     -AllowReversiblePasswordEncryption $FALSE`
     -PasswordNotRequired $FALSE`
	 -ChangePasswordAtLogon $TRUE`
	 -GivenName $Firstname`
	 -Surname $Lastname`
     -DisplayName "$Firstname $Lastname"`
     -Description "$Lastname,$Firstname $SamAccountName"`
     -SamAccountName $SamAccountName`
     -userprincipalname ("$Firstname.$Lastname$userdomain")`
     -EmailAddress "$Firstname.$Lastname$maildomain"`
     -Company $Company`
     -Department $Department`
     -City $City`
     -StreetAddress $StreetAddress`
     -Path $OUPath`
     -Enabled $TRUE`
     -PassThru

	$SRXEnv.ResultMessage
}
catch
{
    $SRXEnv.ResultMessage = $_.Exception.Message
    throw
}
