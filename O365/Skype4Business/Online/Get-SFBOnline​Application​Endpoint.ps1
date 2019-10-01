#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Fetch the application endpoints for a tenant
    
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

    .Parameter Uri
        Sip Uri that identifies the tenant specific endpoint for the application

    .Parameter PhoneNumber
        The service number assigned to the trusted application endpoint

    .Parameter TenantID
        Unique identifier for the tenant
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [Parameter(Mandatory = $true)] 
    [string]$Uri,
    [string]$PhoneNumber,
    [string]$TenantID
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Uri' =$Uri
                            }      
    if([System.String]::IsNullOrWhiteSpace($PhoneNumber) -eq $false){
        $cmdArgs.Add('PhoneNumber',$PhoneNumber)
    } 
    if([System.String]::IsNullOrWhiteSpace($TenantID) -eq $false){
        $cmdArgs.Add('Tenant',$TenantID)
    }    

    $result = Get-CsOnlineApplicationEndpoint @cmdArgs | Select-Object *

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