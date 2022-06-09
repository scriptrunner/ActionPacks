#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Get team from group
    
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
        Requires Modules Microsoft.Graph.Teams 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Teams

    .Parameter GroupId
        [sr-en] Group identifier
        [sr-de] Gruppen ID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [ValidateSet('Classification','Description','DisplayName','Id','IsArchived','CreatedDateTime','Specialization','Visibility','WebUrl')]
    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime','IsArchived','WebUrl')
)

Import-Module Microsoft.Graph.Teams 

try{
    ConnectMSGraph  
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'GroupId' = $GroupId
    }

    $mgTeam = Get-MgGroupTeam @cmdArgs | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgTeam
    }
    else{
        Write-Output $mgTeam
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}