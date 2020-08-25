#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Gets the properties of the Active Directory group
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Groups

    .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter GroupName
        DistinguishedName or SamAccountName of the Active Directory group
        [sr-de] SAMAccountName oder Distinguished-Name oder Gruppe

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
        [sr-de] Gibt die zu verwendende Authentifizierungsmethode an
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,   
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$GroupName,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('*','Name','Description','DistinguishedName','HomePage','SAMAccountName','SID','CN','GroupCategory','CanonicalName','GroupScope','Members','MemberOf')]
    [string[]]$Properties = @('Name','Description','DistinguishedName','HomePage','SAMAccountName','SID'),   
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
    $Script:Grp 
    if($Properties -contains '*'){
        $Properties = @('*')
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
                'Filter' = {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)}
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                'Properties' = '*'
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    $Script:Grp= Get-ADGroup @cmdArgs    
    if($null -ne $Script:Grp){
        $resultMessage = New-Object System.Collections.Specialized.OrderedDictionary
        if($Properties -eq '*'){
            foreach($itm in $Script:Grp.PropertyNames){
                if($null -ne $Script:Grp[$itm].Value){
                    $resultMessage.Add($itm,$Script:Grp[$itm].Value)
                }
            }
        }
        else {
            foreach($itm in $Properties){
                $resultMessage.Add($itm,$Script:Grp[$itm.Trim()].Value)
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
            $SRXEnv.ResultMessage = "Group $($GroupName) not found"
        }    
        Throw "Group $($GroupName) not found"
    }   
}
catch{
    throw
}
finally{
}