#Requires -Version 4.0

<#
.SYNOPSIS
    Starts a stopped service 

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
    Specifies the name of service to be started

.Parameter ServiceDisplayName
    Specifies the display name of service to be started
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [string]$ServiceName,
    [string]$ServiceDisplayName
)

try{
    [string[]]$Properties = @('Name','DisplayName','Status','RequiredServices','DependentServices','CanStop','CanShutdown','CanPauseAndContinue')
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $ComputerName = "."
    }

    if([System.String]::IsNullOrWhiteSpace($ServiceName) -eq $false){
        $Script:srv = Get-Service -ComputerName $ComputerName -Name $ServiceName -ErrorAction Stop 
    }
    elseif([System.String]::IsNullOrWhiteSpace($ServiceDisplayName) -eq $false){
        $Script:srv = Get-Service -ComputerName $ComputerName -DisplayName $ServiceDisplayName -ErrorAction Stop 
    }
    $null = Start-Service -InputObject $Script:srv -Confirm:$false -ErrorAction Stop

    $result = Get-Service -ComputerName $ComputerName -Name $Script:srv.Name -ErrorAction Stop | Select-Object $Properties
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