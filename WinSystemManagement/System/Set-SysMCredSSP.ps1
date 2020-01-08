#Requires -Version 4.0

<#
.SYNOPSIS
    Set Credential Security Support Provider (CredSSP) authentication

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/System

.Parameter EnableCredSSP
    Enable or disable Credential Security Support Provider (CredSSP) authentication 

.Parameter Role
    Specifies whether to disable CredSSP as a client or as a server

.Parameter DelegateComputer 
    Specifies servers to which client credentials are delegated
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Server','Client')]
    [string]$Role,
    [bool]$EnableCredSSP,
    [string]$DelegateComputer
)

try{
    if($EnableCredSSP -eq $true){
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'Role' = $Role
                                'Force' = $true
                                }  
        if([System.String]::IsNullOrWhiteSpace($DelegateComputer) -eq $false){
            $cmdArgs.Add('DelegateComputer',$DelegateComputer)
        }
        $null = Enable-WSManCredSSP @cmdArgs
    }
    else{
        $null = Disable-WSManCredSSP -Role $Role -ErrorAction Stop
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "CredSSP enabled is $($EnableCredSSP.ToString())"
    }
    else{
        Write-Output "CredSSP enabled is $($EnableCredSSP.ToString())"
    }
}
catch{
    throw
}
finally{
}