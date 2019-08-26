#Requires -Version 5.0
#Requires -Modules microsoftteams

function ConnectMSTeams(){
    <#
        .SYNOPSIS
            Open a connection to Microsoft Teams

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
            © AppSphere AG

        .COMPONENT
            Requires Module microsoftteams

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_LIB_

        .Parameter MTCredential
            Credential object containing the Microsoft Teams user/password

        .Parameter TenantID
            Specifies the ID of a tenant

        .Parameter LogLevel
            Specifies the log level
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true)]  
            [PSCredential]$MTCredential,
            [string]$TenantId,
            [ValidateSet('Info','Error','Warning','None')]
            [string]$LogLevel = 'Info'
        )

        try{
            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'Confirm' = $false
                        'LogLevel' = $LogLevel
                        'Credential' = $MTCredential
                        }
            if([System.String]::IsNullOrWhiteSpace($TenantId) -eq $false){
                $cmdArgs.Add('TenantId', $TenantId)
            }
            $null = Connect-MicrosoftTeams @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}

function DisconnectMSTeams(){
    <#
        .SYNOPSIS
            Closes the connection to Microsoft Teams

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
            © AppSphere AG

        .COMPONENT
            Requires Module microsoftteams

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_LIB_

        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            Disconnect-MicrosoftTeams -Confirm:$false
        }
        catch{
            throw
        }
        finally{
        }
}

function FillParameters(){
<#
    .SYNOPSIS
        Writes parameter values to parameter hashtable

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT
        Requires Module microsoftteams

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_LIB_

    .Parameter BoundParameters
        PSBoundParameters
    #>

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $true)]  
        $BoundParameters
    )

    try{
        if($null -eq $BoundParameters){
            return
        }
        foreach($key in $BoundParameters.Keys){
            if($BoundParameters.Item($key).GetType().Name -eq 'Boolean'){
                $Global:cmdArgs.Add($key,$BoundParameters.Item($key))
                $Global:Properties += $key
            }
        }
    }
    catch{
        throw
    }
    finally{
    }
}

function SendMessage2Channel{
    <#
        .SYNOPSIS
            Sends a message to a Team Channel

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
            © AppSphere AG

        .COMPONENT
            Requires Module microsoftteams

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_LIB_
    
        .Parameter WebhookURL
            The URL of your Webhook, it must be match with "https://outlook.office.com/webhook/"
            
        .Parameter Message
            The body of the message to publish on Teams

        .Parameter Title
            The Title of the message to publish on Teams

        .Parameter MessageColor
            The color theme for the message

        .Parameter ActivityTitle
            The Activity title of the message to publish on Teams

        .Parameter ActivitySubtitle
            The Activity subtitle of the message to publish on Teams
    #>

    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $true)]   
        [ValidatePattern("^https://outlook.office.com/webhook/*")]
        [string]$WebhookURL,
        [Parameter(Mandatory = $true)]   
        [string]$Message,
        [string]$Title,
        [ValidateSet('Orange','Green','Red')]
        [string]$MessageColor,
        [string]$ActivityTitle,
        [string]$ActivitySubtitle
    )

    try{
        [hashtable]$cmdArgs = @{} 
        [hashtable]$section =@{}
        if([System.String]::IsNullOrWhiteSpace($Title) -eq $false){
            $cmdArgs.Add('Title',$Title)
        } 
        if([System.String]::IsNullOrWhiteSpace($ActivityTitle) -eq $false){
            $section.Add('activityTitle',$ActivityTitle)
        } 
        if([System.String]::IsNullOrWhiteSpace($ActivitySubtitle) -eq $false){
            $section.Add('activitySubtitle',$ActivitySubtitle)
        }  
        $cmdArgs.Add('Text',$Message)
        $cmdArgs.Add('sections',@($section))

        switch ($MessageColor){
            'Orange'{
                $cmdArgs.Add('themeColor','FFC300')            
            }
            'Green'{
                $cmdArgs.Add('themeColor','008000')            
            }
            'Red'{
                $cmdArgs.Add('themeColor','FF0000')
            }
        }  
        
        # Build the request 
        $Params = @{ 
            Headers = @{'accept'='application/json'} 
            Body = $cmdArgs | ConvertTo-Json 
            Method = 'Post' 
            URI = $WebhookURL  
        } 
        $null = Invoke-RestMethod @Params  
    }
    catch{
        throw
    }
    finally{
    }
}