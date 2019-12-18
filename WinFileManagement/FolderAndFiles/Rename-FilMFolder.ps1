#Requires -Version 4.0

<#
.SYNOPSIS
    Renames the specified folder

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    � ScriptRunner Software GmbH

.COMPONENT    

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/FolderAndFiles

.Parameter FolderName
    Specifies the folder name with the path

.Parameter NewName
    Specifies the new name of the folder, only the name without the path
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [Parameter(Mandatory = $true)]
    [string]$NewName,
    [PSCredential]$AccessAccount
)

try{   
    if($null -eq $AccessAccount){
        $null = Rename-Item -Path $FolderName -NewName $NewName -Force -ErrorAction Stop
    }
    else {
        $null = Rename-Item -Path $FolderName -NewName $NewName -Credential $AccessAccount -Force -ErrorAction Stop
    }   
     
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Folder $($FolderName) renamed to $($NewName)"
    }
    else{
        Write-Output "Folder $($FolderName) renamed to $($NewName)"
    }
}
catch{
    throw
}
finally{
}