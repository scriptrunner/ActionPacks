#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Generates a report with all the installed applications from an external marketplace or from the App Catalog that contain Name in their application names 
        or the installed application with mentioned ProductId
    
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

    .Parameter Name
        [sr-en] Specifies the application’s name
        [sr-de] Name der Anwendung

    .Parameter ProductID
        [sr-en] Specifies the application’s GUID
        [sr-de] GUID der Anwendung
#>

param(   
    [Parameter(Mandatory = $true,ParameterSetName='ByName')]  
    [string]$Name,    
    [Parameter(Mandatory = $true,ParameterSetName='ByID')]  
    [string]$ProductID
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [string[]]$Properties = @('Name','Source','ProductId')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}

    if($PSCmdlet.ParameterSetName -eq 'ByName'){
        $cmdArgs.Add('Name',$Name)
    }
    else{
        $cmdArgs.Add('ProductID',$ProductID)
    }

    $result = Get-SPOAppInfo @cmdArgs | Select-Object $Properties
      
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