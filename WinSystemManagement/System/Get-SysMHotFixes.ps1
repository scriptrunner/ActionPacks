#Requires -Version 4.0

<#
.SYNOPSIS
    Gets the hotfixes that have been applied to the local and remote computer

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

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. HotFixID,Caption. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [ValidateSet('*','Caption','Description','HotFixID','InstallDate','InstalledBy','FixComments')]
    [string[]]$Properties = @('Caption','Description','HotFixID','InstallDate','InstalledBy','FixComments')
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    }
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    if($null -eq $AccessAccount){
        $Script:output = Get-HotFix -ComputerName $ComputerName -ErrorAction Stop | Select-Object $Properties
    }
    else {
        $Script:output = Get-HotFix -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop | Select-Object $Properties
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