#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Gets the SQL Server error logs

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module SQLServer
    Requires the library script DMSSqlServer.ps1
    
.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/SQLServer
 
.Parameter ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.Parameter ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.Parameter Ascending
    Indicates that the cmdlet sorts the collection of error logs by the log date in ascending order

.Parameter After
    Specifies that this cmdlet only gets error logs generated after the given time

.Parameter Before
    Specifies that this cmdlet only gets error logs generated before the given time
        
.Parameter Since
    Specifies an abbreviation for the Timespan parameter

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Status. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [datetime]$After,
    [datetime]$Before,
    [switch]$Ascending,
    [ValidateSet('Midnight', 'Yesterday', 'LastWeek','LastMonth')]
    [string]$Since,
    [int]$ConnectionTimeout = 30,
    [string]$Properties = "Date,Source,Text,ServerInstance"
)

Import-Module SQLServer

try{
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties='*'
    }
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'Ascending' = $Ascending.ToBool()
                            }
    if($null -ne $After){
        $cmdArgs.Add("After",$After)
    }
    if($null -ne $Before){
        $cmdArgs.Add("Before",$Before)
    }
    if((-not $After) -and (-not $Before) -and ([System.String]::IsNullOrWhiteSpace($Since) -eq $false)){
        $cmdArgs.Add("Since",$Since)
    }  
    $Script:result = Get-SqlErrorLog @cmdArgs | Select-Object $Properties.Split(',')
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:result
    }
    else{
        Write-Output $Script:result
    }
}
catch{
    throw
}
finally{
}