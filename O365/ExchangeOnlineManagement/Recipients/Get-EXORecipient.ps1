#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Gets the recipient objects in your organization
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/Recipients

    .Parameter Identity
        [sr-en] Specifies name, Guid or UPN of the recipient object
        [sr-de] Name, Guid oder UPN des Empfängers
    
    .Parameter AnrSearch
        [sr-en] Specifies a partial string for search objects with an attribute that matches that string. 
        The default attributes searched are: CommonName, DisplayName, FirstName, LastName, Alias
        [sr-de] Teilzeichenfolge für die Suche in einem Attribut. 
        Die standardmäßig durchsuchten Attribute sind CommonName, DisplayName, Vorname, Nachname, Alias        

    .Parameter IncludeSoftDeletedRecipients
        [sr-en] Specifies whether to include soft deleted recipients in the results
        [sr-de] Gibt an, ob vorläufig gelöschte Empfänger in die Ergebnisse einbezogen werden sollen

    .Parameter RecipientType
        [sr-en] Filters the results by the specified recipient type
        [sr-de] Filtert die Ergebnisse nach dem angegebenem Empfängertyp

    .Parameter RecipientTypeDetails
        [sr-en] Filters the results by the specified recipient type
        [sr-de] Filtert die Ergebnisse nach dem angegebenen Empfänger Untertyp

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
    [switch]$IncludeSoftDeletedRecipients,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('DynamicDistributionGroup','MailContact','MailNonUniversalGroup','MailUniversalDistributionGroup','MailUniversalSecurityGroup','MailUser','PublicFolder','UserMailbox')]
    [string[]]$RecipientType,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('DiscoveryMailbox','DynamicDistributionGroup','EquipmentMailbox','GroupMailbox','GuestMailUser','LegacyMailbox','LinkedMailbox','LinkedRoomMailbox','MailContact','MailForestContact','MailNonUniversalGroup','MailUniversalDistributionGroup','MailUniversalSecurityGroup','MailUser','PublicFolder','PublicFolderMailbox','RemoteEquipmentMailbox','RemoteRoomMailbox','RemoteSharedMailbox','RemoteTeamMailbox','RemoteUserMailbox','RoomList','RoomMailbox','SchedulingMailbox','SharedMailbox','TeamMailbox','UserMailbox')]
    [string[]]$RecipientTypeDetails,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [int]$ResultSize = 1000,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('Minimum','Archive','Custom','MailboxMove','Policy','All')]
    [string]$PropertySet = 'Minimum',
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Search')]
    [ValidateSet('*','Name','Identity','FirstName','LastName,','City','Company','CountryOrRegion','PostalCode','Department','Office','Alias','DisplayName','DistinguishedName','RecipientType','PrimarySmtpAddress','EmailAddresses','Guid')]
    [string[]]$Properties =  @('Name','FirstName','LastName,','Identity','Alias','DisplayName','PrimarySmtpAddress')
)

Import-Module ExchangeOnlineManagement

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'ResultSize' = $ResultSize
                    'PropertySets' = $PropertySets
                    'IncludeSoftDeletedRecipients' = $IncludeSoftDeletedRecipients
    }
    
    if($PSCmdlet.ParameterSetName -eq 'Search'){
        $cmdArgs.Add('Anr',$AnrSearch)
    }
    if([System.String]::IsNullOrWhiteSpace($Identity) -eq $false){
        $cmdArgs.Add('Identity',$Identity)
    }
    if($PSBoundParameters.ContainsKey('RecipientType') -eq $true){
        $cmdArgs.Add('RecipientType',$RecipientType)
    }
    if($PSBoundParameters.ContainsKey('RecipientTypeDetails') -eq $true){
        $cmdArgs.Add('RecipientTypeDetails',$RecipientTypeDetails)
    }

    $result = Get-EXORecipient @cmdArgs | Select-Object $Properties   
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    } 
    else{
        Write-Output $result 
    }
}
catch{
    throw
}
finally{
    
}