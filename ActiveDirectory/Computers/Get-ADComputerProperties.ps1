#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Gets the properties of the Active Directory computer
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter OUPath
        Specifies the AD path

    .Parameter Computername
        DistinguishedName, DNSHostName or SamAccountName of the Active Directory computer
    
    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP

    .Parameter Properties
        List of properties to expand. Use * for all properties
    
    .Parameter DomainName
        Name of Active Directory Domain
        
    .Parameter SearchScope
        Specifies the scope of an Active Directory search

     .Parameter AuthType
        Specifies the authentication method to use
#>

param(    
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,  
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Computername,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string[]]$Properties="Name,DistinguishedName,DNSHostName,Enabled,Description,IPv4Address,IPv6Address,LastBadPasswordAttempt,Location,OperatingSystem,SAMAccountName",   
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

#Clear
#$ErrorActionPreference='Stop'

[string]$Script:sam=$Computername
if(-not $Script:sam.EndsWith('$')){
    $Script:sam += '$'
}
$Script:Cmp 
if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:Cmp= Get-ADComputer -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
        -SearchBase $OUPath -SearchScope $SearchScope `
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
        -SearchBase $OUPath -SearchScope $SearchScope `
        -Filter {(SamAccountName -eq $sam) -or (DNSHostName -eq $Computername) -or (DistinguishedName -eq $Computername)} -Properties *    
}
if($null -ne $Cmp){
    $resultMessage = New-Object System.Collections.Specialized.OrderedDictionary
    if($Properties -eq '*'){
        foreach($itm in $Script:Cmp.PropertyNames){
            if($null -ne $Script:Cmp[$itm].Value){
                $resultMessage.Add($itm,$Script:Cmp[$itm].Value)
            }
        }
    }
    else {
        foreach($itm in $Properties.Split(',')){
            $resultMessage.Add($itm,$Script:Cmp[$itm.Trim()].Value)
        }
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $resultMessage  | Format-Table -HideTableHeaders -AutoSize
    }
    else{
        Write-Output $resultMessage | Format-Table -HideTableHeaders -AutoSize
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Computer $($Computername) not found"
    }    
    Throw "Computer $($Computername) not found"
}