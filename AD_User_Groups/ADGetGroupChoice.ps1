<#
    .SYNOPSIS 
	Get the collected group Choice list.

    .PARAMETER ADName
        Active Directory Name
    
	.PARAMETER BasePath
		Optional: OU root to search (OU=Customer)

	.PARAMETER Customer
		Optional: Select specific customer/country

#>

Param
(
	[Parameter(Mandatory=$true)]
    [string]$ADName = 'DC=asr,DC=local',
  	[string]$BasePath,
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

if (!$BasePath) {
    $searchbase = $ADName
}
else {
    $searchbase = $BasePath, $ADName
} 

$SB = $searchbase -join ','
if ($Customer -eq 'ALL') {
    $searchdepth = $searchbase.Split(",").Count
} else {
    $SB = 'OU=' + $Customer + ',' + $SB
}
#"Searching groups in $SB with depth $searchdepth..."

$a = Get-ADGroup -Filter * -SearchBase $SB -SearchScope Subtree

if ($a) {
    $C = $Customer
    $SRXEnv.ResultMessage = 'Selection list created with ' + $a.Count + " groups (searchbase: $SB)."
    ForEach($group in $a) {
        if ($searchdepth) {
            $C = ExtractCustomer -DN $group.DistinguishedName -BaseDepth $searchdepth
        }
        $C + ':' + $group.SamAccountName
    }
}
else {
    $SRXEnv.ResultMessage = "Selection list is empty! (searchbase: $SB)"
}