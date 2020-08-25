#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Enable or disable a Active Directory computer
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Computers
        
    .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter Computername
        DistinguishedName, DNSHostName or SamAccountName of the Active Directory computer
        [sr-de] Distinguished-Name, DNSHost-Name oder SamAccountName des Computers

    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP        

    .Parameter EnableStatus
        Enables or disables the Active Directory computer
        [sr-de] De-/aktivieren der Computers
    
    .Parameter DomainName
        Name of Active Directory Domain
        [sr-de] Name der Active Directory Domäne
        
    .Parameter SearchScope
        Specifies the scope of an Active Directory search
        [sr-de] Gibt den Suchumfang einer Active Directory-Suche an
    
    .Parameter AuthType
        Specifies the authentication method to use
        [sr-de] Gibt die zu verwendende Authentifizierungsmethode an#>
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
    [ValidateSet('Enable','Disable')]
    [string]$EnableStatus='Enable',
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

try{
    $Script:Domain
    $Script:Cmp 
    [string]$Script:sam=$Computername
    if(-not $Script:sam.EndsWith('$')){
        $Script:sam += '$'
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
                'AuthType' = $AuthType
                'Filter' = {(SamAccountName -eq $sam) -or (DNSHostName -eq $Computername) -or (DistinguishedName -eq $Computername)}
                'Server' = $Domain.PDCEmulator
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                'Properties' = '*'
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }

    $Script:Cmp= Get-ADComputer @cmdArgs

    if($null -ne $Script:Cmp){    
        $res
        $cmdArgs = @{'ErrorAction' = 'Stop'
                    'AuthType' = $AuthType
                    'Identity' = $Script:Cmp.SamAccountName
                    'Server' = $Domain.PDCEmulator
                    }
        if($null -ne $DomainAccount){
            $cmdArgs.Add("Credential", $DomainAccount)
        }
    
        if($EnableStatus -eq 'Enable'){
            if($Cmp.Enabled -eq $false){
                Enable-ADAccount @cmdArgs
                $res= "Computer $($Cmp.Name) enabled"
            }
            else{
                $res= "Computer $($Cmp.Name) is not disabled"
            }
        }
        else{
            if($Cmp.Enabled -eq $true){
                Disable-ADAccount @cmdArgs
                $res= "Computer $($Cmp.Name) disabled"
            }
            else{
                $res= "Computer $($Cmp.Name) is not enabled"
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
}
catch{
    throw
}
finally{
}