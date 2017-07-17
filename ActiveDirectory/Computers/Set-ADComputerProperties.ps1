#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Sets the properties of the Active Directory computer.
        Only parameters with values are set
    
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

    .Parameter DNSHostName
        Specifies the fully qualified domain name (FQDN) of the computer
        
    .Parameter Location
        Specifies the location of the computer

    .Parameter Description
        Specifies a description of the computer

    .Parameter OperatingSystem
        Specifies an operating system name

    .Parameter OSServicePack
        Specifies the name of an operating system service pack

    .Parameter OSServiceVersion
        Specifies an operating system version

    .Parameter TrustedForDelegation
        Specifies whether an account is trusted for Kerberos delegation
    
    .Parameter AllowDialin
        Specifies the network access permission

    .Parameter EnableCallback
        Specifies the Callback options

    .Parameter CallbackNumber
        Specifies the Callback number

    .Parameter NewSAMAccountName
        The new SAMAccountName of Active Directory computer

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
    [string]$DNSHostName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Location,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Description,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$OperatingSystem,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$OSServicePack,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$OSVersion,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$TrustedForDelegation,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$AllowDialin,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$EnableCallback,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$CallbackNumber,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$NewSAMAccountName,
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
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:Cmp= Get-ADComputer -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
        -Filter {(SamAccountName -eq $sam) -or (DNSHostName -eq $Computername) -or (DistinguishedName -eq $Computername)} -Properties *    
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
    $Script:Cmp= Get-ADComputer -Server $Domain.PDCEmulator -AuthType $AuthType `
        -Filter {(SamAccountName -eq $sam) -or (DNSHostName -eq $Computername) -or (DistinguishedName -eq $Computername)} -Properties *    
}
if($null -ne $Script:Cmp){
    if(-not [System.String]::IsNullOrWhiteSpace($DNSHostName)){
        $Script:Cmp.DNSHostName = $DNSHostName
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Location)){
        $Script:Cmp.Location = $Location
    }
    if(-not [System.String]::IsNullOrWhiteSpace($Description)){
        $Script:Cmp.Description = $Description
    }
    if(-not [System.String]::IsNullOrWhiteSpace($OperatingSystem)){
        $Script:Cmp.OperatingSystem = $OperatingSystem
    }
    if(-not [System.String]::IsNullOrWhiteSpace($OSServicePack)){
        $Script:Cmp.OperatingSystemServicePack = $OSServicePack
    }
    if(-not [System.String]::IsNullOrWhiteSpace($OSVersion)){
        $Script:Cmp.OperatingSystemVersion = $OSVersion
    }
    if($PSBoundParameters.ContainsKey('TrustedForDelegation') -eq $true){
        $Script:Cmp.TrustedForDelegation = $TrustedForDelegation
    }
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        $Script:Cmp = Set-ADComputer -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Instance $Script:Cmp -PassThru
    }
    else{
        $Script:Cmp = Set-ADComputer -Server $Domain.PDCEmulator -AuthType $AuthType -Instance $Script:Cmp -PassThru
    }
    if($Script:Cmp -and $PSBoundParameters.ContainsKey('AllowDialin') -eq $true){
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            $Script:Cmp=Set-ADComputer -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Cmp.SamAccountName -Replace @{msnpallowdialin=$AllowDialin} -PassThru
        }
        else{
            $Script:Cmp=Set-ADComputer -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Cmp.SamAccountName -Replace @{msnpallowdialin=$AllowDialin} -PassThru
        }
    }
    if($Script:Cmp -and $PSBoundParameters.ContainsKey('EnableCallback') -eq $true -and $EnableCallback -eq $true) {        
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            $Script:Cmp=Set-ADComputer -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Cmp.SamAccountName -Replace @{msRADIUSServiceType=4} -PassThru
        }
        else{
            $Script:Cmp=Set-ADComputer -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Cmp.SamAccountName -Replace @{msRADIUSServiceType=4} -PassThru
        }
    }  
    if($Script:Cmp -and $PSBoundParameters.ContainsKey('EnableCallback') -eq $true -and $EnableCallback -eq $false) {  
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){      
            $Script:Cmp=Set-ADComputer -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Cmp.SamAccountName -Remove @{msRADIUSServiceType=4} -PassThru
        }
        else{
            $Script:Cmp=Set-ADComputer -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Cmp.SamAccountName -Remove @{msRADIUSServiceType=4} -PassThru
        }
    }  
    if($Script:Cmp -and (-not [System.String]::IsNullOrWhiteSpace($CallbackNumber))) {
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){      
            $Script:Cmp=Set-ADComputer -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Identity `
                $Script:Cmp.SamAccountName -Replace @{'msRADIUSCallbackNumber'=$CallbackNumber;'msRADIUSServiceType'=4} -PassThru
        }
        else{
            $Script:Cmp=Set-ADComputer -Server $Domain.PDCEmulator -AuthType $AuthType -Identity `
                $Script:Cmp.SamAccountName -Replace @{'msRADIUSCallbackNumber'=$CallbackNumber;'msRADIUSServiceType'=4} -PassThru
        }
    }    
    if($Script:Cmp -and (-not [System.String]::IsNullOrWhiteSpace($NewSAMAccountName))){
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){      
            $Script:Cmp = Set-ADComputer -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Cmp.SamAccountName -Replace @{'SAMAccountName'=$NewSAMAccountName} -PassThru
        }
        else{
            $Script:Cmp = Set-ADComputer -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Cmp.SamAccountName -Replace @{'SAMAccountName'=$NewSAMAccountName} -PassThru
        }
    }
    if($null -ne $Script:Cmp){
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Computer $($Computername) changed"
        }
        else{
            Write-Output "Computer $($Computername) changed"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Computer $($Computername) not changed"
        }
        Throw "Computer $($Computername) not changed"
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Computer $($Computername) not found"
    }
    Throw "Computer $($Computername) not found"
}