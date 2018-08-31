#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Lists users where disabled, inactive, locked out and/or account is expired
    
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

    .Parameter DomainAccount
        Active Directory Credential

    .Parameter Disabled
        Show the users where account disabled
    
    .Parameter InActive
        Show the users where account inactive
        
    .Parameter Locked
        Show the users where account locked

    .Parameter Expired
        Show the users where account expired

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
    [PSCredential]$DomainAccount,
    [bool]$Disabled,
    [bool]$InActive,
    [bool]$Locked,
    [bool]$Expired,
    [string]$DomainName,
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

try{
    $Script:users = @()
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
        if($Disabled -eq $true){
            $Script:users += Search-ADAccount -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -AccountDisabled -UsersOnly -SearchBase $OUPath -SearchScope $SearchScope `
                                 | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName
        }
        if($InActive -eq $true){
            $Script:users += Search-ADAccount -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -AccountInactive -UsersOnly -SearchBase $OUPath -SearchScope $SearchScope `
                                 | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName
        } 
        if($Locked -eq $true){
            $Script:users += Search-ADAccount -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -LockedOut -UsersOnly -SearchBase $OUPath -SearchScope $SearchScope `
                                 | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName
        } 
        if($Expired -eq $true){
            $Script:users += Search-ADAccount -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -AccountExpired -UsersOnly -SearchBase $OUPath -SearchScope $SearchScope `
                                 | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName
        } 
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
        if($Disabled -eq $true){
            $Script:users += Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountDisabled -UsersOnly -SearchBase $OUPath -SearchScope $SearchScope `
                                | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName           
        }
        if($InActive -eq $true){
            $Script:users += Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountInactive -UsersOnly -SearchBase $OUPath -SearchScope $SearchScope `
                                | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName            
        } 
        if($Locked -eq $true){
            $Script:users += Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -LockedOut -UsersOnly -SearchBase $OUPath -SearchScope $SearchScope `
                                | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName            
        } 
        if($Expired -eq $true){
            $Script:users += Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountExpired -UsersOnly -SearchBase $OUPath -SearchScope $SearchScope `
                                | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName
        } 
    } 
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    if($null -ne $Script:users){
        foreach($itm in  $users){
            if($SRXEnv) {            
                $SRXEnv.ResultList += $itm.DistinguishedName # Value
                $SRXEnv.ResultList2 += $itm.SamAccountName # DisplayValue            
            }
            else{
                Write-Output $itm.SamAccountName
            }
        }
    }
}
catch{
    throw
}
finally{
}