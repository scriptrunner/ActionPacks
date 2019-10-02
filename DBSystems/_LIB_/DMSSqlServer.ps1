function GetSQLServerInstance(){
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
            Requires Module SQLServer

        .LINK
            https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/_LIB_

        .Parameter ServerInstance
            Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

        .Parameter ServerCredential
            Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
            When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.
            
        .Parameter ConnectionTimeout
            Specifies the time period to retry the command on the target server
    #>
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $true)]   
        [string]$ServerInstance,    
        [pscredential]$ServerCredential,
        [int]$ConnectionTimeout = 30
    )
    try{
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'Confirm' = $false
                                'ServerInstance' = $ServerInstance
                                'ConnectionTimeout' = $ConnectionTimeout}
        if($null -ne $ServerCredential){
            $cmdArgs.Add('Credential',$ServerCredential)
        }
        return Get-SqlInstance  @cmdArgs
    }
    catch{
        throw
    }
}

function GetSQLDatabase(){
    <#
        .SYNOPSIS
            Gets a SQL database object 

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
            https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/_LIB_

        .Parameter ServerInstance
            Specifies the server object of the target instance

        .Parameter ServerCredential
            Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
            When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.
            
        .Parameter ConnectionTimeout
            Specifies the time period to retry the command on the target server
    #>
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $true)]   
        [object]$ServerInstance,    
        [Parameter(Mandatory = $true)]   
        [string]$DatabaseName
    )
    try{
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'InputObject' = $ServerInstance
                                'Name' = $DatabaseName
                                'Confirm' = $false
                                }
        
        return Get-SqlDatabase @cmdArgs
    }
    catch{
        throw
    }
}