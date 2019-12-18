#Requires -Version 4.0

<#
.SYNOPSIS
    Moves the specified folder

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT    

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/FolderAndFiles

.Parameter FolderName
    Specifies the folder name with the path

.Parameter Destination
    Specifies the path to the location where the folder are being moved
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [PSCredential]$AccessAccount
)

try{
    if($null -eq $AccessAccount){
        if( (Test-Path -Path $Destination) -eq $false){
            throw "Destination $($Destination) not exists"
        }
    }
    else {
        if((Test-Path -Path $Destination -Credential $AccessAccount) -eq $false){
            throw "Destination $($Destination) not exists"
        }
    }     
    if($null -eq $AccessAccount){
        $null = Move-Item -Path $FolderName -Destination $Destination -Force -ErrorAction Stop
    }
    else {
        $null = Move-Item -Path $FolderName -Destination $Destination -Credential $AccessAccount -Force -ErrorAction Stop
    }    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Folder $($FolderName) moved to $($Destination)"
    }
    else{
        Write-Output "Folder $($FolderName) moved to $($Destination)"
    }
}
catch{
    throw
}
finally{
}