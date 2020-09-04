#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

function ConnectExchangeOnline(){
    <#
        .SYNOPSIS
            Open a connection to ExchangeOnline

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module ExchangeOnlineManagement

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline_v2/_LIB_

        .Parameter ExOCredential
            [sr-en] Credential object containing the Exchange Online user/password
            [sr-de] Gibt den Benutzernamen und das Kennwort an, zum Anmelden an Exchange Online an

        .Parameter CertificateThumbprint
            [sr-en] Thumbprint off a certificate stored within certification store
            [sr-de] Fingerabdruck eines Zertifikats, das im Zertifizierungsspeicher gespeichert ist

        .Parameter CertificateFilePath
            [sr-en] Path and file name of the certificate file
            [sr-de] Pfad und Dateiname der Zertifikatsdatei 

        .Parameter CertificatePassword
            [sr-en] Password of the certificate file
            [sr-de] Passwort der Zertifikatsdatei

        .Parameter ApplicationID
            [sr-en] ID of the registered application (Exchange manage as app)
            [sr-de] ID der registrierten Anwendung (Exchange manage per App)

        .Parameter ExchangeEnvironmentName
            [sr-en] Specifies the Exchange Online environment
            [sr-de] Gibt die Exchange Online Umgebung an

        .Parameter DelegateOrganization
            [sr-en] Specifies the customer organization that you want to manage (for example, DevStar.onmicrosoft.com)
            [sr-de] Gibt die Kundenorganisation an (z.B DevStar.onmicrosoft.com)

        .Parameter Organization
            [sr-en] Specifies the customer organization that you want to manage (for example, DevStar.onmicrosoft.com)
            [sr-de] Gibt die Kundenorganisation an (z.B DevStar.onmicrosoft.com)

        .Parameter LogLevel
            [sr-en] Specifies the log level
            [sr-de] Gibt die Protokollierungsstufe an

        .Parameter ConnectionEndpoint
            [sr-en] Specifies the connection endpoint for the remote PowerShell session
            [sr-de] Gibt den connection endpoint für die Remote-PowerShell-Sitzung an
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true,ParameterSetName = 'Credential')]  
            [PSCredential]$ExOCredential,
            [Parameter(Mandatory = $true,ParameterSetName = 'Thumbprint')]  
            [string]$CertificateThumbprint,          
            [Parameter(Mandatory = $true,ParameterSetName = 'CertificatePath')]  
            [string]$CertificateFilePath , 
            [Parameter(Mandatory = $true,ParameterSetName = 'CertificatePath')]  
            [Parameter(Mandatory = $true,ParameterSetName = 'Thumbprint')]  
            [string]$ApplicationID, 
            [Parameter(Mandatory = $true,ParameterSetName = 'CertificatePath')]  
            [Parameter(Mandatory = $true,ParameterSetName = 'Thumbprint')] 
            [string]$Organization,
            [Parameter(ParameterSetName = 'CertificatePath')]  
            [securestring]$CertificatePassword,  
            [Parameter(ParameterSetName = 'Credential')] 
            [string]$DelegateOrganization, 
            [Parameter(ParameterSetName = 'CertificatePath')]  
            [Parameter(ParameterSetName = 'Thumbprint')]  
            [Parameter(ParameterSetName = 'Credential')]  
            [ValidateSet('O365Default','O365GermanyCloud','O365USGovDoD','O365USGovGCCHigh','O365China')]
            [string]$ExchangeEnvironmentName = 'O365Default',
            [Parameter(ParameterSetName = 'CertificatePath')]
            [Parameter(ParameterSetName = 'Thumbprint')]    
            [Parameter(ParameterSetName = 'Credential')]  
            [ValidateSet('Default','O365 Germany','21Vianet','MS 365 GCC High','MS 365 DoD')]
            [string]$ConnectionEndpoint = 'Default',
            [Parameter(ParameterSetName = 'CertificatePath')]  
            [Parameter(ParameterSetName = 'Thumbprint')]  
            [Parameter(ParameterSetName = 'Credential')]  
            [ValidateSet('Default','All')]
            [string]$LogLevel = 'Default'
        )

        try{
            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'ShowBanner' = $false
                        'ShowProgress' = $false
                        'ExchangeEnvironmentName' = $ExchangeEnvironmentName
                        'LogLevel' = $LogLevel
                        'TrackPerformance' = $false
                        'UseMultithreading' = $true
                        }

            if($PSCmdlet.ParameterSetName -eq 'Credential'){
                $cmdArgs.Add('Credential', $ExOCredential)
            }
            if($PSCmdlet.ParameterSetName -eq 'Thumbprint'){
                $cmdArgs.Add('CertificateThumbprint', $CertificateThumbprint)
                $cmdArgs.Add('AppID', $ApplicationID)
                $cmdArgs.Add('Organization', $Organization)
            }
            if($PSCmdlet.ParameterSetName -eq 'CertificatePath'){
                $cmdArgs.Add('CertificateFilePath', $CertificateFilePath)
                $cmdArgs.Add('Organization', $Organization)
                $cmdArgs.Add('AppID', $ApplicationID)
                if([System.String]::IsNullOrWhiteSpace($CertificatePassword) -eq $false){
                    $cmdArgs.Add('CertificatePassword', $CertificatePassword)
                }
            }
            if([System.String]::IsNullOrWhiteSpace($DelegateOrganization) -eq $false){
                $cmdArgs.Add('DelegateOrganization', $DelegateOrganization)
            }

            switch ($ConnectionEndpoint){
                'O365 Germany'{
                    $cmdArgs.Add('ConnectionUri', 'https://outlook.office.de/PowerShell-LiveID')
                }
                '21Vianet'{
                    $cmdArgs.Add('ConnectionUri', 'https://partner.outlook.cn/PowerShell')
                }
                'MS 365 GCC High'{
                    $cmdArgs.Add('ConnectionUri', 'https://outlook.office365.us/powershell-liveid')
                }
                'MS 365 DoD'{
                    $cmdArgs.Add('ConnectionUri', 'https://webmail.apps.mil/powershell-liveid')
                }
            }

            $null = Connect-ExchangeOnline @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}
function ConnectExchangeOnlineIPSession(){
    <#
        .SYNOPSIS
            Use the Connect-IPPSSession cmdlet in the Exchange Online PowerShell V2 module to connect to Security & Compliance Center PowerShell or standalone Exchange Online Protection PowerShell

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module ExchangeOnlineManagement

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/_LIB_

        .Parameter ExOCredential
            [sr-en] Credential object containing the Exchange Online user/password
            [sr-de] Gibt den Benutzernamen und das Kennwort an zum Anmelden an Exchange Online an

        .Parameter ConnectionEndpoint
            [sr-en] Specifies the connection endpoint for the remote PowerShell session
            [sr-de] Gibt den connection endpoint für die Remote-PowerShell-Sitzung an
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true)]  
            [PSCredential]$ExOCredential,
            [ValidateSet('Default','O365 Germany','MS 365 GCC High','MS 365 DoD','Standalone EOP')]
            [string]$ConnectionEndpoint = 'Default'
        )

        try{
            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
            'Credential' = $ExOCredential
            }

            switch ($ConnectionEndpoint){
                'O365 Germany'{
                    $cmdArgs.Add('ConnectionUri', 'https://ps.compliance.protection.outlook.de/PowerShell-LiveID')
                }
                'MS 365 GCC High'{
                    $cmdArgs.Add('ConnectionUri', 'https://outlook.office365.us/powershell-liveid')
                }
                'MS 365 DoD'{
                    $cmdArgs.Add('ConnectionUri', 'https://l5.ps.compliance.protection.office365.us/powershell-liveid/')
                }
                'Standalone EOP'{
                    $cmdArgs.Add('ConnectionUri', 'https://ps.protection.outlook.com/powershell-liveid/')
                }
            }
            $null = Connect-IPPSSession @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}

function DisconnectExchangeOnline(){
    <#
        .SYNOPSIS
            Closes the connection to ExchangeOnline

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module ExchangeOnlineManagement

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline_v2/_LIB_

        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            $null = Disconnect-ExchangeOnline -Confirm:$false
        }
        catch{
            throw
        }
        finally{
        }
}