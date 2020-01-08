#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and adds members to Azure Active Directory roles
        Group is not currently supported.
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Azure Active Directory Powershell Module v1
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/Users

    .Parameter RoleIds
        Specifies the unique IDs of the roles to which to add members

    .Parameter RoleNames
        Specifies the names of the roles to which to add members
    
    .Parameter UserIds
        Specifies the unique object IDs of the users to add to the roles

    .Parameter UserNames
        Specifies the Display names, Sign-In Name or user principal names of the users to add to the roles

    .Parameter ServicePrincipalIds
        Specifies the unique object IDs of the service principals to add to the roles

    .Parameter ServicePrincipalNames
        Specifies the Display names of the service principals to add to the roles

    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Ids")]
    [guid[]]$RoleIds,
    [Parameter(ParameterSetName = "Ids")]
    [guid[]]$UserIds,
    [Parameter(ParameterSetName = "Ids")]
    [guid[]]$ServicePrincipalIds,
    [Parameter(Mandatory = $true,ParameterSetName = "Names")]
    [string[]]$RoleNames,
    [Parameter(ParameterSetName = "Names")]
    [string[]]$UserNames,
    [Parameter(ParameterSetName = "Names")]
    [string[]]$ServicePrincipalNames,
    [Parameter(ParameterSetName = "Names")]
    [Parameter(ParameterSetName = "Ids")]    
    [guid]$TenantId
)

try{
    $Script:result = @()
    $Script:err = $false
    if($PSCmdlet.ParameterSetName  -eq "Names"){
        $RoleIds=@()
        $tmp
        foreach($itm in $RoleNames){
            try{
                $tmp = Get-MsolRole -TenantId $TenantId | Where-Object -Property Name -eq $itm #| Select-Object ObjectID
                $RoleIds += $tmp.ObjectID
            }
            catch{
                $Script:result += "Error: Role $($itm) not found "
                $Script:err = $true
                continue
            }
        }
        if($null -ne $UserNames){
            $UserIds=@()
            foreach($itm in $UserNames){
                try{
                    $tmp = Get-MsolUser -TenantId $TenantId | `
                        Where-Object {($_.DisplayName -eq $itm) -or ($_.SignInName -eq $itm) -or ($_.UserPrincipalName -eq $itm)} 
                    $UserIds += $tmp.ObjectID
                }
                catch{
                    $Script:result += "Error: User $($itm) not found "
                    $Script:err = $true
                    continue
                }
            }
        }
        if($null -ne $ServicePrincipalNames){
            $ServicePrincipalIds=@()
            foreach($itm in $ServicePrincipalNames){
                try{
                    $tmp = Get-MsolServicePrincipal -TenantId $TenantId | Where-Object -Property DisplayName -eq $itm
                    $ServicePrincipalIds += $tmp.ObjectID
                }
                catch{
                    $Script:result += "Error: Service principal $($itm) not found "
                    $Script:err = $true
                    continue
                }
            }
        }
    }
    $Script:Role
    foreach($id in $RoleIds){
        try{
            $role = Get-MsolRole -ObjectId $id -TenantId $TenantId | Select-Object ObjectID,Name
        }
        catch{
            $Script:result += "Error: Role $($id) not found "
            $Script:err = $true
            continue
        }    
        if($null -ne $UserIds){
            $usr=$null
            foreach($itm in $UserIds){
                try{
                    $usr = Get-MsolUser -ObjectId $itm -TenantId $TenantId | Select-Object ObjectID,DisplayName                
                }
                catch{
                    $Script:result += "Error: User $($itm) not found "
                    $Script:err = $true
                    continue
                }
                try{
                    $null = Add-MsolRoleMember -TenantId $TenantId -RoleObjectId $role.ObjectID -RoleMemberObjectId $usr.ObjectID -RoleMemberType 'User'
                    $Script:result += "User $($usr.DisplayName) added to Role $($role.Name)"
                }
                catch{
                    $Script:result += "Error: User $($usr) $($_.Exception.Message)"
                    $Script:err = $true
                    continue
                }
            }
        }
        if($null -ne $ServicePrincipalIds){
            $srv=$null
            foreach($itm in $ServicePrincipalIds){
                try{
                    $srv = Get-MsolServicePrincipal -ObjectId $itm -TenantId $TenantId | Select-Object ObjectID,DisplayName                
                }
                catch{
                    $Script:result += "Error: Service principal $($itm) not found "
                    $Script:err = $true
                    continue
                }
                try{
                    $null = Add-MsolRoleMember -TenantId $TenantId -RoleObjectId $role.ObjectID -RoleMemberObjectId $srv.ObjectID -RoleMemberType 'ServicePrincipal'
                    $Script:result += "Service principal $($srv.DisplayName) added to Role $($role.Name)"
                }
                catch{
                    $Script:result += "Error: Service principal $($srv) $($_.Exception.Message)"
                    $Script:err = $true
                    continue
                }
            }
        }
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:result
        if($Script:err -eq $true){
            Throw $($Script:result -join ' ')
        }
    } 
    else{    
        Write-Output $Script:result 
    }
}
catch{
    throw
}