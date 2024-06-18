#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Update the navigation property licenseDetails in users
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter DetailId
        [sr-en] Unique identifier of licenseDetails
        [sr-de] Lizenzdetail ID

    .Parameter SkuId
        [sr-en] Unique identifier (GUID) for the service SKU
        [sr-de] SKU ID

    .Parameter SkuPartNumber
        [sr-en] Unique SKU display name
        [sr-de] SKU Anzeigename
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$DetailId,
    [string]$SkuId,
    [string]$SkuPartNumber
)

Import-Module Microsoft.Graph.Users

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'UserId' = $UserId
                'LicenseDetailsId' = $DetailId
                'Confirm' = $false
    }
    if($PSBoundParameters.ContainsKey('SkuId') -eq $true){
        $cmdArgs.Add('SkuId',$SkuId)
    }
    if($PSBoundParameters.ContainsKey('SkuPartNumber') -eq $true){
        $cmdArgs.Add('SkuPartNumber',$SkuPartNumber)
    }
    $null = Update-MgUserLicenseDetail @cmdArgs

    $result = Get-MgUserLicenseDetail -UserId $UserId -All | Select-Object *
    if($null -ne $SRXEnv) {
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