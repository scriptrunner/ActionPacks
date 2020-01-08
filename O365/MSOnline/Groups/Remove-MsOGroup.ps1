#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and removes group from Azure Active Directory

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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/Groups

    .Parameter GroupObjectId
        Specifies the unique ID of the group to remove

    .Parameter GroupName
        Specifies the display name of the group to remove
    
    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Group object id")]
    [guid]$GroupObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "Group name")]
    [string]$GroupName,
    [Parameter(ParameterSetName = "Group name")]
    [Parameter(ParameterSetName = "Group object id")]
    [guid]$TenantId
)

try{
    if($PSCmdlet.ParameterSetName  -eq "Group object id"){
        $Script:Grp = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId  
    }
    else{
        $Script:Grp = Get-MsolGroup -TenantId $TenantId  | Where-Object {$_.Displayname -eq $GroupName} 
    }
    if($null -ne $Script:Grp){
        $null = Remove-MsolGroup -ObjectId $Script:Grp.ObjectId -TenantId $TenantId -Force
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group $($Script:Grp.DisplayName) removed"
        } 
        else{
            Write-Output "Group $($Script:Grp.DisplayName) removed"
        }
    }
    else {
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group not found"
        } 
        Throw "Group not found"
    }
}
catch{
    throw
}