#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Gets the properties of the Active Directory computer
    
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
        [sr-de] DNSHost-Name, SAMAccountName, Distinguished-Name des Computers
    
    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP        

    .Parameter Properties
        List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften

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
    [ValidateSet('*','Name','DistinguishedName','DNSHostName','Enabled','Description','IPv4Address','IPv6Address','LastLogonDate','LastBadPasswordAttempt','SID','Location','SAMAccountName','OperatingSystem','OperatingSystemServicePack','CanonicalName','AccountExpires')]
    [string[]]$Properties = @('Name','DistinguishedName','DNSHostName','Enabled','Description','IPv4Address','IPv6Address','LastBadPasswordAttempt','Location','OperatingSystem','SAMAccountName'),   
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
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [string]$Script:sam = $Computername
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
        $resultMessage = New-Object System.Collections.Specialized.OrderedDictionary
        if($Properties -eq '*'){
            foreach($itm in $Script:Cmp.PropertyNames){
                if($null -ne $Script:Cmp[$itm].Value){
                    $resultMessage.Add($itm,$Script:Cmp[$itm].Value)
                }
            }
        }
        else {
            foreach($itm in $Properties){
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
}
catch{
    throw
}
finally{
}