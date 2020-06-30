#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with the largest sub folders below the start folder

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/_REPORTS_

.Parameter StartFolder
    Specifies the start folder of the evaluation 

.Parameter Top
    Specifies the number of rankings
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('UserProfiles','ProgramFiles')]
    [string]$StartFolder = 'ProgramFiles',
    [int]$Top = 10
)

try{
    $Script:output=@()
    [string]$start = ''
    
    switch ($StartFolder){
        'UserProfiles'{
            $start  = [Environment]::GetEnvironmentVariable('Public')
            $start = $start.Substring(0,$start.LastIndexOf('\'))
        }
        default{
            $start  = [Environment]::GetEnvironmentVariable($StartFolder)
        }
    }    
    
    $result = Get-ChildItem -Path $start -Directory -Recurse -Force -ErrorAction Ignore | Select-Object FullName | `
        ForEach-Object {
            [PSCustomObject] @{
                FullName = $_.FullName;
                Sum =  (Get-ChildItem -Path $_.FullName -File -Force -ErrorAction Ignore | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum)
            }
    }  | Sort-Object -Descending Sum | Select-Object -First $Top
    
    $result = $result|  ForEach-Object {
        [PSCustomObject] @{
            FullName = $_.FullName;
            'Sum (MB)' = ([math]::round($_.Sum/1MB ,3));
            'Sum (GB)' = ([math]::round($_.Sum/1GB ,3))
        }
    }
    
    ConvertTo-ResultHtml -Result $result
}
catch{
    throw
}
finally{ 
}