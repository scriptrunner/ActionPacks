#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Mail 

<#
    .SYNOPSIS
        Returns media content for the navigation property messages from users
    
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

    .Parameter MessageId
        [sr-en] Id of the message
        [sr-de] Mail ID

    .Parameter OutFile
        [sr-en] Path to write output file to
        [sr-de] Pfad und Dateiname der Ausgabedatei
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$MessageId,
    [Parameter(Mandatory = $true)]
    [string]$OutFile
)

Import-Module Microsoft.Graph.Mail 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'UserId' = $UserId
                        'MessageId' = $MessageId   
                        'OutFile' = $OutFile      
                        'PassThru' = $null               
    }

    $result = Get-MgUserMessageContent @cmdArgs | Select-Object *
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