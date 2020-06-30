#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with one or all services on a computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/_REPORTS_ 

.Parameter ComputerName
    Gets the service running on the specified computer. The default is the local computer

.Parameter ServiceName
    Specifies the name of service to be retrieved. If name and display name not specified, all services retrieved 

.Parameter ServiceDisplayName
    Specifies the display name of service to be retrieved. If name and display name not specified, all services retrieved 
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [string]$ServiceName,
    [string]$ServiceDisplayName     
)

try{
    [string[]]$Properties = @('Name','DisplayName','Status','StartType')
    $Script:output = @()
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $ComputerName = "."
    }
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ComputerName' = $ComputerName}
    if([System.String]::IsNullOrWhiteSpace($ServiceName) -eq $false){
        $cmdArgs.Add('Name', $ServiceName)
    }
    elseif([System.String]::IsNullOrWhiteSpace($ServiceDisplayName) -eq $false){
        $cmdArgs.Add('DisplayName', $ServiceDisplayName)
    }

    $null = Get-Service @cmdArgs | Select-Object $Properties `
                         | Sort-Object DisplayName | ForEach-Object{
                            $Script:output +=  [PSCustomObject] @{
                                'Name' = $_.Name;                                
                                'DisplayName' = $_.DisplayName;
                                'Status' = $_.Status;
                                'StartType' = $_.StartType
                            }
                         }

    ConvertTo-ResultHtml -Result $Script:output
}
catch{
    throw
}
finally{
}