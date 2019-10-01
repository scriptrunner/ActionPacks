#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

function ConnectSPO(){
    <#
        .SYNOPSIS
            Open a SharePoint Online session

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.Online.SharePoint.PowerShell

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/_LIB_

        .Parameter SPOCredential
            Specifies the credentials to use to connect, e.g. https://contoso-admin.sharepoint.com

        .Parameter Url
            Specifies the URL of the SharePoint Online Administration Center site
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true)]  
            [string]$Url ,
            [Parameter(Mandatory = $true)]  
            [PSCredential]$SPOCredential
        )

        try{
            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'Credential' = $SPOCredential
                        'Url' = $Url
                        }
            Connect-SPOService @cmdArgs
        }
        catch{
            throw
        }
        finally{
        }
}

function DisconnectSPO(){
    <#
        .SYNOPSIS
            Closes the SharePoint Online session 

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module SkypeOnlineConnector

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/_LIB_

        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            Disconnect-SPOService -ErrorAction Ignore
        }
        catch{
            throw
        }
        finally{
        }
}