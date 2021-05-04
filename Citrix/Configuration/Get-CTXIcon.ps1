#Requires -Version 5.0

<#
    .SYNOPSIS
        Get stored icons
    
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

    .Parameter FileName
        [sr-en] Name of a file from which to read the icon data
        [sr-de] Name einer Datei, aus der die Symboldaten gelesen werden sollen

    .Parameter IconId
        [sr-en] Icon specified by unique identifier
        [sr-de] ID des Icons 
#>

param( 
    [Parameter(Mandatory = $true, ParameterSetName = 'FileName')]
    [string]$FileName,
    [Parameter(ParameterSetName = 'FileName')]
    [int]$IconIndex,
    [Parameter(ParameterSetName = 'byId')]
    [int]$IconId,
    [string]$SiteServer
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)    

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }

    if($PSCmdlet.ParameterSetName -eq 'FileName'){
        $cmdArgs.Add('FileName',$FileName)
        if($PSBoundParameters.ContainsKey('IconIndex') -eq $true){
            $cmdArgs.Add('Index',$IconIndex)
        }
    }
    else{
        if($PSBoundParameters.ContainsKey('IconId') -eq $true){
            $cmdArgs.Add('Uid',$IconId)
        }
    }

    $ret = Get-BrokerIcon @cmdArgs | Select-Object *
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