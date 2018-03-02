#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Removes Active Directory service account
    
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

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Users

    .Parameter OUPath
        Specifies the AD path

    .Parameter AccountName
        SAMAccountName or DistinguishedName name of Active Directory service account

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP
        
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
    [string]$AccountName,
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
try{
    $Script:Srv 
    $Script:Domain

    [string]$Script:sam=$AccountName
    if(-not $Script:sam.EndsWith('$')){
    #  $Script:sam += '$'
    }
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        $Script:Srv= Get-ADServiceAccount -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType `
                -SearchBase $OUPath -SearchScope $SearchScope `
                -Filter {(SamAccountName -eq $sam) -or (DistinguishedName -eq $AccountName)}  -ErrorAction Stop
    }
    else{
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType  -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType  -ErrorAction Stop
        }
        $Script:Srv= Get-ADServiceAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
                -SearchBase $OUPath -SearchScope $SearchScope `
                -Filter {(SamAccountName -eq $sam) -or (DistinguishedName -eq $AccountName)}  -ErrorAction Stop
    }
    if($null -ne $Script:Srv){
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            Remove-ADServiceAccount -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Srv -Confirm:$false -ErrorAction Stop
        }
        else {
            Remove-ADServiceAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Srv -Confirm:$false -ErrorAction Stop
        }
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Service account $($AccountName) deleted"
        } 
        else {
            Write-Output "Service account $($AccountName) deleted"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Service account $($AccountName) not found"
        }    
        Throw "Service account $($AccountName) not found"
    }   
}
catch{
    throw
}
finally{
}