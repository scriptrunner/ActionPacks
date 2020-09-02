#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Gets the Client Access settings that are configured on mailboxes
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Requires PS Module ExchangeOnlineManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/MailBoxes

    .Parameter Identity
        [sr-en] Specifies name, Guid or UPN of the mailbox
        [sr-de] Name, Guid oder UPN des Postfachs
    
    .Parameter AnrSearch
        [sr-en] Specifies a partial string for search objects with an attribute that matches that string. 
        The default attributes searched are: CommonName, DisplayName, FirstName, LastName, Alias
        [sr-de] Teilzeichenfolge für die Suche in einem Attribut. 
        Die standardmäßig durchsuchten Attribute sind CommonName, DisplayName, Vorname, Nachname, Alias        

    .Parameter ProtocolSettings
        [sr-en] Returns the server names, TCP ports and encryption methods
        [sr-de] Gibt die Servernamen, TCP-Ports und Verschlüsselungsmethoden für die Einstellungen zurück

    .Parameter ResultSize
        [sr-en] Specifies the maximum number of results to return
        [sr-de] Gibt die maximale Anzahl der zurückzugegebenen Ergebnisse an

    .Parameter PropertySet
        [sr-en] Specifies a logical grouping of properties
        [sr-de] Gibt eine logische Gruppierung von Eigenschaften an

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [Parameter(ParameterSetName = 'Default')]
    [string]$Identity,
    [Parameter(Mandatory=$true,ParameterSetName = 'Search')]
    [string]$AnrSearch,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [switch]$ProtocolSettings,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [int]$ResultSize = 1000,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('Minimum','All','ActiveSync','Ews','Imap','Mapi','Pop','ProtocolSettings')]
    [string]$PropertySet = 'Minimum',
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('*','Name','Identity','ActiveSyncEnabled','EwsEnabled','OWAEnabled','PopEnabled','ImapEnabled','MAPIEnabled','ECPEnabled','DisplayName','PrimarySmtpAddress','EmailAddresses','Guid')]
    [string[]]$Properties =  @('Name','PrimarySmtpAddress','ActiveSyncEnabled','EwsEnabled','OWAEnabled','PopEnabled','ImapEnabled','MAPIEnabled','ECPEnabled')
)

Import-Module ExchangeOnlineManagement

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'ResultSize' = $ResultSize
                    'PropertySets' = $PropertySet
                    'ProtocolSettings' = $ProtocolSettings
    }
    
    if($PSCmdlet.ParameterSetName -eq 'Search'){
        $cmdArgs.Add('Anr',$AnrSearch)
    }
    if([System.String]::IsNullOrWhiteSpace($Identity) -eq $false){
        $cmdArgs.Add('Identity',$Identity)
    }

    $box = Get-EXOCasMailbox @cmdArgs | Select-Object $Properties   
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $box
    } 
    else{
        Write-Output $box 
    }
}
catch{
    throw
}
finally{
    
}