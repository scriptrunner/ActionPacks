#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Retrieving teams informations

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
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_REPORTS_
 
.Parameter MSTCredential
    Provides the user ID and password for organizational ID credentials
    
.Parameter GroupId
    Specify the specific GroupId of the team to be returned

.Parameter ExtendedReport
    Extended output with the team users and their roles

.Parameter Archived
    Filters to return teams that have been archived or not

.Parameter Visibility
    Filters to return teams with a set "visibility" value

.Parameter TenantID
    Specifies the ID of a tenant
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$MSTCredential,
    [string]$GroupId,
    [switch]$ExtendedReport,
    [bool]$Archived,
    [ValidateSet('Public','Private')]
    [string]$Visibility,
    [string]$TenantID
)

Import-Module microsoftteams

try{
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'Archived' = $Archived
                            }  
                            
    if([System.String]::IsNullOrWhiteSpace($GroupId) -eq $false){
        $getArgs.Add('GroupId',$GroupId)
    }
    if([System.String]::IsNullOrWhiteSpace($Visibility) -eq $false){
        $getArgs.Add('Visibility',$Visibility)
    }

    $result = @()
    $output = @()
    $teams = Get-Team @getArgs | Select-Object @('DisplayName', 'Alias','GroupID','MailNickName') | Sort-Object DisplayName
    [int]$owners,$members,$guests

    foreach($item in $teams){
        try{
            $users = Get-TeamUser -GroupId $item.GroupId 
            if($ExtendedReport -eq $true){
                foreach ($usr in ($users | Sort-Object -Property Name | Sort-Object -Property Role -Descending)){
                    $output += [PSCustomObject] @{
                        'Team' = $item.DisplayName
                        'GroupID' =  $item.GroupId
                        'Alias' = $item.MailNickName
                        "User name" =  $usr.Name
                        "Role" =  $usr.Role
                    }
                }
            }
            else{
                $owners = @($users | Where-Object {$_.Role -eq "owner"}).Length
                $members = @($users | Where-Object {$_.Role -eq "member"}).Length
                $guests = @($users | Where-Object {$_.Role -eq "guest"}).Length
                $output += [PSCustomObject] @{
                    'Team' = $item.DisplayName
                    'GroupID' =  $item.GroupId
                    'Alias' = $item.MailNickName
                    "Number of Owners" =  $owners
                    "Number of Members" =  $members
                    "Number of Guests" =  $guests
                }                
            }

        }
        catch{
            $result += "Error read team $($item.GroupId) - $($_.Exception.Message)"
        }
    }
    
    ConvertTo-ResultHtml -Result $output
}
catch{
    throw
}
finally{
    DisconnectMSTeams
}