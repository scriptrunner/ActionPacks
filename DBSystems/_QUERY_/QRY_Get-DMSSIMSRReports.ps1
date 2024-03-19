#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    Returns the ScriptRunner reports in the specified period

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module SimplySQL
    Requires Library script DMSSimplySQL.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/_QUERY_

.Parameter ServerName
    The datasource for the connection

.Parameter DatabaseName
    Database catalog connecting to

.Parameter SQLCredential
    Credential object containing the SQL user/password, is the parameter empty authentication is Integrated Windows Authetication
 
.Parameter StartDate
    SQL statement to run

.Parameter EndDate
    The default command timeout to be used for all commands executed against this connection
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerName, 
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName, 
    [Parameter(Mandatory = $true,HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartDate,
    [Parameter(Mandatory = $true,HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndDate,    
    [PSCredential]$SQLCredential
)

Import-Module SimplySQL

try{
    OpenSQlConnection -ServerName $ServerName -DatabaseName $DatabaseName -SQLCredential $SQLCredential -ErrorAction Stop
        
    $query = "SELECT Id,DisplayName,Created FROM [dbo].[BaseEntities_JobControlSet]  
        WHERE Created >= DATETIMEFROMPARTS ($($StartDate.Year), $($StartDate.Month), $($StartDate.Day), $($StartDate.Hour), $($StartDate.Minute), $($StartDate.Second),0) 
        AND Created <  DATETIMEFROMPARTS ($($EndDate.Year), $($EndDate.Month), $($EndDate.Day), $($EndDate.Hour), $($EndDate.Minute), $($EndDate.Second),0)
        ORDER BY DisplayName DESC"

    $result = InvokeQuery -QuerySQL $query -ReturnResult

    foreach($itm in  $result){
        if($SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.Id) # Value
            $null = $SRXEnv.ResultList2.Add("$($itm.DisplayName) - ($($itm.Created))") # DisplayValue            
        }
        else{
            Write-Output "$($itm.DisplayName) - ($($itm.Created))"
        }
    }
}
catch{
    throw
}
finally{
    CloseConnection 
}