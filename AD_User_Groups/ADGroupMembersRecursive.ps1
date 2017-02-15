#ASR Parameter: GroupName Type: Choice(ADGroups)

<#
	.SYNOPSIS
	List group members (users only OR users and groups), and optionally write the result in an text file.

	.PARAMETER GroupName
	Select the group.

	.PARAMETER SamGroup
    Enter the group SamAccountName.

	.PARAMETER WriteFile
    Optional: Also write result list to a file (specified in parameter $Path).

	.PARAMETER Path
	Optional: Path and name for text output file.

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ParameterSetName="Select")]
	[string]$GroupName,
    [Parameter(Mandatory=$true, ParameterSetName="Enter")]
	[string]$SamGroup,
	#[switch]$IncludeGroups,
	[switch]$WriteFile,
	[string]$Path = 'C:\test\out.txt'
)

function ExtractSamAccountName($entry) {
	if ($entry -match ':') {
		$list = $entry.Split(':');
		#'Removing ' + $list[0] + ' ...'
		return $list[1]
	}
	return $entry
}

if ($GroupName) {
	$SamGroup = ExtractSamAccountName -entry $GroupName
}

#if ($IncludeGroups) {
	$res = (Get-ADGroupMember -Identity $SamGroup -Recursive | Select-Object Name, DisplayName)
#}
#else {
#	$a = Get-ADGroup -Identity $SamGroup | Select -Property DistinguishedName 
#	'Calling dsget.exe for group ' + $($a.DistinguishedName) + '...'
#	$res = & dsget.exe group $a.DistinguishedName -members -expand
#}
# report output
$res
$SRXEnv.ResultMessage = "Group '{0}': {1} members." -f $SamGroup, $res.Count

if ($WriteFile.IsPresent -and $Path) {
	$res | out-file $Path
	$SRXEnv.ResultMessage = "Group '{0}': {1} members exported to file: {2}" -f $SamGroup, $res.Count, $Path
}

