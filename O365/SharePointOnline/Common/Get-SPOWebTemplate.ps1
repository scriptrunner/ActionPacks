#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Displays all site templates that match the given identity
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Common

    .Parameter CompatibilityLevel
        Specifies the compatibility level of the site template

    .Parameter LocaleId
        Specifies the Locale ID of the site template

    .Parameter Name
        Specifies the name of the site template

    .Parameter Title
        Specifies the title of the site template
#>

param(  
    [int]$CompatibilityLevel,
    [uint32]$LocaleId,
    [string]$Name,
    [string]$Title  
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}

    if($PSBoundParameters.ContainsKey('Name')){
        $cmdArgs.Add('Name',$Name)
    }
    if($PSBoundParameters.ContainsKey('Title')){
        $cmdArgs.Add('Title',$Title)
    }
    if($CompatibilityLevel -gt 0){
        $cmdArgs.Add('CompatibilityLevel',$CompatibilityLevel)
    }
    if($LocaleId -gt 0){
        $cmdArgs.Add('LocaleId',$LocaleId)
    }
    
    $result = Get-SPOWebTemplate @cmdArgs | Select-Object *
      
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