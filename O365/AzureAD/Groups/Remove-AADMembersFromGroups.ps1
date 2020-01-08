#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and removes members from the groups
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Groups

    .Parameter TargetGroupNames
        Specifies the display names of the groups to which to remove members

    .Parameter GroupNames
        Specifies the display names of the groups to remove from the target groups

    .Parameter UserNames
        Specifies the display names or user principal names of the users to remove from the target groups
    
    .Parameter GroupObjectIds
        Specifies the unique IDs of the groups to which to remove members

    .Parameter GroupIds
        Specifies the unique object IDs of the groups to remove from the group

    .Parameter UserIds
        Specifies the unique object IDs of the users to remove from the group
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Names")]
    [string[]]$TargetGroupNames,
    [Parameter(ParameterSetName = "Names")]
    [string[]]$UserNames,
    [Parameter(ParameterSetName = "Names")]
    [string[]]$GroupNames,
    [Parameter(Mandatory = $true,ParameterSetName = "IDs")]
    [guid[]]$GroupObjectIds,
    [Parameter(ParameterSetName = "IDs")]
    [guid[]]$GroupIds,
    [Parameter(ParameterSetName = "IDs")]
    [guid[]]$UserIds
)

try{
    $Script:result = @()
    $Script:err = $false
    if($PSCmdlet.ParameterSetName  -eq "Names"){
        $GroupObjectIds=@()
        $tmp
        foreach($itm in $TargetGroupNames){
            try{
                $tmp = Get-AzureADGroup -All $true | Where-Object -Property DisplayName -eq $itm 
                $GroupObjectIds += $tmp.ObjectID
            }
            catch{
                $Script:result += "Error: Target group $($itm) not found "
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
        if($null -ne $GroupNames){
            $GroupIds=@()
            foreach($itm in $GroupNames){
                try{
                    $tmp = Get-AzureADGroup -All $true | Where-Object -Property DisplayName -eq $itm
                    $GroupIds += $tmp.ObjectID
                }
                catch{
                    $Script:result += "Error:Group $($itm) not found"
                    $Script:err = $true
                    continue
                }
            }
        }
    }
    forEach($gid in $GroupObjectIds){
        try{
            $grp = Get-AzureADGroup -ObjectId $gid
        }
        catch{
            $Script:result += "Error: GroupObjectID $($gid) $($_.Exception.Message)"
            $Script:err = $true
            continue
        }
        if($null -ne $grp){
            if($null -ne $GroupIds){
                $addGrp
                forEach($itm in $GroupIds){
                    try{
                        $addGrp = Get-AzureADGroup -ObjectId $itm
                    }
                    catch{
                        $Script:result += "Error: GroupID $($itm) $($_.Exception.Message)"
                        $Script:err = $true
                        continue
                    }
                    if($null -ne $addGrp){
                        try{
                            $null = Remove-AzureADGroupMember -ObjectId $gid -MemberId $itm
                            $Script:result += "Group $($addGrp.DisplayName) removed from Group $($grp.DisplayName)"
                        }
                        catch{
                            $Script:result += "Error: GroupID $($itm) $($_.Exception.Message)"
                            $Script:err = $true
                            continue
                        }
                    }                
                }
            }
            if($null -ne $UserIds){
                $usr
                forEach($itm in $UserIds){
                    try{
                        $usr = Get-AzureADUser -ObjectId $itm 
                    }
                    catch{
                        $Script:result += "Error: UserID $($itm) $($_.Exception.Message)"
                        $Script:err = $true
                        continue
                    }
                    if($null -ne $usr){
                        try{
                            $null =  Remove-AzureADGroupMember -ObjectId $gid -MemberId $itm
                            $Script:result += "User $($usr.DisplayName) removed from Group $($grp.DisplayName)"
                        }
                        catch{
                            $Script:result += "Error: UserID $($itm) $($_.Exception.Message)"
                            $Script:err = $true
                            continue
                        }
                    }
                }
            }
        }
        else {
            $Script:result += "Group $($gid) not found"
            $Script:err = $true
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