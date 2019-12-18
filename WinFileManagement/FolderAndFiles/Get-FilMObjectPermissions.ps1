#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves the permissions of a folder or file

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

.Parameter ObjectClass
    Specifies the type of the accounts

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ObjectName,
    [Parameter(Mandatory = $true)]
    [ValidateSet("All","Groups","Users")]
    [string]$ObjectClass="All"
)

[System.Reflection.Assembly]::LoadWithPartialName('System.DirectoryServices.AccountManagement')

try{
    $Script:output=@()
    [bool]$Script:IsGroup = $false
    [bool]$Script:IsUser = $false

    function CheckIdentity([string] $Name){
        if($ObjectClass -eq "All"){
            $Script:IsGroup=$true
            $Script:IsUser=$true
            return
        }
        $Script:IsGroup=$false
        $Script:IsUser=$false
        $tmp = New-Object System.Security.Principal.NTAccount($Name)
        try{
            $sid = $tmp.Translate([System.Security.Principal.SecurityIdentifier]).Value
        }
        catch
        {
            return
        }
        if($sid -eq "S-1-1-0") # Everyone
        {
            $Script:IsGroup=$true    
        }
        elseif($sid -eq  "S-1-5-18") # System
        {
            $Script:IsGroup=$true    
        }
        elseif($sid -eq  "S-1-5-32-544") # Administrators
        {
            $Script:IsGroup=$true
    
        }
        elseif($sid -eq  "S-1-5-11") # Authenticated Users
        {
            $Script:IsGroup=$true
        }
        elseif($sid -eq  "S-1-5-4") # Interactive
        {
            $Script:IsGroup=$true
        }
        elseif($sid -eq  "S-1-5-32-545") # Users
        {
            $Script:IsGroup=$true    
        }
        else{
            $tmp = New-Object System.Security.Principal.SecurityIdentifier ($sid) 
            $tmp=$tmp.Translate([System.Security.Principal.NTAccount]).Value
            $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $tmp.Split("\")[0])
            $chk=[System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($ctx, [System.DirectoryServices.AccountManagement.IdentityType]::SID, $sid)
            $Script:IsGroup = ($null -ne $chk)
            $chk=[System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($ctx, [System.DirectoryServices.AccountManagement.IdentityType]::Sid, $sid)
            $Script:IsUser = ($null -ne $chk)
        }
    }

    $Script:acl = Get-Acl -Path $ObjectName -ErrorAction Stop
    foreach($item in $Script:acl.Access){
        CheckIdentity $item.IdentityReference
        if($Script:IsGroup -eq $true -and $ObjectClass -ne "Users"){
            $Script:output += $item
        }
        if($Script:IsUser -eq $true -and $ObjectClass -ne "Groups"){
            $Script:output += $item
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