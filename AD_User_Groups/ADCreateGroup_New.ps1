<#
	.SYNOPSIS 
		Creates a new Group using the Active Directory Module.
		It creates a new AD group, you are able to specify the Group CN.
        The number of group specific attributes is an example. The script can be enhanced with any 
        attribute available to the PS comandlet New-ADGroup.

	.PARAMETER RootPath
		OU root (OU=Customer,DC=asr,DC=local)

	.PARAMETER Customer
		Customer/Country

	.PARAMETER OUPath
		Enter complete OU Path where to put the new group.

	.Parameter Scope
		Group scope: DomainLocal | Global | Universal

	.Parameter GroupCategory
		Group scope: Distribution | Security

    .Parameter CName
        Group CName 

    .Parameter Description
		Group Description

    .Parameter DisplayName
		Group DisplayName

	.Parameter ManagedBy
		Group Manager Name

#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, ParameterSetName="Structured OU path")]
  	[string]$RootPath = 'OU=Customer,DC=asr,DC=local',
    [Parameter(Mandatory=$true, ParameterSetName="Structured OU path")]
    [ValidateSet('Austria', 'Germany', 'Poland')]
    [string]$Customer,
    [Parameter(Mandatory=$true, ParameterSetName="Enter OU path")]
    [string]$OUPath,    
    [ValidateSet('DomainLocal', 'Global', 'Universal')]
    [string]$Scope = 'Universal',
    [ValidateSet('Distribution', 'Security')]
    [string]$GroupCategory = 'Security',    
    [Parameter(Mandatory=$true)]
    [string]$CName,    
    [string]$Description = '',
    [string]$DisplayName = ''
    #[string]$ManagedBy
	
)

if (!$OUPath) {
	$path = 'OU=GRP', ('OU='+$Customer), $RootPath
	$OUPath = $path -join ','
}
"Creating Group '$CName' in $OUPath ..."

try {
    if (!$DisplayName) {
        $DisplayName = $CName
    }
    # $a = New-ADGroup -GroupCategory $GroupCategory -GroupScope $Scope -Name $CName -Path $OUPath -Description $Description -DisplayName $DisplayName -ManagedBy $ManagedBy -PassThru
    $a = New-ADGroup -GroupCategory $GroupCategory -GroupScope $Scope -Name $CName -Path $OUPath -Description $Description -DisplayName $DisplayName -PassThru
    $SRXEnv.ResultMessage = $a
    $a
}
catch
{
    $SRXEnv.ResultMessage = $_.Exception.Message
    throw
}
