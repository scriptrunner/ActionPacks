#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Returns the properties and settings of users that are enabled for dial-in conferencing and are using Microsoft as their PSTN conferencing provider
    
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

    .Parameter Identity
        Specifies the user to retrieve

    .Parameter BridgeId
        Specifies the globally-unique identifier (GUID) for the audio conferencing bridge

    .Parameter BridgeName
        Specifies the name of the audio conferencing bridge

    .Parameter ServiceNumber
        Specifies a service number to serve as a filter for the returned user collection

    .Parameter ResultSize
        Specifies the number of records returned by the cmdlet
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [string]$Identity,
    [string]$BridgeId,
    [string]$BridgeName,
    [string]$ServiceNumber,
    [int]$ResultSize
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Force' = $true
                            }      
    if([System.String]::IsNullOrWhiteSpace($Identity) -eq $false){
        $cmdArgs.Add('Identity',$Identity)
    } 
    if([System.String]::IsNullOrWhiteSpace($BridgeId) -eq $false){
        $cmdArgs.Add('BridgeId',$BridgeId)
    }    
    if([System.String]::IsNullOrWhiteSpace($BridgeName) -eq $false){
        $cmdArgs.Add('BridgeName',$BridgeName)
    }    
    if([System.String]::IsNullOrWhiteSpace($ServiceNumber) -eq $false){
        $cmdArgs.Add('ServiceNumber',$ServiceNumber)
    }  
    if($ResultSize -gt 0){
        $cmdArgs.Add('ResultSize',$ResultSize)
    }    

    $result = Get-CsOnlineDialInConferencingUser @cmdArgs | Select-Object *

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