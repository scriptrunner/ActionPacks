#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Mail 

<#
    .SYNOPSIS
        Creates user mail folder
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Mail 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Mail

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter DisplayName
        [sr-en] Mail folder display name
        [sr-de] Ordnername

    .Parameter IsHidden
        [sr-en] Mail folder is hidden
        [sr-de] Ordner ist hidden
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [switch]$IsHidden
)

Import-Module Microsoft.Graph.Mail 

try{
    [string[]]$Properties = @('DisplayName','Id','ChildFolderCount','TotalItemCount','UnreadItemCount')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'UserId' = $UserId
                        'DisplayName' = $DisplayName
                        'Confirm' = $false
    }
    if($IsHidden.IsPresent -eq $true){
        $cmdArgs.Add('IsHidden',$null)
    }
    $result = New-MgUserMailFolder @cmdArgs | Select-Object $Properties

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