#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Gets a list of licenses
    
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
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/_QUERY_
#>

param(    
)
 
try{
    $result = Get-AzureADSubscribedSku  | Select-Object SkuId, SkuPartNumber | Sort-Object -Property SkuPartNumber
    
    foreach($itm in  $result){
        if($SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.SkuId) # Value
            $null = $SRXEnv.ResultList2.Add($itm.SkuPartNumber) # DisplayValue            
        }
        else{
            Write-Output $itm.SkuPartNumber 
        }
    }
}
finally{
 
}