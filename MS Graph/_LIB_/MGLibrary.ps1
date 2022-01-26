#Requires -Version 5.0
#Requires -Modules Microsoft.Graph.Authentication

Import-Module Microsoft.Graph.Authentication

function ConnectMSGraph(){
    <#
        .SYNOPSIS
            Open a connection to Microsoft Graph

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.Graph.Authentication

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/MS Graph/_LIB_

        .Parameter ClientID
            Credential object containing the Microsoft Teams user/password

        .Parameter TenantID
            Specifies the ID of a tenant

        .Parameter CertificateThumbprint
            Specifies the log level
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true)]  
            [string]$ClientID,
            [Parameter(Mandatory = $true)]  
            [string]$TenantId,
            [Parameter(Mandatory = $true)]  
            [string]$CertificateThumbprint
        )
        
        try{
            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'ClientID' = $ClientID
                        'TenantId' = $TenantId
                        'CertificateThumbprint' = $CertificateThumbprint
                        }
            $null = Connect-MgGraph @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}
function DisconnectMSGraph(){
    <#
        .SYNOPSIS
            Closes the connection to Microsoft Graph

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.Graph.Authentication

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/MS Graph/_LIB_

        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            if($null -ne (Get-MgContext)){
                Disconnect-MgGraph 
            }
        }
        catch{
            throw
        }
        finally{
        }
}