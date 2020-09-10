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
            Requires Module Az.Accounts

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Azure/_LIB_

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
            if([System.String]::IsNullOrWhiteSpace($Tenant) -eq $true){
                $null = Connect-AzAccount -Credential $AzureCredential -Force -Confirm:$false -ErrorAction Stop
            }
            else{
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
            Requires Module Az.Accounts

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Azure/_LIB_

        .Parameter Tenant
            Tenant name or ID
        #>

        [CmdLetBinding()]
        Param(               
        )

        try{
            Disconnect-AzAccount -Confirm:$false -ErrorAction Stop
        }
        catch{
            throw
        }
        finally{
        }
}
function GetAzureStorageAccount(){
    <#
        .SYNOPSIS
            Gets a Storage account

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Az.Accounts

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Azure/_LIB_

        .Parameter Name
            Specifies the name of the Storage account to get

        .Parameter ResourceGroupName
            Specifies the name of the resource group that contains the Storage account to get

        .Parameter StorageAccount
            Reference parameter for result
    #>

    [CmdLetBinding()]
    Param(  
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string]$AccountName,   
        [Parameter(Mandatory = $true)]
        [ref]$StorageAccount          
    )

    try{
        $StorageAccount.Value = Get-AzStorageAccount -Name $AccountName -ResourceGroupName $ResourceGroupName -ErrorAction Stop | Select-Object *
    }
    catch{

    }
}