#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Retrieving group ids of the teams

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams
 
.Parameter MSTCredential
    Provides the user ID and password for organizational ID credentials

.Parameter TenantID
    Specifies the ID of a tenant
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$MSTCredential,
    [string]$TenantID
)

Import-Module microsoftteams

try{
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                        'Confirm' = $false
                        'Credential' = $MSTCredential
                        }
    if([System.String]::IsNullOrWhiteSpace($TenantId) -eq $false){
        $getArgs.Add('TenantId', $TenantId)
    }
    $null = Connect-MicrosoftTeams @getArgs

    $teams = Get-Team -ErrorAction Stop | Sort-Object -Property DisplayName    
    foreach($itm in  $teams){
        if($SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.GroupId) # Value
            $null = $SRXEnv.ResultList2.Add($itm.DisplayName) # DisplayValue            
        }
        else{
            Write-Output $itm.DisplayName 
        }
    }
    Disconnect-MicrosoftTeams -Confirm:$false
}
catch{
    throw
}
finally{
}