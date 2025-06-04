#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets the Storage resource usage of the current subscription
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Storage

    .Parameter Location
        [sr-en] Get Storage resources usage on the specified location
        [sr-de] Nutzung von Storage Ressourcen der Location abrufen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Location
)

Import-Module Az.Storage

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Location' = $Location
    }
    
    $ret = Get-AzStorageUsage @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}