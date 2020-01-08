#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and gets the properties from Azure Active Directory group
    
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
        Specifies the unique ID of the group from which to get properties

    .Parameter GroupName
        Specifies the display name of the group from which to get properties

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
    $Script:result = @()
    $Script:Grp
    if($PSCmdlet.ParameterSetName  -eq "Group object id"){
        $Script:Grp = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId  | Select-Object *
    }
    else{
        $Script:Grp = Get-MsolGroup -TenantId $TenantId  | Where-Object {$_.Displayname -eq $GroupName} | Select-Object *
    }
    if($null -ne $Script:Grp){
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:Grp
        } 
        else{
            Write-Output $Script:Grp 
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group not found"
        }    
        Throw "Group not found"
    }
}
catch{
    throw
}