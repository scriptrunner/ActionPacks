#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.7"}

<#
.SYNOPSIS
    Update the picture of a team

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 1.0.7 or greater
    Requires .NET Framework Version 4.7.2.
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams

.Parameter GroupId
    [sr-en] GroupId of the team
    [sr-de] Gruppen ID des Teams
    
.Parameter ImagePath
    [sr-en] File path and image (.png, .gif, .jpg, or .jpeg)
    [sr-de] Pfad und Name der Bilddatei (.png, .gif, .jpg, oder .jpeg) 
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [Parameter(Mandatory = $true)]   
    [string]$ImagePath
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            'ImagePath' = $ImagePath
                        }

    $null = Set-TeamPicture @cmdArgs
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Team Picture set"
    }
    else{
        Write-Output "Team Picture set"
    }
}
catch{
    throw
}
finally{
}