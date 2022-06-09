#Requires -Version 5.0
#Requires -Modules Microsoft.Graph.Authentication

Import-Module Microsoft.Graph.Authentication

function ConnectMSGraph(){
    <#
        .SYNOPSIS
            Open a connection to Microsoft Graph

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.Graph.Authentication

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/MS Graph/_LIB_

        .Parameter ClientID
            Credential object containing the Microsoft Teams user/password

        .Parameter TenantID
            Specifies the ID of a tenant

        .Parameter CertificateThumbprint
            Specifies the log level

        .Parameter SecretValue
            Client Secret value
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true,ParameterSetName = "Certificate")]  
            [Parameter(Mandatory = $true,ParameterSetName = "ClientSecret")]
            [string]$ClientID,
            [Parameter(Mandatory = $true,ParameterSetName = "Certificate")]  
            [Parameter(Mandatory = $true,ParameterSetName = "ClientSecret")]
            [string]$TenantId,
            [Parameter(Mandatory = $true,ParameterSetName = "Certificate")]  
            [string]$CertificateThumbprint,
            [Parameter(Mandatory = $true,ParameterSetName = "ClientSecret")]
            [string]$SecretValue
            )
        
        try{
            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
            if($PSCmdlet.ParameterSetName -eq 'Certificate'){
                $cmdArgs.Add('ClientID',$ClientID)
                $cmdArgs.Add('TenantId',$TenantId)
                $cmdArgs.Add('CertificateThumbprint',$CertificateThumbprint)                
            }
            else{
                $uri = "https://login.microsoftonline.com/$($TenantId)/oauth2/v2.0/token"
                # Construct Body
                $body = @{
                    client_id     = $ClientID
                    scope         = "https://graph.microsoft.com/.default"
                    client_secret = $SecretValue
                    grant_type    = "client_credentials"
                    }
                $tokenRequest = Invoke-WebRequest –Method Post –Uri $uri –ContentType "application/x-www-form-urlencoded" –Body $body –UseBasicParsing
                $mgToken =($tokenRequest.Content | ConvertFrom-Json).access_token
                $cmdArgs.Add('AccessToken', $mgToken)
            }
            $null = Connect-MgGraph @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}
function DisconnectMSGraph(){
    <#
        .SYNOPSIS
            Closes the connection to Microsoft Graph

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.Graph.Authentication

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/MS Graph/_LIB_

        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            if($null -ne (Get-MgContext)){
                Disconnect-MgGraph 
            }
        }
        catch{
            throw
        }
        finally{
        }
}
function GetGroupMembers{
    <#
        .SYNOPSIS
            Returns the members of a group

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.Graph.Groups
    #>

    param(
        [Parameter(Mandatory =$True)]        
        [string]$GroupId,
        [Parameter(Mandatory =$True)]
        [ref]$Memberships
    )

    try{
        [bool]$connected = $false
        if($null -eq (Get-MgContext)){
            ConnectMSGraph
            $connected = $true
        }        
        if($null -eq (Get-Module -Name 'Microsoft.Graph.Groups')){
            Import-Module Microsoft.Graph.Groups
        }

        [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                                'GroupId' = $GroupId
                                'All' = $null
        }
        $mgGroupMembers = Get-MgGroupMember @cmdArgs | Select-Object *

        [PSCustomObject]$members = @()
        #groups 
        foreach($itm in $mgGroupMembers | Where-Object {$_.AdditionalProperties.ContainsValue("#microsoft.graph.group")} ){
            [PSCustomObject]$member = [PSCustomObject] @{DisplayName=''; Type='Group';Mail=''}
            if($itm.AdditionalProperties.ContainsKey('displayName')){
                $member.DisplayName = $itm.AdditionalProperties.displayName
            }
            if($itm.AdditionalProperties.ContainsKey('mail')){
                $member.Mail = $itm.AdditionalProperties.mail
            }
            $members += $member
        }
        # users
        foreach($itm in $mgGroupMembers | Where-Object {$_.AdditionalProperties.ContainsValue("#microsoft.graph.user")} ){
            [PSCustomObject]$member = [PSCustomObject] @{DisplayName=''; Type='User';Mail=''}
            if($itm.AdditionalProperties.ContainsKey('displayName')){
                $member.DisplayName = $itm.AdditionalProperties.displayName
            }
            if($itm.AdditionalProperties.ContainsKey('mail')){
                $member.Mail = $itm.AdditionalProperties.mail
            }
            $members += $member
        }
        $Memberships.Value = $members
    }
    catch{
        throw
    }
    finally{
        if($connected){
            DisconnectMSGraph
        }
    }
}
function GetGroupOwners{
    <#
        .SYNOPSIS
            Returns the owners of a group

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.Graph.Groups
    #>

    param(
        [Parameter(Mandatory =$True)]        
        [string]$GroupId,
        [Parameter(Mandatory =$True)]
        [ref]$Owners
    )

    try{
        [bool]$connected = $false
        if($null -eq (Get-MgContext)){
            ConnectMSGraph
            $connected = $true
        }        
        if($null -eq (Get-Module -Name 'Microsoft.Graph.Groups')){
            Import-Module Microsoft.Graph.Groups
        }

        [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                                'GroupId' = $GroupId
                                'All' = $null
        }
        $mgGroupOwners = Get-MgGroupOwner @cmdArgs | Select-Object *

        [PSCustomObject]$result = @()
        # users
        foreach($itm in $mgGroupOwners){
            [PSCustomObject]$owner = [PSCustomObject] @{DisplayName='';Mail='';Type='User'}
            if($itm.AdditionalProperties.ContainsKey('displayName')){
                $owner.DisplayName = $itm.AdditionalProperties.displayName
            }
            if($itm.AdditionalProperties.ContainsKey('mail')){
                $owner.Mail = $itm.AdditionalProperties.mail
            }
            $result += $owner
        }
        $Owners.Value = $result
    }
    catch{
        throw
    }
    finally{
        if($connected){
            DisconnectMSGraph
        }
    }
}