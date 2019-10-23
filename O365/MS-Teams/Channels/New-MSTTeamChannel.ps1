#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Add a new channel to a team

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
    Requires Library script MSTLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Channels
 
.Parameter MSTCredential
    Provides the user ID and password for organizational ID credentials 

.Parameter GroupId
    GroupId of the team
    
.Parameter DisplayName
    Channel display name
    
.Parameter ChannelNames
    One or more channel display names, comma separated

.Parameter Description
    Channel Description

.Parameter TenantID
    Specifies the ID of a tenant
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Single")]   
    [Parameter(Mandatory = $true, ParameterSetName = "Multi")]   
    [pscredential]$MSTCredential,
    [Parameter(Mandatory = $true, ParameterSetName = "Single")]   
    [Parameter(Mandatory = $true, ParameterSetName = "Multi")]   
    [string]$GroupId,
    [Parameter(Mandatory = $true, ParameterSetName = "Multi")]   
    [string]$ChannelNames,
    [Parameter(Mandatory = $true, ParameterSetName = "Single")]   
    [ValidateLength(5,50)]
    [string]$DisplayName,
    [Parameter(ParameterSetName = "Single")]   
    [ValidateLength(0,1024)]
    [string]$Description,
    [Parameter(ParameterSetName = "Single")]   
    [Parameter(ParameterSetName = "Multi")]
    [string]$TenantID
)

Import-Module microsoftteams

try{
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            }      

    if($PSCmdlet.ParameterSetName -eq 'Multi'){
        $team = Get-Team -GroupId $GroupId -ErrorAction Stop | Select-Object -ExpandProperty DisplayName
        $result = @()
        $names = $ChannelNames.Split(',')
        foreach($cnl in $names){
            try{
                $null = New-TeamChannel @cmdArgs -DisplayName $cnl
                $result += "Channel $($cnl) added to team $($team)"
            }
            catch{
                $result += "Error. Add channel $($cnl) to team $($team)"
            }
        }  
    }
    else{
        $cmdArgs.Add('DisplayName' , $DisplayName)
        if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
            $cmdArgs.Add('Description',$Description)
        }    
        $result = New-TeamChannel @cmdArgs | Select-Object *
    }    
    
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
    DisconnectMSTeams
}