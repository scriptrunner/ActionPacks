#Requires -Version 4.0

<#
.SYNOPSIS
    Changes permissions on a folder or file

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

.Parameter ObjectName
    Specifies the folder or file name with the path

.Parameter ModifyType
    Specifies the change type

.Parameter AccessControlType
    Specifies permission is set to allow or deny access

.Parameter AccessType
    Specifies the common access right to grant or denied to the trustee

.Parameter Permission
    Specifies the common or special access right to grant or denied to the trustee

.Parameter PermissionAccounts
    Specifies which accounts are granted or denied the permission to access the object, e.g. Contoso\John.Doe . Multiple accounts can be specified comma separated

.Parameter AccountsToBeAuthorize
    Specifies which accounts are granted or denied the special permissions to access the object, e.g. Contoso\John.Doe . Multiple accounts can be specified comma separated

.Parameter ChangePermissions
    Specifies the right to change the security and audit rules associated with a file or folder

.Parameter CreateDirectories
    Specifies the right to create a folder

.Parameter CreateFiles
    Specifies the right to create a file

.Parameter Delete
    Specifies the right to delete a folder or file

.Parameter DeleteSubdirectoriesAndFiles
    Specifies the right to delete a folder and any files contained within that folder

.Parameter ListDirectory
    Specifies the right to read the contents of a directory

.Parameter ReadPermissions
    Specifies the right to open and copy access and audit rules from a folder or file. This does not include the right to read data, file system attributes, and extended file system attributes

.Parameter ReadAttributes
    Specifies the right to open and copy file system attributes from a folder or file. For example, this value specifies the right to view the file creation or modified date. This does not include the right to read data, extended file system attributes, or access and audit rules

.Parameter ReadExtendedAttributes
    Specifies the right to open and copy extended file system attributes from a folder or file. For example, this value specifies the right to view author and content information. This does not include the right to read data, file system attributes, or access and audit rules

.Parameter WriteAttributes
    Specifies the right to open and write file system attributes to a folder or file. This does not include the ability to write data, extended attributes, or access and audit rules

.Parameter WriteExtendedAttributes
    Specifies the right to open and write extended file system attributes to a folder or file. This does not include the ability to write data, attributes, or access and audit rules

.Parameter TakeOwnership
    Specifies the right to change the owner of a folder or file. Note that owners of a resource have full access to that resource

.Parameter Traverse
    Specifies the right to list the contents of a folder and to run applications contained within that folder

.Parameter Inheritance
    Inheritance specify the inheritance for the object

.Parameter OnlyThisContainer
    Apply the permissions to objects and/or containers within this container only    
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Common permissions")]
    [string[]]$PermissionAccounts,
    [Parameter(Mandatory = $true,ParameterSetName = "Special permissions")]
    [string[]]$AccountsToBeAuthorize,
    [Parameter(Mandatory = $true,ParameterSetName = "Common permissions")]
    [Parameter(Mandatory = $true,ParameterSetName = "Special permissions")]
    [string]$ObjectName,
    [Parameter(Mandatory = $true,ParameterSetName = "Common permissions")]
    [Parameter(Mandatory = $true,ParameterSetName = "Special permissions")]
    [ValidateSet('Set','Remove')]
    [string]$ModifyType = "Set",
    [Parameter(Mandatory = $true,ParameterSetName = "Common permissions")]
    [Parameter(Mandatory = $true,ParameterSetName = "Special permissions")]
    [ValidateSet('Allow','Deny')]
    [string]$AccessControlType = "Allow",
    [Parameter(Mandatory = $true,ParameterSetName = "Common permissions")]
    [ValidateSet('Read','Modify','FullControl','Write','ReadAndExecute')]
    [string]$AccessType="Read",
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$ChangePermissions,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$CreateDirectories,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$CreateFiles,    
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$Delete,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$DeleteSubdirectoriesAndFiles,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$ListDirectory,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$ReadAttributes,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$WriteAttributes,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$ReadExtendedAttributes,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$WriteExtendedAttributes,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$ReadPermissions,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$TakeOwnership,
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$Traverse,
    [Parameter(ParameterSetName = "Common permissions")]
    [Parameter(ParameterSetName = "Special permissions")]
    [ValidateSet("ThisFolderOnly","ThisFolderSubfoldersAndFiles","ThisFolderAndSubfolders","ThisFolderAndFiles","SubfoldersAndFiles","SubfoldersOnly","FilesOnly")]
    [string]$Inheritance = "ThisFolderSubfoldersAndFiles",
    [Parameter(ParameterSetName = "Common permissions")]
    [Parameter(ParameterSetName = "Special permissions")]
    [switch]$OnlyThisContainer
)

$Script:output=@()
[string]$Script:Identity
try{
    $Script:objectItem = Get-Item -Path $ObjectName -ErrorAction Stop
    $Script:acl = Get-Acl -Path $ObjectName -ErrorAction Stop    
    # Check accounts
    function CheckIdentity([string] $Name){
        if(($Name -eq "Jeder") -or ($Name -eq "Everyone") -or ($Name -eq "S-1-1-0"))
        {
             $sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-1-0")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
    
        }
        elseif(($Name -eq "System") -or ($Name -eq "Local System") -or ($Name -eq "S-1-5-18"))
        {
             $sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
    
        }
        elseif(($Name -eq "Administratoren") -or ($Name -eq "Administrators") -or ($Name -eq "S-1-5-32-544"))
        {
             $sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
    
        }
        elseif(($Name -eq "Authenticated Users") -or ($Name -eq "Authentifizierte Benutzer") -or ($Name -eq "S-1-5-11"))
        {
             $sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-11")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
        }
        elseif(($Name -eq "Interactive") -or ($Name -eq "Interaktiv") -or ($Name -eq "S-1-5-4"))
        {
             $sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-4")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
    
        }
        elseif(($Name -eq "Users") -or($Name -eq "Benutzer") -or ($Name -eq "S-1-5-32-545"))
        {
             $sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-545")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
    
        }
        else{
            if($Name.IndexOf('\') -lt 0){ # no domain in account
                $tmp = New-Object System.Security.Principal.NTAccount($Name)
                $tmp = New-Object System.Security.Principal.SecurityIdentifier ($tmp.translate([System.Security.Principal.SecurityIdentifier]).value)
                $Name = $tmp.Translate([System.Security.Principal.NTAccount]).Value
            }            
            $Script:Identity=$Name
        }
    }    
    function RemoveSetRight($Permission){
        try{
            $propagation="None"
            $inherit="None, None"
            if($Script:objectItem.PSIsContainer -eq $true){
                if($Inheritance -eq "ThisFolderSubfoldersAndFiles"){
                    $inherit = "ContainerInherit,ObjectInherit"
                    if($OnlyThisContainer){
                        $propagation = "NoPropagateInherit"
                    }                
                }
                if($Inheritance -eq "ThisFolderAndSubfolders"){
                    $inherit = "ContainerInherit,None"
                }
                if($Inheritance -eq "ThisFolderAndFiles"){
                    $inherit = "ObjectInherit,None"
                }
                if($Inheritance -eq "SubfoldersAndFiles"){
                    $inherit = "ContainerInherit,ObjectInherit"
                    $propagation="InheritOnly"
                }
                if($Inheritance -eq "SubfoldersOnly"){
                    $inherit = "ContainerInherit,None"
                    $propagation="InheritOnly"
                }
                if($Inheritance -eq "FilesOnly"){
                    $inherit = "ObjectInherit,None"
                    $propagation="InheritOnly"
                }
            }
            $ACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                ($Script:Identity,$Permission, $inherit, $propagation, $AccessControlType)
            if( $AccessControlType -eq "Deny"){
                $del = "Allow"
            }
            else {
                $del = "Deny"
            }
            $delACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                ($Script:Identity,$Permission, $inherit, $propagation, $del)
            if($ModifyType -eq "Set"){
                if($PSCmdlet.ParameterSetName  -eq "Special permissions"){
                    $Modification = $False
                    $null = $Script:acl.ModifyAccessRule("Remove", $delACE,[ref]$Modification)
                    $null = $Script:acl.ModifyAccessRule("Add", $ACE,[ref]$Modification)    
                }
                else{
                    $null = $Script:acl.RemoveAccessRule($delACE)
                    $null = $Script:acl.SetAccessRule($ACE)
                }              
            }
            else {
                $null = $Script:acl.RemoveAccessRule($ACE)
            }            
            Set-Acl -Path $ObjectName -AclObject $Script:acl -ErrorAction Stop
            $Script:output += "Permission $($Permission) $($ModifyType) on file $($ObjectName) for $($Script:Identity)"
        }
        catch
        {$Script:output +="Error $($ModifyType) $($Permission) for $($Script:Identity) on file $($ObjectName) - $($_.Exception.Message)"}
    }
    # Set permission
    if($PSCmdlet.ParameterSetName  -eq "Special permissions"){
        $PermissionAccounts = $AccountsToBeAuthorize
    }
    foreach($rd in $PermissionAccounts){
        try{
            CheckIdentity $rd
            if($PSCmdlet.ParameterSetName  -eq "Common permissions"){
                RemoveSetRight $AccessType
            }
            else{
                if($ChangePermissions -eq $true){
                    RemoveSetRight "ChangePermissions"
                }
                if($CreateDirectories -eq $true){
                    RemoveSetRight "CreateDirectories"
                }
                if($CreateFiles -eq $true){
                    RemoveSetRight "CreateFiles"
                }
                if($Delete -eq $true){
                    RemoveSetRight "Delete"
                }
                if($DeleteSubdirectoriesAndFiles -eq $true){
                    RemoveSetRight "DeleteSubdirectoriesAndFiles"
                }
                if($ListDirectory -eq $true){
                    RemoveSetRight "ListDirectory"
                }
                if($ReadAttributes -eq $true){
                    RemoveSetRight "ReadAttributes"
                }
                if($WriteAttributes -eq $true){
                    RemoveSetRight "WriteAttributes"
                }
                if($ReadExtendedAttributes -eq $true){
                    RemoveSetRight "ReadExtendedAttributes"
                }
                if($WriteExtendedAttributes -eq $true){
                    RemoveSetRight "WriteExtendedAttributes"
                }
                if($ReadPermissions -eq $true){
                    RemoveSetRight "ReadPermissions"
                }
                if($TakeOwnership -eq $true){
                    RemoveSetRight "TakeOwnership"
                }
                if($Traverse -eq $true){
                    RemoveSetRight "Traverse"
                }
            }
        }
        catch{
            $Script:output +="Error change permissions for $($Script:Identity) on file $($ObjectName) - $($_.Exception.Message)"
        }
    }
  
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output        
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}