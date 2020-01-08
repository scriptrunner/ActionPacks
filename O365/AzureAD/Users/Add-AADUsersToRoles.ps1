#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and adds members to the roles
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Azure Active Directory Powershell Module v2
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Users

    .Parameter RoleIds
        Specifies the unique IDs of the roles to which to add members

    .Parameter RoleNames
        Specifies the display names of the roles to which to add members
    
    .Parameter UserIds
        Specifies the unique object IDs of the users to add to the roles

    .Parameter UserNames
        Specifies the display names or user principal names of the users to add to the roles
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Ids")]
    [guid[]]$RoleIds,
    [Parameter(Mandatory = $true,ParameterSetName = "Ids")]
    [guid[]]$UserIds,
    [Parameter(Mandatory = $true,ParameterSetName = "Names")]
    [string[]]$RoleNames,
    [Parameter(Mandatory = $true,ParameterSetName = "Names")]
    [string[]]$UserNames
)

try{
    $Script:result = @()
    $Script:err = $false
    if($PSCmdlet.ParameterSetName  -eq "Names"){
        $RoleIds=@()
        $tmp
        foreach($itm in $RoleNames){
            try{
                $tmp = Get-AzureADDirectoryRole | Where-Object -Property DisplayName -eq $itm 
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
                    $tmp = Get-AzureADUser -All $true | `
                        Where-Object {($_.DisplayName -eq $itm) -or ($_.UserPrincipalName -eq $itm)} 
                    $UserIds += $tmp.ObjectID
                }
                catch{
                    $Script:result += "Error: User $($itm) not found "
                    $Script:err = $true
                    continue
                }
            }
        }
    }
    $Script:Role
    foreach($id in $RoleIds){
        try{
            $Script:Role = Get-AzureADDirectoryRole -ObjectId $id | Select-Object ObjectID,DisplayName
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
                    $usr = Get-AzureADUser -ObjectId $itm | Select-Object ObjectID,DisplayName                
                }
                catch{
                    $Script:result += "Error: User $($itm) not found "
                    $Script:err = $true
                    continue
                }
                try{
                    $null = Add-AzureADDirectoryRoleMember -ObjectId $Script:Role.ObjectID -RefObjectId $usr.ObjectID -ErrorAction Stop
                    $Script:result += "User $($usr.DisplayName) added to Role $($Script:Role.DisplayName)"
                }
                catch{
                    $Script:result += "Error: User $($usr) $($_.Exception.Message)"
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
finally{
 
}