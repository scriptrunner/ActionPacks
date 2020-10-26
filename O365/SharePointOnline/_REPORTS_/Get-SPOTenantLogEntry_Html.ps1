#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Generates a report with SharePoint Online company logs
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/_REPORTS_

    .Parameter EndTime
        [sr-en] Specifies the end time to search for logs
        [sr-de] Gibt die Endzeit an, bis zu der nach Protokollen gesucht werden soll

    .Parameter StartTime
        [sr-en] Specifies the start time to search for logs
        [sr-de] Gibt die Startzeit an, ab wann nach Protokollen gesucht werden soll

    .Parameter MaxRows
        [sr-en] Specifies the maximum number of rows in the descending order of timestamp
        [sr-de] Maximale Anzahl der Zeilen in absteigender Reihenfolge
#>

param(   
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartTime,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndTime,
    [ValidateRange(1,5000)]
    [uint32]$MaxRows = 1000
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'MaxRows' = $MaxRows
                            }     

    if(($null -ne $StartTime) -and ($StartTime.Year -gt 2010)){
        $cmdArgs.Add('StartTimeInUtc', $StartTime)
    }  
    if(($null -ne $EndTime) -and ($EndTime.Year -gt 2010)){
        $cmdArgs.Add('EndTimeInUtc', $EndTime)
    } 

    $result = Get-SPOTenantLogEntry @cmdArgs | Select-Object *
      
    if($SRXEnv) {
        ConvertTo-ResultHtml -Result $result    
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}