#Requires -Version 4.0

<#
.SYNOPSIS
    Tests of a path exist

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/FolderAndFiles

.Parameter Path
    Specifies a path to be tested. Wildcard characters are permitted. If the path includes spaces, enclose it in quotation marks

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Path,    
    [PSCredential]$AccessAccount
)

try{
    [string]$Script:output
    if($null -eq $AccessAccount){
        if((Test-Path -Path $Path -ErrorAction Stop) -eq $true){
            $Script:output = "Path $($Path) exists"    
        }
        else {
            throw "Path $($Path) not exists"
        }
    }
    else {
        if((Test-Path -Path $Path -Credential $AccessAccount -ErrorAction Stop) -eq $true){
            $Script:output = "Path $($Path) exists"    
        }
        else {
            throw "Path $($Path) not exists"
        }
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}