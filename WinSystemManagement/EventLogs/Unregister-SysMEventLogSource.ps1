#Requires -Version 4.0

<#
.SYNOPSIS
    Unregisters an event source

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/EventLogs

.Parameter Source
    Specifies the event source that unregisters. Enter the source name, not the executable name

.Parameter ComputerName
    Specifies remote computer, the default is the local computer.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Source,
    [string]$ComputerName
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    } 
    $null = Remove-EventLog -ComputerName $ComputerName -Source $Source -Confirm:$false -ErrorAction Stop
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Source: $($Source) removed"
    }
    else{
        Write-Output "Source: $($Source) removed"
    }
}
catch{
    throw
}
finally{
}