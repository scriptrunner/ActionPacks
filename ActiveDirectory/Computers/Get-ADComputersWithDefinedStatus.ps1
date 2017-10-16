#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Lists computers where disabled or inactive
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT
        Requires Module ActiveDirectory       
    	
    .Parameter OUPath
        Specifies the AD path

    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP

    .Parameter Disabled
        Shows the disabled computers
    
    .Parameter InActive
        Shows the inactive computers
    
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
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$Disabled,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$InActive,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
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

$resultMessage = @()
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
    if($Disabled -eq $true){
        $computers = Search-ADAccount -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountDisabled -ComputersOnly `
            -SearchBase $OUPath -SearchScope $SearchScope | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($computers){
            foreach($itm in  $computers){
                $resultMessage = $resultMessage + ("Disabled: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)
            }
            $resultMessage = $resultMessage + ''  
        }
    }
    if($InActive -eq $true){
        $computers = Search-ADAccount -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountInactive -ComputersOnly `
            -SearchBase $OUPath -SearchScope $SearchScope | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($computers){
            foreach($itm in  $computers){
               $resultMessage = $resultMessage + ("Inactive: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
        }
    } 
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
    if($Disabled -eq $true){
        $computers = Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountDisabled -ComputersOnly `
            -SearchBase $OUPath -SearchScope $SearchScope | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($computers){
            foreach($itm in  $computers){
                $resultMessage = $resultMessage + ("Disabled: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)
            }
            $resultMessage = $resultMessage + ''
        }
    }
    if($InActive -eq $true){
        $computers = Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountInactive -ComputersOnly `
            -SearchBase $OUPath -SearchScope $SearchScope | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($computers){
            foreach($itm in  $computers){
               $resultMessage = $resultMessage + ("Inactive: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
        }
    } 
} 
if($SRXEnv) {
    $SRXEnv.ResultMessage = $resultMessage 
}
else{
    Write-Output $resultMessage 
}