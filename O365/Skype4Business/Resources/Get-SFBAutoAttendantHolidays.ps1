#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Get the holiday information for an existing Auto Attendant (AA)
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/Resources

    .Parameter SFBCredential
        Credential object containing the Skype for Business user/password

    .Parameter Identity
        The identifier for the auto attendant whose holidays are to be retrieved

    .Parameter Name
        Represents the name for the holidays to be retrieved

    .Parameter Year
        Represents the year for the holidays to be retrieved

    .Parameter TenantID
        Guid of the tenant
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [Parameter(Mandatory = $true)] 
    [string]$Identity,
    [string]$Name,
    [string]$Year,
    [string]$TenantID
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            "Identity"= $Identity
                        }

    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',@($Name))
    }    
    if([System.String]::IsNullOrWhiteSpace($Year) -eq $false){
        $cmdArgs.Add('Year',@($Year))
    } 
    if([System.String]::IsNullOrWhiteSpace($TenantID) -eq $false){
        $cmdArgs.Add('Tenant',$TenantID)
    }    

    $result = Get-CsAutoAttendantHolidays  @cmdArgs | Select-Object *

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