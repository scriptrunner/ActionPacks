<#
	.SYNOPSIS 
		Search all inactive user for a given time .

    .PARAMETER $ADName
        Active Directory Name

    .PARAMETER $BasePath
		Optional: OU root to search (OU=Customer)

    .PARAMETER $Customer
		Optional: Select specific customer/country

    .PARAMETER Days
        Inactive for number of days.

	.PARAMETER WriteFile
		Optional: Also write result list to a CSV file (specified in parameter $Path).

	.PARAMETER Path
		Optional: Path and name for CSV output file.

#>

Param
(
	[Parameter(Mandatory=$true)]
    [string]$ADName = 'DC=asr,DC=local',
  	[string]$BasePath,
    [ValidateSet('ALL', 'Austria', 'Germany', 'Poland')]
  	[string]$Customer = 'ALL',
	[Parameter(Mandatory=$true)]
    [int]$Days = 90,
	[switch]$WriteFile,
	[string]$Path = 'C:\test\out.csv'
    
)

$Time = New-TimeSpan -Days $Days

if ($Customer -eq 'ALL') {
	"Searching inactive users..."
	$res = Search-ADAccount –AccountInactive -TimeSpan $Time -UsersOnly | Select -Property SamAccountName,Name,DistinguishedName,LastLogonDate
} 
else {
	if (!$BasePath) {
		$searchbase = $ADName
	}
	else {
		$searchbase = $BasePath, $ADName
	} 
	$SB = $searchbase -join ','
    $SB = 'OU=' + $Customer + ',' + $SB
	"Searching inactive users in $SB..."
	$res = Search-ADAccount –AccountInactive -TimeSpan $Time -UsersOnly -SearchBase $SB | Select -Property SamAccountName,Name,DistinguishedName,LastLogonDate
}

# report output
$res
$SRXEnv.ResultMessage = "Found {0} accounts inactive since {1} days." -f $res.Count, $Days

if ($WriteFile.IsPresent -and $Path) {
	$res | Export-Csv -Path $Path
	$SRXEnv.ResultMessage = "{0} accounts inactive since {1} days exported to CSV file: {2}" -f $res.Count, $Days, $Path
}