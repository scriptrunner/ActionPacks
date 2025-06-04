#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Sets the properties of the Active Directory computer.
        Only parameters with values are set
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module ActiveDirectory
    
    .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter Computername
        DistinguishedName, DNSHostName or SamAccountName of the Active Directory computer
        [sr-de] DNSHost-Name, SAMAccountName, Distinguished-Name des Computers

    .Parameter DNSHostName
        Specifies the fully qualified domain name (FQDN) of the computer
        [sr-de] Gibt den fully qualified domain name (FQDN) des Computers an
        
    .Parameter Location
        Specifies the location of the computer
        [sr-de] Ort des Computers

    .Parameter Description
        Specifies a description of the computer
        [sr-de] Beschreibung des Computers

    .Parameter OperatingSystem
        Specifies an operating system name
        [sr-de] Betriebssystem des Computers        

    .Parameter OSServicePack
        Specifies the name of an operating system service pack
        [sr-de] Service Pack des Computer-Betriebesystems 

    .Parameter OSVersion
        Specifies an operating system version
        [sr-de] Version des Computer-Betriebesystems 

    .Parameter TrustedForDelegation
        Specifies whether an account is trusted for Kerberos delegation
        [sr-de] Gibt an, ob ein Konto für die Kerberos-Delegierung vertrauenswürdig ist.
    
    .Parameter AllowDialin
        Specifies the network access permission
        [sr-de] Aktiviert die Netzwerkzugriffsberechtigung

    .Parameter EnableCallback
        Specifies the Callback options
        [sr-de] Aktiviert die Rückrufoption

    .Parameter CallbackNumber
        Specifies the Callback number
        [sr-de] Gibt die Nummer für den Rückruf an

    .Parameter NewSAMAccountName
        The new SAMAccountName of Active Directory computer
        [sr-de] Neuer SamAccountName des Computers

    .Parameter DomainName
        Name of Active Directory Domain
        [sr-de] Name der Active Directory Domäne
        
    .Parameter SearchScope
        Specifies the scope of an Active Directory search
        [sr-de] Gibt den Suchumfang einer Active Directory-Suche an
    
    .Parameter AuthType
        Specifies the authentication method to use
        [sr-de] Gibt die zu verwendende Authentifizierungsmethode an
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
        $cmdArgs = @{'ErrorAction' = 'Stop'
                    'AuthType' = $AuthType
                    'Server' = $Domain.PDCEmulator
                    'PassThru' = $null
                    }
        if($null -ne $DomainAccount){
            $cmdArgs.Add("Credential", $DomainAccount)
        }

        $Script:Cmp= Set-ADComputer @cmdArgs -Instance $Script:Cmp 
        $cmdArgs.Add("Identity", $Script:Cmp.SamAccountName)

        if($Script:Cmp -and $PSBoundParameters.ContainsKey('AllowDialin') -eq $true){
            $Script:Cmp= Set-ADComputer @cmdArgs -Replace @{msnpallowdialin=$AllowDialin} 
        }
        if($Script:Cmp -and $PSBoundParameters.ContainsKey('EnableCallback') -eq $true -and $EnableCallback -eq $true) {        
            $Script:Cmp= Set-ADComputer @cmdArgs -Replace @{msRADIUSServiceType=4} 
        }  
        if($Script:Cmp -and $PSBoundParameters.ContainsKey('EnableCallback') -eq $true -and $EnableCallback -eq $false) {  
            $Script:Cmp= Set-ADComputer @cmdArgs -Remove @{msRADIUSServiceType=4}
        }  
        if($Script:Cmp -and (-not [System.String]::IsNullOrWhiteSpace($CallbackNumber))) {
            $Script:Cmp= Set-ADComputer @cmdArgs -Replace @{'msRADIUSCallbackNumber'=$CallbackNumber;'msRADIUSServiceType'=4} 
        }    
        if($Script:Cmp -and (-not [System.String]::IsNullOrWhiteSpace($NewSAMAccountName))){
            $Script:Cmp= Set-ADComputer @cmdArgs -Replace @{'SAMAccountName'=$NewSAMAccountName}
        }
        Write-Output "Computer $($Computername) changed"
    }
    else{
        throw "Computer $($Computername) not found"
    }   
}
catch{
    throw
}
finally{
}