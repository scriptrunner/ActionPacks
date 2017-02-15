<#
	.SYNOPSIS 
		Search all users in a given OU

    .Parameter SearchPath
        Path for User to search
    
    .PARAMETER Path
        Path and Name for .csv result file

#>

Param
(
    [string]$SearchPath,
    [string]$Path
    
)


Get-ADUser -Filter * -SearchBase $SearchPath -Properties * | Select -Property SurName,GivenName,SamAccountName | Export-CSV -Path $Path

$SRXEnv.ResultMessage = "Alle User im Pfad $SearchPath wurden in die Datei $Path gechrieben"