#ASR Parameter: UserName Type: Choice(ADUsers)
#ASR Parameter: GroupName Type: Choice(ADGroups)

<#
	.SYNOPSIS 
		Add a user account to a group.
     
    .PARAMETER UserName
        Select the user account to add.

    .PARAMETER SamMember
        Enter the SamAccountName of the user to add.

	.PARAMETER GroupName
		Select the group to add the user account to.

	.PARAMETER SamGroup
		Enter the group SamAccountName to add the user account to.

#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, ParameterSetName="Select")]
    [string]$UserName,
    [Parameter(Mandatory=$true, ParameterSetName="Enter")]
    [string]$SamMember,
    [Parameter(Mandatory=$true, ParameterSetName="Select")]
    [string]$GroupName,
    [Parameter(Mandatory=$true, ParameterSetName="Enter")]
    [string]$SamGroup
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
	$SamMember = ExtractSamAccountName -entry $UserName
} 
if ($GroupName) {
	$SamGroup = ExtractSamAccountName -entry $GroupName
} 

Add-ADGroupMember -Identity $SamGroup -Members $SamMember
$SRXEnv.ResultMessage = "$SamMember has been added to group $SamGroup."
