#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.1.7"}

<#
.SYNOPSIS
    Submits an operation that updates a custom policy package with new package settings

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 1.1.7 or greater
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Policies
    
.Parameter Identity 
    [sr-en] Name of the custom package.
    [sr-de] Name des benutzerdefinierten Pakets
    
.Parameter PolicyList
    [sr-en] List of one or more policies included in the package, semicolon separated. 
    The form is "<PolicyType>, <PolicyName>"
    [sr-de] Liste der Policies, Semikolon separiert. 
    Angabe der Werte: "<PolicyType>, <PolicyName>"

.Parameter Description
    [sr-en] Description of the custom package
    [sr-de] Beschreibung des benutzerdefinierten Pakets
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$Identity,
    [Parameter(Mandatory = $true)]   
    [string]$PolicyList,
    [string]$Description
)

Import-Module microsoftteams

try{
    $check = (Get-Command Update-CsCustomPolicyPackage -ErrorAction SilentlyContinue)
    if($null -eq $check){
        throw "Command is not available in the current module version"
    }
    
    [string[]]$list = $PolicyList.Split(';')
    [hashtable]$setArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            'PolicyList' = $list
                            }                       

    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $setArgs.Add('Description',$Description)
    }

    $result = Update-CsCustomPolicyPackage @setArgs | Select-Object *    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}