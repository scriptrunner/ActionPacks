#Requires -Version 6.0

<#
.SYNOPSIS
    Removes a Windows service

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Services

.Parameter ComputerName
    Gets the service running on the specified computer. The default is the local computer

.Parameter ServiceName
    Specifies the name of service to be removed

.Parameter ServiceDisplayName
    Specifies the display name of service to be removed
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [string]$ServiceName,
    [string]$ServiceDisplayName
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $ComputerName = "."
    }

    if([System.String]::IsNullOrWhiteSpace($ServiceName) -eq $false){
        $Script:srv = Get-Service -ComputerName $ComputerName -Name $ServiceName -ErrorAction Stop 
    }
    elseif([System.String]::IsNullOrWhiteSpace($ServiceDisplayName) -eq $false){
        $Script:srv = Get-Service -ComputerName $ComputerName -DisplayName $ServiceDisplayName -ErrorAction Stop 
    }
    $null = Remove-Service -InputObject $Script:srv -Confirm:$false -ErrorAction Stop

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Service $($Script:srv.DisplayName) removed"
    }
    else{
        Write-Output "Service $($Script:srv.DisplayName) removed"
    }
}
catch{
    throw
}
finally{
}