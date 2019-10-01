#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Retrieve the regions where specified inventory types are supported
    
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

    .Parameter InventoryType
        Specifies the target telephone number type for the cmdlet

    .Parameter RegionalGroup
        Specifies the target geographical region 
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [Parameter(Mandatory = $true)]
    [ValidateSet('Service','Subscriber')]
    [string]$InventoryType,
    [string]$RegionalGroup
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InventoryType' = $InventoryType
                            'Force' = $true
                            }  
    if([System.String]::IsNullOrWhiteSpace($RegionalGroup) -eq $false){
        $cmdArgs.Add('RegionalGroup',$RegionalGroup)
    }

    $result = Get-CsOnlineTelephoneNumberInventoryRegions @cmdArgs | Select-Object *

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