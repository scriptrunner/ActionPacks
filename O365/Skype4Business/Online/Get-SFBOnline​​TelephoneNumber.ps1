#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Retrieve telephone numbers from the Business Voice Directory
    
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

    .Parameter Assigned
        Specifies the function of the telephone number

    .Parameter ExpandLocation
        Displays the location parameter with its value

    .Parameter InventoryType
        Specifies the target telephone number type for the cmdlet

    .Parameter IsNotAssigned
        Specifying treturn only telephone numbers which are not assigned

    .Parameter ResultSize
        Specifies the number of records returned by the cmdlet

    .Parameter TelephoneNumber
        Specifies the target telephone number
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [ValidateSet('caa','user')]
    [string]$Assigned,
    [switch]$ExpandLocation,
    [ValidateSet('Service','Subscriber')]
    [string]$InventoryType,
    [switch]$IsNotAssigned,
    [int]$ResultSize,
    [string]$TelephoneNumber
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ExpandLocation' = $ExpandLocation
                            'IsNotAssigned' = $IsNotAssigned
                            'Force' = $true
                            }  
    if([System.String]::IsNullOrWhiteSpace($Assigned) -eq $false){
        $cmdArgs.Add('Assigned',$Assigned)
    }    
    if([System.String]::IsNullOrWhiteSpace($InventoryType) -eq $false){
        $cmdArgs.Add('InventoryType',$InventoryType)
    }
    if([System.String]::IsNullOrWhiteSpace($TelephoneNumber) -eq $false){
        $cmdArgs.Add('TelephoneNumber',$TelephoneNumber)
    }    
    if($ResultSize -gt 0){
        $cmdArgs.Add('ResultSize',$ResultSize)
    }

    $result = Get-CsOnlineTelephoneNumber @cmdArgs | Select-Object *

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