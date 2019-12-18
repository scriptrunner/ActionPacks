#Requires -Version 4.0

<#
.SYNOPSIS
    Creates an folder and sets the permissions for the accounts

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
    Specifies a name for the folder

.Parameter Path
    Specifies the path of the folder location
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter ModifyAccess
    Specifies which accounts are granted modify permission to access the folder. Multiple accounts can be specified comma separated

.Parameter FullControlAccess
    Specifies which accounts are granted full control permission to access the folder. Multiple accounts can be specified comma separated

.Parameter ReadAccess
    Specifies which accounts are granted read permission to access the folder. Multiple accounts can be specified comma separated

.Parameter ReadAndExecuteAccess
    Specifies which accounts are granted read and execute permission to access the folder. Multiple accounts can be specified comma separated

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [Parameter(Mandatory = $true)]
    [string]$Path,
  #  [PSCredential]$AccessAccount,
    [string[]]$ModifyAccess,
    [string[]]$FullControlAccess,
    [string[]]$ReadAccess,
    [string[]]$ReadAndExecuteAccess
)

[string]$Script:Identity
$Script:output=@()
[string[]]$Script:Properties = @("Name","FullName","CreationTime","Root")
try{
    function CheckIdentity([string] $Name){
        $Name = $Name.Trim()
        if(($Name -eq "Jeder") -or ($Name -eq "Everyone") -or ($Name -eq "S-1-1-0"))
        {
             $sid =New-Object System.Security.Principal.SecurityIdentifier("S-1-1-0")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
    
        }
        elseif(($Name -eq "System") -or ($Name -eq "Local System") -or ($Name -eq "S-1-5-18"))
        {
             $sid =New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
    
        }
        elseif(($Name -eq "Administratoren") -or ($Name -eq "Administrators") -or ($Name -eq "S-1-5-32-544"))
        {
             $sid =New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
    
        }
        elseif(($Name -eq "Authenticated Users") -or ($Name -eq "Authentifizierte Benutzer") -or ($Name -eq "S-1-5-11"))
        {
             $sid =New-Object System.Security.Principal.SecurityIdentifier("S-1-5-11")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
        }
        elseif(($Name -eq "Interactive") -or ($Name -eq "Interaktiv") -or ($Name -eq "S-1-5-4"))
        {
             $sid =New-Object System.Security.Principal.SecurityIdentifier("S-1-5-4")
             $Script:Identity= $sid.Translate([System.Security.Principal.NTAccount]).Value
    
        }
        elseif(($Name -eq "Users") -or($Name -eq "Benutzer") -or ($Name -eq "S-1-5-32-545"))
        {
             $sid =New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-545")
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
    function SetAccess($Permission){
        try{
            $ACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                ($Script:Identity,$Permission, "ContainerInherit,ObjectInherit", "NoPropagateInherit", "Allow")
            $null = $Script:acl.SetAccessRule($ACE)
            Set-Acl -Path $newFolder -AclObject $Script:acl -ErrorAction Stop
            $Script:output += "$($Permission) access set for $($Script:Identity)"
        }
        catch
        {$Script:output +="Error set $($Permission) access for $($Script:Identity) - $($_.Exception.Message)"}
    }
 #   if($null -eq $AccessAccount){
        $tmp = New-Item -Name $FolderName -Path $Path -ItemType "directory"  -ErrorAction Stop
  #  }
  #  else{
   #     $tmp = New-Item -Name $FolderName -Path $Path -ItemType "directory"  -Credential $AccessAccount -ErrorAction Stop
   # }
    $newFolder = "$($Path)\$($FolderName)"
    $Script:acl = Get-Acl -Path $newFolder -ErrorAction Stop    
    # Modify access
    if(-not [System.String]::IsNullOrWhiteSpace($ModifyAccess)){
        foreach($chn in $ModifyAccess){
            try{
                CheckIdentity $chn
                SetAccess "Modify"
            }
            catch
            {$Script:output +="Error set Modify access for $($chn) - $($_.Exception.Message)"}
        }
    } 
    # Read access
    if(-not [System.String]::IsNullOrWhiteSpace($ReadAccess)){
        foreach($rd in $ReadAccess){
            try{
                CheckIdentity $rd
                SetAccess "Read"
            }
            catch
            {$Script:output +="Error set Read access for $($rd) - $($_.Exception.Message)"}
        }
    } 
    # Full access
    if(-not [System.String]::IsNullOrWhiteSpace($FullControlAccess)){
        foreach($fa in $FullControlAccess){
            try{
                CheckIdentity $fa
                SetAccess "FullControl"
            }
            catch
            {$Script:output +="Error set FullControl access for $($fa) - $($_.Exception.Message)"}
        }
    } 
    # Read and execute
    if(-not [System.String]::IsNullOrWhiteSpace($ReadAndExecuteAccess)){
        foreach($no in $ReadAndExecuteAccess){
            try{
                CheckIdentity $no
                SetAccess "ReadAndExecute"
            }
            catch
            {$Script:output +="Error set ReadAndExecute access for $($no) - $($_.Exception.Message)"}
        }
    } 
    
    $Script:output += Get-Item -Path $newFolder `
                    | Select-Object @($Script:Properties) | Format-List
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