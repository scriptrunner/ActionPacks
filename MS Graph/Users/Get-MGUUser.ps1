#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Returns a user
    
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
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$UserId,
    [ValidateSet('AboutMe','AccountEnabled','AssignedLicenses','Birthday','BusinessPhones','City','CompanyName','Country','CreatedDateTime','DeletedDateTime','Department','DisplayName',
    'EmployeeId','EmployeeType','FaxNumber','GivenName','HireDate','Id','Interests','IsResourceAccount','JobTitle','LastPasswordChangeDateTime','LicenseDetails','Mail','MailNickname',
    'Manager','MemberOf','MobilePhone','OfficeLocation','OtherMails','PostalCode','PreferredLanguage','PreferredName','Schools','ShowInAddressList','Skills','State','StreetAddress','Surname','UserPrincipalName','UserType')]
    [string[]]$Properties = @('DisplayName','Id','GivenName','Surname','Mail','PostalCode','City','StreetAddress','CompanyName','Country','Department','AccountEnabled','LastPasswordChangeDateTime','CreatedDateTime','DeletedDateTime')
)

Import-Module Microsoft.Graph.Users

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if($PSBoundParameters.ContainsKey('UserId') -eq $true){
        $cmdArgs.Add('UserId',$UserId)
    }
    else{
        $cmdArgs.Add('All',$null)
        $cmdArgs.Add('Sort','DisplayName')
    }
    $result = Get-MgUser @cmdArgs | Select-Object $Properties

    if (Get-Command 'ConvertTo-ResultHtml' -ErrorAction Ignore) {
        ConvertTo-ResultHtml -Result $result
    }
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
    DisconnectMSGraph
}