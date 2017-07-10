#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Gets all groups from the OU path
    
    .DESCRIPTION

    .Parameter OUPath
        Specifies the AD path
      
    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP

    .Parameter DomainName
        Name of Active Directory Domain

    .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

#Clear
$ErrorActionPreference='Stop'

$Script:Grps
if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }    
    if([System.String]::IsNullOrWhiteSpace($OUPath)){
        $OUPath = $Domain.DistinguishedName
    }
    $Script:Grps = Get-ADGroup -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -SearchBase $OUPath `
        -Filter * -Properties DistinguishedName, SamAccountName | Sort-Object -Property SAMAccountName
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }    
    if([System.String]::IsNullOrWhiteSpace($OUPath)){
        $OUPath = $Domain.DistinguishedName        
    }
    $Script:Grps = Get-ADGroup -Server $Domain.PDCEmulator -AuthType $AuthType -SearchBase $OUPath `
        -Filter * -Properties DistinguishedName, SamAccountName | Sort-Object -Property SAMAccountName
}
if($null -ne $Script:Grps){ 
    $resultMessage = @()
    foreach($itm in $Script:Grps){
        $resultMessage = $resultMessage + ($itm.DistinguishedName + ';' +$itm.SamAccountName)
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $resultMessage 
    }
    else{
        Write-Output $resultMessage 
    }
}
else {
    if($SRXEnv) {
        $SRXEnv.ResultMessage = 'No groups found' 
    }
    else{
        Write-Output 'No groups found'
    }
}