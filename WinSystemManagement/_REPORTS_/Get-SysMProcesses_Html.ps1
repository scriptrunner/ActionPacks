#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with processes that are running on the local computer or a remote computer

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
#>

[CmdLetBinding()]
Param(
)

try{
    [string[]]$Properties = @('ID','Name','PM','Cpu','Description','TotalProcessorTime','StartTime')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'IncludeUserName' = $true
                            'Name' = '*'
                            }
    $output = Get-Process @cmdArgs | Select-Object $Properties | Sort-Object Name | `
                            Where-Object {$_.ID -gt 0} | ForEach-Object {
                                [PSCustomObject] @{
                                    'ID' = $_.ID;
                                    'Name' = $_.Name;
                                    'PM (KB)' = ([math]::round($_.PM/1KB,3));
                                    'CPU (Sec)' = ([math]::round($_.CPU/1000 ,3));
                                    'TotalProcessorTime' = $_.TotalProcessorTime;
                                    'TotalRunningTime' = (Get-Date).Subtract(($_.StartTime));
                                    'Description' = $_.Description
                                }
                            } 	
    ConvertTo-ResultHtml -Result $output                            
}
catch{
    throw
}
finally{
}