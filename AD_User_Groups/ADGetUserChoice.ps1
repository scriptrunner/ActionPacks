<#
    .SYNOPSIS 
	Get the collected user Choice list.

    .PARAMETER ADName
        Active Directory Name
    
	.PARAMETER BasePath
		Optional: OU base path to search (OU=Customer)

	.PARAMETER Customer
		Optional: Select specific customer/country

#>

Param
(
    [string]$ADName = 'DC=asr,DC=local',
  	[string]$RootPath,
    [ValidateSet('ALL', 'Austria', 'Germany', 'Poland')]
  	[string]$Customer = 'ALL'
    #[ValidateSet('ADM', 'TEST', 'USR')]
  	#[string]$Type
)

function ExtractCustomer($DN, $BaseDepth) {

    $list = $DN.Split(",")
    $i = $list.Count - $BaseDepth
    if ($i -le 0) { # don't even use the first
        return ''
    }
    $resDN = $list[$i-1]
    $list = $resDN.Split("=")
    return $list[1]
}

if (!$RootPath) {
    $searchbase = $ADName
}
else {
    $searchbase = $RootPath, $ADName
} 

$SB = $searchbase -join ','
if ($Customer -eq 'ALL') {
    $searchdepth = $searchbase.Split(",").Count
} else {
    $SB = 'OU=' + $Customer + ',' + $SB
}
#"Searching users in $SB with depth $searchdepth..."

$a = Get-ADUser -Filter * -SearchBase $SB -SearchScope Subtree

if ($a) {
    $C = $Customer
    $SRXEnv.ResultMessage = 'Selection list created with ' + $a.Count + " users (searchbase: $SB)."
    ForEach($user in $a) {
        if ($searchdepth) {
            $C = ExtractCustomer -DN $user.DistinguishedName -BaseDepth $searchdepth
        }
        $C + ':' + $user.SamAccountName
    }
}
else {
    $SRXEnv.ResultMessage = "Selection list is empty! (searchbase: $SB)"
}