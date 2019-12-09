#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Lists the users below the ou
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

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
    if([System.String]::IsNullOrWhiteSpace($SamAccountName)){
        $SamAccountName = "*"
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AuthType' = $AuthType
                            }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $cmdArgs.Add("Current", 'LocalComputer')
    }
    else {
        $cmdArgs.Add("Identity", $DomainName)
    }
    $Domain = Get-ADDomain @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Filter' = {SamAccountName -like $SamAccountName}
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                'Properties' = @('DistinguishedName', 'DisplayName', 'SamAccountName')
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    $Script:users = Get-ADUser @cmdArgs | Sort-Object -Property DisplayName    
   
    if($null -ne $Script:users){
        foreach($itm in  $users){
            if($SRXEnv) {            
                $SRXEnv.ResultList.Add($itm.DistinguishedName) # Value
                $SRXEnv.ResultList2.Add("$($itm.DisplayName) ($($itm.SamAccountName))") # DisplayValue            
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