#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups 

<#
    .SYNOPSIS
        Returns a group
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Groups 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Groups

    .Parameter GroupId
        [sr-en] Group identifier
        [sr-de] Gruppen ID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$GroupId,
    [ValidateSet('AcceptedSenders','CreatedDateTime','DeletedDateTime','Description','DisplayName','Id','IsArchived','Mail','MailEnabled','MailNickname','MemberOf','Members','Owners','Specialization','Visibility','GroupTypes','PreferredLanguage','ProxyAddresses','RenewedDateTime','SecurityEnabled','SecurityIdentifier')]
    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime','Mail','MailEnabled')
)

Import-Module Microsoft.Graph.Groups 

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if($PSBoundParameters.ContainsKey('GroupID') -eq $true){
        $cmdArgs.Add('GroupId',$GroupId)
    }
    else{
        $cmdArgs.Add('All',$null)
        $cmdArgs.Add('Sort','DisplayName')
    }
    $mgGroup = Get-MgGroup @cmdArgs | Select-Object $Properties

    if (Get-Command 'ConvertTo-ResultHtml' -ErrorAction Ignore) {
        ConvertTo-ResultHtml -Result $mgGroup
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgGroup
    }
    else{
        Write-Output $mgGroup
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}