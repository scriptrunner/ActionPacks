#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Removes Active Directory computer
    
    .DESCRIPTION
          
    .Parameter Computername
        DistinguishedName, DNSHostName or SamAccountName of the Active Directory computer
    
    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP
       
    .Parameter DomainName
        Name of Active Directory Domain

     .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Computername,
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

$Script:Domain 
$Script:Cmp 
[string]$Script:sam=$Computername
if(-not $Script:sam.EndsWith('$')){
    $Script:sam += '$'
}
if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:Cmp= Get-ADComputer -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
        -Filter {(SamAccountName -eq $sam) -or (DNSHostName -eq $Computername) -or (DistinguishedName -eq $Computername)} -Properties *    
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
    $Script:Cmp= Get-ADComputer -Server $Domain.PDCEmulator -AuthType $AuthType  `
        -Filter {(SamAccountName -eq $sam) -or (DNSHostName -eq $Computername) -or (DistinguishedName -eq $Computername)} -Properties *    
}

$Script:res
if($null -ne $Cmp){
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        Remove-ADComputer -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Cmp -Confirm:$false
    }
    else{
        Remove-ADComputer -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Cmp -Confirm:$false 
    }
    $res= "Computer $($Computername) deleted"
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Computer $($Computername) not found"
    }    
    Write-Error "Computer $($Computername) not found"
}
if($SRXEnv){
    $SRXEnv.ResultMessage = $res
}
else{
    Write-Output $res    
}