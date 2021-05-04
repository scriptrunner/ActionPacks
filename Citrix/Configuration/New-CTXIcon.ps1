#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates a new icon
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Configuration
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers
    
    .Parameter IconIndex
        [sr-en] Zero-based icon resource index
        [sr-de] Null-basierter Icon-Index

    .Parameter IconSource
        [sr-en] Name of a file from which to read the icon data to create
        [sr-de] Name einer Datei, aus der die Symboldaten zum Anlegen gelesen werden

    .Parameter EncodedIconData
        [sr-en] Base64 encoded .ICO format icon data
        [sr-de] Base64-kodierte Symboldaten im .ICO-Format
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = "SourceFile")]
    [int]$IconIndex,
    [Parameter(Mandatory = $true,ParameterSetName = "SourceFile")]
    [string]$IconSource,
    [Parameter(Mandatory = $true,ParameterSetName = "EncodedData")]
    [string]$EncodedIconData,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    [string]$logText = "Create Icon"
    if($PSCmdlet.ParameterSetName -eq 'SourceFile'){
        $logText = "Create Icon $($IconIndex) from $($IconSource)"
        $EncodedIconData = Invoke-Command -ComputerName $SiteServer -ScriptBlock {
                                param(
                                    $idx,
                                    $file
                                )

                                $icon = Get-BrokerIcon -FileName $file -Index $idx 
                                $icon.EncodedIconData
                            } -ArgumentList $IconIndex,$IconSource
    }
    StartLogging -ServerAddress $SiteServer -LogText $logText -LoggingID ([ref]$LogID)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'EncodedIconData' = $EncodedIconData
                            'LoggingId' = $LogID
                            }

    $ret = New-BrokerIcon @cmdArgs | Select-Object *
    $success = $true
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
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}