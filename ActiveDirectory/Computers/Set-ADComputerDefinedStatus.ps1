#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Enable or disable a Active Directory computer
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter Computername
        DistinguishedName, DNSHostName or SamAccountName of the Active Directory computer
    
    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP

    .Parameter Enable
        Enables the Active Directory computer
    
    .Parameter Disable
        Disables the Active Directory computer
    
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
    [switch]$Enable,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$Disable,
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
#$ErrorActionPreference='Stop'

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
if($null -ne $Cmp){    
    $res
    if($Disable -eq $true){
        if($Cmp.Enabled -eq $true){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                Disable-ADAccount -Identity $Cmp -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType
            }
            else{
                Disable-ADAccount -Identity $Cmp -Server $Domain.PDCEmulator -AuthType $AuthType
            }
            $res= "Computer $($Cmp.Name) disabled"
        }
        else{
            $res= "Computer $($Cmp.Name) is not enabled"
        }
    }
    if($Enable -eq $true){
        if($Cmp.Enabled -eq $false){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                Enable-ADAccount -Identity $Cmp -Credential $DomainAccount -AuthType $AuthType -Server $Domain.PDCEmulator
            }
            else{
                Enable-ADAccount -Identity $Cmp -AuthType $AuthType -Server $Domain.PDCEmulator
            }
            $res= "Computer $($Cmp.Name) enabled"
        }
        else{
            $res= "Computer $($Cmp.Name) is not disabled"
        }
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $res
    }
    else{
        Write-Output $res
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Computer $($Computername) not found"
    }    
    Throw "Computer $($Computername) not found"
}