<#
	.SYNOPSIS 
		Set a new Password for one User.
        User must change password at next logon


    .PARAMETER SamAccountName
        User Account Name

    .PARAMETER Pwd
        New Reset Password
#>

Param
(
    $SamAccountName,
    [ValidateLength(8, 12)]
    [String]$Pwd
)


Set-ADAccountPassword -Identity $SamAccountName -Reset -NewPassword (ConvertTo-SecureString -string $Pwd -AsPlainText -Force)
Set-ADUser -Identity $SamAccountName -ChangePasswordAtLogon:$true

$SRXEnv.ResultMessage = "Das Passwort wurde auf $Pwd geändert"