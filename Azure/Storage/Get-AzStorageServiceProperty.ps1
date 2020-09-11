#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets properties for Azure Storage services
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az.Storage

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Storage   

    .Parameter StorageAccountName 
        [sr-en] Specifies the name of the Storage account
        [sr-de] Name des Storage Accounts
        
    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group
        [sr-de] Name der resource group

    .Parameter ServiceType
        [sr-en] Specifies the Azure Storage service type
        [sr-de] Azure Storage Service Typ
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Blob','Table','Queue','File')]
    [string]$ServiceType
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'ServiceType' = $ServiceType
    }

    $ret = @()
    $null = Get-AzStorageServiceProperty @cmdArgs | Select-Object * | ForEach-Object{
        $ret += [PSCustomObject] @{
            'DefaultServiceVersion' = $_.DefaultServiceVersion
            'StaticWebsite' = $_.StaticWebsite
            'HourMetrics' = (Select-Object -ExpandProperty $_.HourMetrics)            
            'MinuteMetrics' = (Select-Object -ExpandProperty $_.MinuteMetrics)
            'Logging' = (Select-Object -ExpandProperty $_.Logging)
        }
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}