<#
.synopsis


.Parameter ADName
Active Diretory Name as distinguishedName 

#>


param(
    $ADName
)


$a = Get-ADDomain
$a
$SRXEnv.ResultMessage = $a
