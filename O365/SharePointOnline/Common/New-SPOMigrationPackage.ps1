#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Create a new migration package based on source files in a local or network shared folder
    
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

    .Parameter OutputPackagePath
        The directory location where the output package metadata files will be saved

    .Parameter SourceFilesPath
        The directory location where the source content files exist

    .Parameter IgnoreHidden
        Ignore hidden files and folders

    .Parameter IncludeFileSharePermissions
        Used to include permissions and sharing information into the generated manifest files in the package metadata

    .Parameter NoAzureADLookup
        Not lookup local user accounts in Azure Active Directory

    .Parameter NoLogFile
        Used to not create a log file

    .Parameter ReplaceInvalidCharacters
        Replace characters in file and folder names that would be invalid in SharePoint Online

    .Parameter TargetDocumentLibraryPath
        The web relative document library to use as the document library part of the base URL in the package metadata

    .Parameter TargetDocumentLibrarySubFolderPath
        Specifies the document library relative subfolder to use as the folder path part of the base URL in the package metadata

    .Parameter TargetWebUrl
        The fully qualified web URL to use as the web address part of the base URL in the package metadata
#>

param(     
    [Parameter(Mandatory = $true)]
    [string]$OutputPackagePath,
    [Parameter(Mandatory = $true)]
    [string]$SourceFilesPath,
    [switch]$IgnoreHidden,
    [switch]$IncludeFileSharePermissions,
    [switch]$NoAzureADLookup,
    [switch]$NoLogFile,
    [switch]$ReplaceInvalidCharacters,
    [string]$TargetDocumentLibraryPath,
    [string]$TargetDocumentLibrarySubFolderPath,
    [string]$TargetWebUrl
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'OutputPackagePath' = $OutputPackagePath
                            'SourceFilesPath' = $SourceFilesPath
                            'IgnoreHidden' = $IgnoreHidden                            
                            'NoAzureADLookup' = $NoAzureADLookup
                            'NoLogFile' = $NoLogFile
                            'ReplaceInvalidCharacters' = $ReplaceInvalidCharacters
                            'IncludeFileSharePermissions' = $IncludeFileSharePermissions
                            }

    if($PSBoundParameters.ContainsKey('TargetDocumentLibraryPath')){
        $cmdArgs.Add('TargetDocumentLibraryPath',$TargetDocumentLibraryPath)
    }
    if($PSBoundParameters.ContainsKey('TargetDocumentLibrarySubFolderPath')){
        $cmdArgs.Add('TargetDocumentLibrarySubFolderPath',$TargetDocumentLibrarySubFolderPath)
    }
    if($PSBoundParameters.ContainsKey('TargetWebUrl')){
        $cmdArgs.Add('TargetWebUrl',$TargetWebUrl)
    }

    $result = New-SPOMigrationPackage @cmdArgs | Select-Object *
      
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