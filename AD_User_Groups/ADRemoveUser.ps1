#ASR Parameter: UserName Type: Choice(ADUsers)

<#
	.SYNOPSIS 
		Remove one account.

    .PARAMETER UserName
        Select the user account to remove.

    .PARAMETER SamAccountName
        Enter the user SamAccountName to remove.

#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, ParameterSetName="Select")]
    [string]$UserName,	
    [Parameter(Mandatory=$true, ParameterSetName="Enter")]
    [string]$SamAccountName
)

function ExtractSamAccountName($entry) {
	if ($entry -match ':') {
		$list = $entry.Split(':');
		#'Removing ' + $list[0] + ' ...'
		return $list[1]
	}
	return $entry
}

if ($UserName) {
	$SamAccountName = ExtractSamAccountName $UserName
}

"Removing user $SamAccountName..."
Remove-ADUser -Identity $SamAccountName -Confirm:$false

$SRXEnv.ResultMessage = "User $SamAccountName removed."
