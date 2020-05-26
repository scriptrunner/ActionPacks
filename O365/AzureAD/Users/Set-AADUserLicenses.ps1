#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Adds the licenses to the user
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Azure Active Directory Powershell Module v2

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Users

    .Parameter UserObjectId
        Specifies the ID of a user (as a UPN or ObjectId) in Azure AD

    .Parameter LicenseSkuIds
        Specifies a list of licenses SkuIDs to assign, comma separated

    .Parameter LicenseSkuNames
        Specifies a list of licenses SkuPartNames to assign, comma separated
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName='ByIds')]
    [Parameter(Mandatory = $true,ParameterSetName='ByNames')]
    [string]$UserObjectId,
    [Parameter(Mandatory = $true,ParameterSetName='ByIds')]
    [string]$LicenseSkuIds,
    [Parameter(Mandatory = $true,ParameterSetName='ByNames')]
    [string]$LicenseSkuNames
)

try{
    $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    $licenses.AddLicenses = New-Object 'System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.AssignedLicense]'
    if($PSCmdlet.ParameterSetName -eq 'ByNames'){
        foreach($name in $LicenseSkuNames.Split(',')){
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $name -EQ).SkuID
            $licenses.AddLicenses.Add($license)
        }    
    }
    else{
        foreach($id in $LicenseSkuIds.Split(',')){
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $id
            $licenses.AddLicenses.Add($license)
        }  
    }
    
    $null = Set-AzureADUserLicense -ObjectId $UserObjectId -AssignedLicenses $licenses -ErrorAction Stop
    $usr = Get-AzureADUserLicenseDetail -ObjectId $UserObjectId -ErrorAction Stop | Select-Object SkuId,SkuPartNumber

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $usr
    } 
    else{
        Write-Output $usr 
    }
}
finally{
 
}