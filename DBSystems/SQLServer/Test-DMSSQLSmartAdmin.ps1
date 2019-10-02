#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Tests the health of Smart Admin by evaluating SQL Server policy based management (PBM) policies

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module SQLServer

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/SQLServer
 
.Parameter ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.Parameter ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.
    
.Parameter DatabaseName
    Specifies the name of the database of the SQL Smart Admin object

.Parameter AllowUserPolicies
    Indicates that this cmdlet runs user policies found in the Smart Admin warning and error policy categories

.Parameter NoRefresh
    Indicates that this cmdlet will not manually refresh the object specified by the Path or InputObject parameters

.Parameter ShowPolicyDetails
    Indicates that this cmdlet shows the result of the policy

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$DatabaseName,
    [switch]$AllowUserPolicies,
    [switch]$NoRefresh,
    [switch]$ShowPolicyDetails,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'Confirm' = $false
                            }
    if([System.String]::IsNullOrWhiteSpace($DatabaseName) -eq $false){
        $cmdArgs.Add('DatabaseName',$DatabaseName)
    }
    $result = Get-SqlSmartAdmin @cmdArgs | Test-SqlSmartAdmin -AllowUserPolicies:$AllowUserPolicies -NoRefresh:$NoRefresh `
                        -ShowPolicyDetails:$ShowPolicyDetails -Confirm:$false -ErrorAction Stop
    
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