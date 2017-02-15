<#
	.SYNOPSIS 
		Unlock a list of Users.

    .PARAMETER LockedUserList
       Location and name of the .csv List with locked users

#>

Param
(
	
    $LockedUserList = "C:\temp\UserUnlock.csv"
)


Import-Csv „C:\Temp\Benutzersperren.csv“ | ForEach-Object {
$samAccountName = $_.“samAccountName“
Get-ADUser -Identity $samAccountName | Unlock-ADAccount
}

$SRXEnv.ResultMessage = "Die Anwender wurden entsperrt"
