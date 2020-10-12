function OpenSqlConnection(){
    <#
        .SYNOPSIS
            Function opens a connection to the database

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT            

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/_LIB_

        .Parameter SqlCon
            Object for the connection

        .Parameter SQLServer
            Name of the sql server

        .Parameter DBName
            Name of database

        .Parameter SQLServerAccount
            SQL Server authentication non windows authentication
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ref]$SqlCon,     
        [string]$SqlServer = 'YOUR SQL Server Name',
        [string]$DBName = 'SRStatistics',
        [pscredential]$SQLServerAccount
    )

    try{        
        $scon = New-Object System.Data.SqlClient.SqlConnection
        $scon.ConnectionString = "Data Source=$($SqlServer);Initial Catalog=$($DBName)"
        if($null -eq $SQLServerAccount){
            $scon.ConnectionString += ";Integrated Security=true"
        }
        else{
            $SQLServerAccount.Password.MakeReadOnly()
            $sqlCred = New-Object System.Data.SqlClient.SqlCredential($SQLServerAccount.UserName,$SQLServerAccount.Password)
            $scon.Credential = $sqlCred
        }
        $null = $scon.Open()
        $SqlCon.Value = $scon
    }
    catch{
        throw
    }
}
function CloseSqlConnection(){
    <#
        .SYNOPSIS
            Function closes the connection to the database

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT            

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/_LIB_

        .Parameter SqlCon
            Connection object
    #>

    param(
        $SqlCon 
    )

    try{
        if(($null -eq $SqlCon) -or ($null -eq $SqlCon.Value)){
            return
        }        
        if($SqlCon.Value.State -eq [System.Data.ConnectionState]::Open){
            $null = $SqlCon.Value.Close()
        }
        $null = $SqlCon.Value.Dispose()
    }
    catch{
        throw
    }
}
function LogExecution(){
    <#
        .SYNOPSIS
            Function logs the execution of an action

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT            

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/_LIB_

        .Parameter CostSavingsSeconds
            Cost savings in seconds 

        .Parameter DeleteExecutionsDays
            Delete logs older than this days

        .Parameter SQLAccount
            SQL Server authentication non windows authentication
    #>

        [CmdLetBinding()]
        Param(     
            [int]$CostSavingsSeconds = 300,
            [int]$DeleteExecutionsDays = 0,
            [pscredential]$SQLAccount
        )

        $con = $null
        try{
            [Datetime]$start = [System.DateTime]::Now
            [Datetime]$end = [System.DateTime]::Now
            [int]$runs = $end.Subtract($start).Seconds

            OpenSqlConnection -SqlCon ([ref]$con) -SQLServerAccount $SQLAccount

            $scmd = New-Object System.Data.SqlClient.SqlCommand
            $scmd.CommandType = [System.Data.CommandType]::StoredProcedure
            $scmd.CommandText = 'RegisterExecution'
            $null = $scmd.Parameters.AddWithValue('Savings',$CostSavingsSeconds)
            $null = $scmd.Parameters.AddWithValue('StartedBy',$SRXEnv.SRXStartedBy)
            $null = $scmd.Parameters.AddWithValue('Started',$start.ToFileTimeUtc())
            $null = $scmd.Parameters.AddWithValue('Ended',$end.ToFileTimeUtc())
            $null = $scmd.Parameters.AddWithValue('Duration',$runs)
            $null = $scmd.Parameters.AddWithValue('Target',$SRXEnv.SRXRunOn)
            $null = $scmd.Parameters.AddWithValue('Action',$SRXEnv.SRXDisplayName)
            if(($null -ne $SRXEnv.SRXActionID) -and ([int]$SRXEnv.SRXActionID -gt 0)){
                $null = $scmd.Parameters.AddWithValue('ActionID',([int]$SRXEnv.SRXActionID)) 
            }
            else{
                $null = $scmd.Parameters.AddWithValue('ActionID',0) 
            }
            $null = $scmd.Parameters.AddWithValue('ScriptName',$SRXEnv.SRXScriptName)
            if($null -ne $SRXEnv.SRXStartedReason){
                $null = $scmd.Parameters.AddWithValue('Reason',$SRXEnv.SRXStartedReason)
            }
            if($DeleteExecutionsDays -gt 0){
                $null = $scmd.Parameters.AddWithValue('DeleteOlderExecutions',($end.AddDays(($DeleteExecutionsDays * -1)).ToFileTimeUtc()))
            }

            $scmd.Connection = $con
            
            $null = $scmd.ExecuteScalar()

            $null = $scmd.Dispose()
        }
        catch{
            throw
        }
        finally{
            CloseSqlConnection -SqlCon $con
        }
}