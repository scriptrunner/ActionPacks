#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Retrieve the cities that support a given inventory type within a geographical area
    
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
        Requires Library script SFBLibrary.ps1
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/Online

    .Parameter SFBCredential
        Credential object containing the Skype for Business user/password

    .Parameter Area
        Specifies the target geographical

    .Parameter CountryOrRegion
        Specifies the target country

    .Parameter InventoryType
        Specifies the target telephone number type

    .Parameter RegionalGroup
        Specifies the target geographical region

    .Parameter CapitalOrMajorCity
        Specifies the target geographical city 
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [Parameter(Mandatory = $true)]
    [string]$CountryOrRegion,  
    [Parameter(Mandatory = $true)]
    [ValidateSet('Service','Subscriber')]
    [string]$InventoryType ,
    [Parameter(Mandatory = $true)]
    [string]$RegionalGroup ,
    [Parameter(Mandatory = $true)]
    [string]$Area,
    [string]$CapitalOrMajorCity
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CountryOrRegion' = $CountryOrRegion
                            'InventoryType' = $InventoryType
                            'RegionalGroup' = $RegionalGroup
                            'Area' = $Area
                            'Force' = $true
                            } 
    if([System.String]::IsNullOrWhiteSpace($CapitalOrMajorCity) -eq $false){
        $cmdArgs.Add('CapitalOrMajorCity',$CapitalOrMajorCity)
    }

    $result = Get-CsOnlineTelephoneNumberInventoryCities @cmdArgs | Select-Object *

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
    DisconnectS4B
}