#Requires -Version 5.0
#Requires -Modules SimplySQL

function OpenSQlConnection(){
    <#
        .SYNOPSIS
            Open a connection to a SQL Server

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

        .LINK
            https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/_LIB_

        .Parameter ServerName
            The datasource for the connection

        .Parameter DatabaseName
            Database catalog connecting to

        .Parameter CommandTimeout
            The default command timeout to be used for all commands executed against this connection
        
        .Parameter ConnectionName
            The name to associate with the newly created connection, default is SRConnection

        .Parameter SQLCredential
            Credential object containing the SQL user/password, is the parameter empty authentication is Integrated Windows Authetication
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true)]   
            [string]$ServerName, 
            [Parameter(Mandatory = $true)]   
            [string]$DatabaseName, 
            [PSCredential]$SQLCredential,
            [int32]$CommandTimeout = 30,
            [string]$ConnectionName = "SRConnection"
        )

        try{
            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'Server' = $ServerName
                        'Database' = $DatabaseName
                        'CommandTimeout' = $CommandTimeout
                        'ConnectionName' = $ConnectionName
                        }
            if($null -ne $SQLCredential){
                $cmdArgs.Add('Credential', $SQLCredential)
            }
            Open-SqlConnection @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}

function CloseConnection(){
    <#
        .SYNOPSIS
            Closes the connection and disposes of the underlying object

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

        .LINK
            https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/_LIB_

        .Parameter ConnectionName
            User defined name for the connection, default is SRConnection
        #>

        [CmdLetBinding()]
        Param(
            [string]$ConnectionName = "SRConnection"
        )

        try{
            if((Test-SqlConnection -ConnectionName $ConnectionName) -eq $true){
                Close-SqlConnection -ConnectionName $ConnectionName             
            }
        }
        catch{
            throw
        }
        finally{
        }
}

function InvokeQuery(){
    <#
      .SYNOPSIS
          Executes a query

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

      .LINK
          https://github.com/scriptrunner/ActionPacks/tree/master/DBSystems/_LIB_

      .Parameter QuerySQL
          SQL statement to run

      .Parameter Timeout
          The timeout, in seconds, for this SQL statement, defaults (-1) to the command timeout for the SqlConnection

      .Parameter UseTransaction
          Starts a sql transaction before execute the query and rollback the transaction on error

      .Parameter ConnectionName
          User defined name for the connection, default is SRConnection
      #>

      [CmdLetBinding()]
      Param(
          [switch]$UseTransaction,
          [string]$QuerySQL,
          [int32]$Timeout = -1,
          [switch]$ReturnResult,
          [string]$ConnectionName = "SRConnection"
      )

      try{
        if($UseTransaction -eq $true){
            try{
                Start-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
                $Global:QueryResult = Invoke-SqlQuery -ConnectionName $ConnectionName -Query $QuerySQL -CommandTimeout $Timeout -ErrorAction Stop
                Complete-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
                if($ReturnResult){
                    return $Global:QueryResult
                }
            }
            catch{
                Undo-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
                throw
            }
        }
        else{
            if($ReturnResult){
                return Invoke-SqlQuery -ConnectionName $ConnectionName -Query $QuerySQL -CommandTimeout $Timeout -ErrorAction Stop
            }
            else {
                $Global:QueryResult = Invoke-SqlQuery -ConnectionName $ConnectionName -Query $QuerySQL -CommandTimeout $Timeout -ErrorAction Stop
            }
        }
      }
      catch{
          throw
      }
      finally{
      }
}

function InvokeScalarQuery(){
      <#
        .SYNOPSIS
            Executes a Scalar query

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

        .LINK
            https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/_LIB_
 
        .Parameter ScalarQuery
            SQL statement to run

        .Parameter Timeout
            The timeout, in seconds, for this SQL statement, defaults (-1) to the command timeout for the SqlConnection

        .Parameter UseTransaction
            Starts a sql transaction before execute the query and rollback the transaction on error

        .Parameter ConnectionName
            User defined name for the connection, default is SRConnection
                        
        .Parameter ReturnResult
            Returns the result
        #>

        [CmdLetBinding()]
        Param(
            [switch]$UseTransaction,
            [string]$ScalarQuery,
            [int32]$Timeout = -1,
            [switch]$ReturnResult,
            [string]$ConnectionName = "SRConnection"
        )

        try{
            if($UseTransaction -eq $true){
                try{
                    Start-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
                    $Global:ScalarResult = Invoke-SqlScalar -ConnectionName $ConnectionName -Query $ScalarQuery -CommandTimeout $Timeout -ErrorAction Stop
                    Complete-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
                    if($ReturnResult){
                        return $Global:ScalarResult
                    }
                }
                catch{
                    Undo-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
                    throw
                }
            }
            else{
                if($ReturnResult){
                    return Invoke-SqlScalar -ConnectionName $ConnectionName -Query $ScalarQuery -CommandTimeout $Timeout -ErrorAction Stop
                }
                else{
                    $Global:ScalarResult = Invoke-SqlScalar -ConnectionName $ConnectionName -Query $ScalarQuery -CommandTimeout $Timeout -ErrorAction Stop
                }
            }
        }
        catch{
            throw
        }
        finally{
        }
}

function InvokeUpdateQuery(){
    <#
      .SYNOPSIS
          Executes a query and returns number of record affected

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

      .LINK
          https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/_LIB_

      .Parameter UpdateQuery
          SQL statement to run

      .Parameter Timeout
          The timeout, in seconds, for this SQL statement, defaults (-1) to the command timeout for the SqlConnection

      .Parameter UseTransaction
          Starts a sql transaction before execute the query and rollback the transaction on error

      .Parameter ConnectionName
          User defined name for the connection, default is SRConnection
      #>

      [CmdLetBinding()]
      Param(
          [switch]$UseTransaction,
          [string]$UpdateQuery,
          [int32]$Timeout,
          [string]$ConnectionName = "SRConnection"
      )

      try{
          if($UseTransaction -eq $true){
              try{
                  Start-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
                  $Global:UpdateResult = Invoke-SqlUpdate -ConnectionName $ConnectionName -Query $UpdateQuery -CommandTimeout $Timeout -ErrorAction Stop
                  Complete-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
              }
              catch{
                  Undo-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
                  throw
              }
          }
          else{
              $Global:UpdateResult = Invoke-SqlUpdate -ConnectionName $ConnectionName -Query $UpdateQuery -CommandTimeout $Timeout -ErrorAction Stop
          }
      }
      catch{
          throw
      }
      finally{
      }
}