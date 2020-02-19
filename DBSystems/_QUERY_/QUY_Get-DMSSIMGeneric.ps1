#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    Returns the specified columns from the specified table 

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
 
.Parameter IDColumn    
    Name of the column for the id value

.Parameter DisplayColumn
    Name of the column for the display value

.Parameter Table
    Name of the database table

.Parameter WhereSection
    Where section of the SQL Command

.Example
    QUY_Get-DMSSIMGeneric -ServerName MyServer - DatabaseName SR_Report -IDColumn Id -DisplayColumn DisplayName -Table BaseEntities_JobControlSet -WhereSection Id=300
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerName, 
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName, 
    [Parameter(Mandatory = $true)]
    [string]$IDColumn,
    [Parameter(Mandatory = $true)]
    [string]$DisplayColumn,
    [Parameter(Mandatory = $true)]
    [string]$Table ,    
    [string]$WhereSection,    
    [PSCredential]$SQLCredential
)

Import-Module SimplySQL

try{
    OpenSQlConnection -ServerName $ServerName -DatabaseName $DatabaseName -SQLCredential $SQLCredential -ErrorAction Stop

    if(([System.String]::IsNullOrWhiteSpace($WhereSection) -eq $false) -and ($WhereSection.IndexOf("Where",[System.StringComparison]::OrdinalIgnoreCase) -lt 0)) {
        $WhereSection = "WHERE $($WhereSection)"
    }
    $query = "SELECT $($IDColumn),$($DisplayColumn) FROM $($Table) $($WhereSection)" 

    $result = InvokeQuery -QuerySQL $query -ReturnResult

    foreach($itm in  $result){
        if($SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.Item($IDColumn)) # Value
            $null = $SRXEnv.ResultList2.Add($itm.Item($DisplayColumn)) # DisplayValue            
        }
        else{
            Write-Output $itm.Item($DisplayColumn)
        }
    }
}
catch{
    throw
}
finally{
    CloseConnection 
}