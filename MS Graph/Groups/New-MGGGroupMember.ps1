#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups 

<#
    .SYNOPSIS
        Add member to a group
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Groups 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Groups
        
    .Parameter GroupId
        [sr-en] Group identifier
        [sr-de] Gruppen ID
        
    .Parameter UserIds
        [sr-en] User identifier
        [sr-de] Benutzer Identifier
        
    .Parameter SecurityGroupIds
        [sr-en] Security group identifier
        [sr-de] Security-Gruppen Identifier
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$GroupId,    
    [string[]]$UserIds,
    [string[]]$SecurityGroupIds
)

Import-Module Microsoft.Graph.Groups

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            'Confirm' = $false
                            'GroupId' = $GroupId
    }
    # Users
    foreach($usr in $UserIds){
        $null = New-MgGroupMember @cmdArgs -DirectoryObjectId $usr
    }
    # groups
    foreach($grp in $SecurityGroupIds){
        $null = New-MgGroupMember @cmdArgs -DirectoryObjectId $grp
    }
    $mgGroupMembers = $null
    GetGroupMembers -GroupID $GroupId -Memberships ([ref]$mgGroupMembers)

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgGroupMembers
    }
    else{
        Write-Output $mgGroupMembers
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}