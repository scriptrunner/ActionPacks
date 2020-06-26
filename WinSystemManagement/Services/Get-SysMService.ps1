#Requires -Version 4.0

<#
.SYNOPSIS
    Gets one or all services on a computer

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
    Specifies the name of service to be retrieved. If name and display name not specified, all services retrieved 

.Parameter ServiceDisplayName
    Specifies the display name of service to be retrieved. If name and display name not specified, all services retrieved 

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [string]$ServiceName,
    [string]$ServiceDisplayName ,
    [ValidateSet('*','Name','DisplayName','Status','RequiredServices','DependentServices','CanStop','CanShutdown','CanPauseAndContinue')]
    [string[]]$Properties = @('Name','DisplayName','Status','RequiredServices','DependentServices','CanStop','CanShutdown','CanPauseAndContinue')
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $ComputerName = "."
    }
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    else{
        if($null -eq ($Properties | Where-Object {$_ -like 'DisplayName'})){
            $Properties += "DisplayName"
        }
    }
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ComputerName' = $ComputerName}
    if([System.String]::IsNullOrWhiteSpace($ServiceName) -eq $false){
        $cmdArgs.Add('Name', $ServiceName)
    }
    elseif([System.String]::IsNullOrWhiteSpace($ServiceDisplayName) -eq $false){
        $cmdArgs.Add('DisplayName', $ServiceDisplayName)
    }

    $result = Get-Service @cmdArgs | Select-Object $Properties `
                         | Sort-Object DisplayName | Format-List

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