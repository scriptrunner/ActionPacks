#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Creates a new SharePoint Online site collection for the current company
    
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
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Sites

    .Parameter Identity
        Specifies the URL of the site collection to update
    
    .Parameter Owner
        Specifies the user name of the site collection’s primary owner

    .Parameter StorageQuota
        Specifies the storage quota for this site collection in megabytes
 
    .Parameter Url
        Specifies the full URL of the new site collection

    .Parameter Title
        Specifies the title of the site collection

    .Parameter CompatibilityLevel
        Specifies the version of templates to use when you are creating a new site collection

    .Parameter LocaleId
        Specifies the language of this site collection

    .Parameter NoWait
        Specifies to continue executing script immediately
    
    .Parameter ResourceQuota
        Specifies the quota for this site collection in Sandboxed Solutions units
    
    .Parameter Template
        Specifies the site collection template type

    .Parameter TimeZoneId
        Specifies the time zone of the site collection
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Owner,
    [Parameter(Mandatory = $true)]         
    [int64]$StorageQuota,
    [Parameter(Mandatory = $true)]        
    [string]$Url,
    [string]$Title,
    [int]$CompatibilityLevel,
    [uint32]$LocaleId,
    [switch]$NoWait,
    [double]$ResourceQuota,
    [string]$Template,
    [int]$TimeZoneId
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Owner' = $Owner
                            'StorageQuota' = $StorageQuota
                            'Url' = $Url
                            'NoWait' = $NoWait
                            }      
                  
    if($PSBoundParameters.ContainsKey('Title')){
        $cmdArgs.Add('Title' , $Title)
    }  
    if($PSBoundParameters.ContainsKey('Template')){
        $cmdArgs.Add('Template' , $Template)
    }  
    if($CompatibilityLevel -gt 0){
        $cmdArgs.Add('CompatibilityLevel' , $CompatibilityLevel)
    }
    if($LocaleId -gt 0){
        $cmdArgs.Add('LocaleId' , $LocaleId)
    }
    if($ResourceQuota -gt 0){
        $cmdArgs.Add('ResourceQuota' , $ResourceQuota)
    }
    if($TimeZoneId -gt 0){
        $cmdArgs.Add('TimeZoneId' , $TimeZoneId)
    }

    $null = New-SPOSite @cmdArgs
    $result = "Site $($Url) created"

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
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