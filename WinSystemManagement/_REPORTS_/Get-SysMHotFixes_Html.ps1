#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with the hotfixes that have been applied to the local and remote computer

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
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Last
    Specifies the number of last fixes
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [int]$Last = 25
)

try{
    [string[]]$Properties = @('Caption','Description','HotFixID','InstalledOn','InstalledBy','FixComments')
    $Script:output = @()
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ComputerName' = $ComputerName
                            }
    if($null -ne $AccessAccount){
        $cmdArgs.Add('Credential' ,$AccessAccount)
    }
    Get-HotFix @cmdArgs | Sort-Object InstalledOn -Descending | Select-Object $Properties -First $Last | ForEach-Object{
        $Script:output += New-Object PSObject -Property ([ordered] @{
            HotFixID = $_.HotFixID
            Date = $_.InstalledOn
            By = $_.InstalledBy
            Caption = $_.Caption
            Description = $_.Description
            Comments = $_.FixComments
        })
    }

    ConvertTo-ResultHtml -Result $output -CreateHttpLinks
}
catch{
    throw
}
finally{
}