#Requires -Version 4.0
#Requires -Modules ActiveDirectory

function GetDomain(){
    <#
        .SYNOPSIS
            Gets the domain

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
            https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/_LIB_

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

        [CmdLetBinding()]
        Param(
            [string]$DomainName, 
            [PSCredential]$DomainAccount,
            [ValidateSet('Basic', 'Negotiate')]
            [string]$AuthType="Negotiate"
        )

        try{
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
            return Get-ADDomain @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}