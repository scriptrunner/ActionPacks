#Requires -Version 5.0
#Requires -Modules Az.Accounts

$VerbosePreference = 'SilentlyContinue'

function ConnectAzure(){
    <#
        .SYNOPSIS
            Function connects the account to azure

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Az

        .LINK
            https://github.com/scriptrunner/ActionPacks/blob/master/Azure/_LIB_

        .Parameter AzureCredential
            The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

        .Parameter Tenant
            Tenant name or ID
        #>

        [CmdLetBinding()]
        Param(            
            [pscredential]$AzureCredential,
            [string]$Tenant
        )

        try{
            [string]$conName = 'SRAzureAccess'
            if([System.String]::IsNullOrWhiteSpace($Tenant) -eq $true){
                $null = Connect-AzAccount -Credential $AzureCredential -Force -Confirm:$false -ErrorAction Stop
            }
            else{
                $conName = 'SR' + $Tenant
                $null = Connect-AzAccount -Credential $AzureCredential -Tenant $Tenant -Force -Confirm:$false -ErrorAction Stop
            }
        }
        catch{
            throw
        }
        finally{
        }
}
function DisconnectAzure(){
    <#
        .SYNOPSIS
            Function disconnects connection to azure

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Az

        .LINK
            https://github.com/scriptrunner/ActionPacks

        .Parameter Tenant
            Tenant name or ID
        #>

        [CmdLetBinding()]
        Param(    
            [string]$Tenant
        )

        try{
            [string]$conName = 'SRAzureAccess'
            if([System.String]::IsNullOrWhiteSpace($Tenant) -eq $true){
                $conName = 'SR' + $Tenant
            }
            Disconnect-AzAccount -Confirm:$false -ErrorAction Stop
        }
        catch{
            throw
        }
        finally{
        }
}