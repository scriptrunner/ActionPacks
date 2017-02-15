<#
	.SYNOPSIS 
		Read alle attributes of a single user.

    .PARAMETER SamAccountName
        SamAccountName

#>

Param
(
    [string]$SamAccountName
)

    $a = Get-ADUser -Identity $SamAccountName -Properties *
    $a
    $SRXEnv.ResultMessage = $a
