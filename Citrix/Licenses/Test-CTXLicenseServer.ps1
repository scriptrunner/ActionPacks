#Requires -Version 5.0

<#
    .SYNOPSIS
        Tests whether or not a license server can be used by the broker
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Licenses
        
    .Parameter ServerAddress
        [sr-en] Address of a XenDesktop controller
        [sr-de] Name des XenDesktop Controller

    .Parameter ServerPort
        [sr-en] License Server port number
        [sr-de] Port des Lizenzservers

    .Parameter LicenseServer
        [sr-en] The name of the license server to test
        [sr-de] Name des zu testenden Lizenzservers
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$LicenseServer,
    [string]$ServerAddress,
    [int]$ServerPort = 27000
)                                                            

try{ 
    StartCitrixSession
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ComputerName' = $LicenseServer
                            'Port' = $ServerPort
                            }

    if($PSBoundParameters.ContainsKey('ServerAddress') -eq $true){
        $cmdArgs.Add('AdminAddress',$ServerAddress)
    }     
    
    $ret = Test-BrokerLicenseServer @cmdArgs| Select-Object *

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
    CloseCitrixSession
}