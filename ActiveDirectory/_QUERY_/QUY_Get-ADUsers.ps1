#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Lists the users below the ou
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/_QUERY_

    .Parameter OUPath
        Specifies the AD path

    .Parameter UserName
        Specifies the SamAccountName of the users, use * to represent any series of characters, is the parameter empty all users retrieved   

    .Parameter DomainAccount
        Active Directory Credential

    .Parameter DomainName
        Name of Active Directory Domain
        
    .Parameter SearchScope
        Specifies the scope of an Active Directory search
    
    .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$OUPath,  
    [string]$SamAccountName,
    [PSCredential]$DomainAccount,
    [string]$DomainName,
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

try{
    $Script:users = @()
    if([System.String]::IsNullOrWhiteSpace($SamAccountName)){
        $SamAccountName = "*"
    }
    if($null -ne $DomainAccount){
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        else{
            $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }    
        if([System.String]::IsNullOrWhiteSpace($OUPath)){
            $OUPath = $Domain.DistinguishedName
        }
        $Script:users += Get-ADUser -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -Filter {SamAccountName -like $SamAccountName} `
                                -SearchBase $OUPath -SearchScope $SearchScope -Properties DistinguishedName, DisplayName, SamAccountName | Sort-Object -Property DisplayName
    }
    else{
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType  -ErrorAction Stop
        }
        else{
            $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType  -ErrorAction Stop
        }    
        if([System.String]::IsNullOrWhiteSpace($OUPath)){
            $OUPath = $Domain.DistinguishedName
        }
        $Script:users += Get-ADUser -Server $Domain.PDCEmulator -AuthType $AuthType -Filter {SamAccountName -like $SamAccountName} `
                            -SearchBase $OUPath -SearchScope $SearchScope -Properties DistinguishedName, DisplayName, SamAccountName | Sort-Object -Property DisplayName
    } 
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    if($null -ne $Script:users){
        foreach($itm in  $users){
            if($SRXEnv) {            
                $SRXEnv.ResultList += $itm.DistinguishedName # Value
                $SRXEnv.ResultList2 += "$($itm.DisplayName) ($($itm.SamAccountName))" # DisplayValue            
            }
            else{
                Write-Output "$($itm.DisplayName) ($($itm.SamAccountName))"
            }
        }
    }
}
catch{
    throw
}
finally{
}