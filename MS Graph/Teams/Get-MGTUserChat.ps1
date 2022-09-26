#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams

<#
    .SYNOPSIS
        Get chats from users
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Teams

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Teams

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [ValidateSet('ChatType','CreatedDateTime','Id','InstalledApps','LastUpdatedDateTime',
                'Members','Messages','Operations','PermissionGrants','PinnedMessages','Tabs',
                'TenantId','Topic','WebUrl')]
    [string[]]$Properties = @('ChatType','Id','CreatedDateTime','Messages')
)

Import-Module Microsoft.Graph.Teams

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            'UserId' = $UserId
    }
    $result = Get-MgUserChat @cmdArgs | Select-Object $Properties

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }    
}
catch{
    throw 
}
finally{
}