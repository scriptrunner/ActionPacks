#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Returns user's profile photo
    
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
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID
        
    .Parameter PhotoId
        [sr-en] Unique identifier of profilePhoto
        [sr-de] Photo ID
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [string]$PhotoId
)

Import-Module Microsoft.Graph.Users

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'UserId' = $UserId
    }
    if($PSBoundParameters.ContainsKey('PhotoId') -eq $true){
        $cmdArgs.Add('ProfilePhotoId',$PhotoId)
    }
    else {
        $cmdArgs.Add('All',$null)
    }
    $result = Get-MgUserPhoto @cmdArgs | Select-Object *

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
    DisconnectMSGraph
}