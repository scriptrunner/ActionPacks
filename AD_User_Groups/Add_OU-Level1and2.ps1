<#
.synopsis

.Parameter cred-demo
Domain credentials

.Parameter ADName
Active Diretory Name

.Parameter OU1
Organizational Unit Name Level 1

.Parameter OU2
Organizational Unit Name Level 2


#>


param(
[string]$ADName = "DC=demo,DC=intern,DC=huths,DC=eu",
[string]$OU1 = "TestBasis",
[string]$OU2 = "TestLevel2"
)
New-ADOrganizationalUnit -Name $OU1 -Path $ADName -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name $OU2 -Path "OU=$OU1,$ADName" -ProtectedFromAccidentalDeletion $false

    $a1 = Get-ADOrganizationalUnit -Filter 'Name -eq $OU1' 
    $a2 = Get-ADOrganizationalUnit -Filter 'Name -eq $OU2' 

    ($a1, $a2) | FT Name,DistinguishedName
    $SRXEnv.ResultMessage = ($a1, $a2)
