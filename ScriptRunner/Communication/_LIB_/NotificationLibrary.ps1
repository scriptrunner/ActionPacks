#Requires -Version 5.0

function SRXSendMailTo {
    param(
        <#
        .SYNOPSIS
            Function for send mail. You can use the function from other scripts
        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH
        .DESCRIPTION
            With this function you can send e-mails, with or without attachments, from other scripts. 
            You need a SMTP server which allows anonymous authentication or authentication by credentials. 
            If you want to use Exchange Online as SMTP server, you have to configure the SMTP authentication first. 
            Microsoft strongly advises against this: 
            https://docs.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/authenticated-client-smtp-submission
        
        .PARAMETER MailSender
            Specifies the address from which the mail is sent
        .PARAMETER MailRecipients                
            Specifies the addresses to which the mail is sent. 
            Enter names (optional) and the e-mail address, such as "John Doe <john.doe@example.com>".
            Use the comma to separate the addresses
        .PARAMETER MailSubject
            Specifies the subject of the email message
        .PARAMETER MailBody
            Specifies the body of the email message
            
        .Parameter MailBodyEncoding
            Specifies the type of encoding for the body
        .PARAMETER MailUseSsl
            Uses the Secure Sockets Layer (SSL) protocol to establish a connection to the remote computer to send mail
        .PARAMETER MailPriority
            Specifies the priority of the email message. The acceptable values for this parameter are: Normal, High, Low
        .PARAMETER MailServer
            Specifies the name of the SMTP server that sends the e-mail message. 
            The default value is the value of the $PSEmailServer preference variable
        .PARAMETER MailServerCredential
            Specifies a user account that has permission to perform this action. The default is the current user.
        .PARAMETER CopyRecipients
            Specifies the e-mail addresses to which a carbon copy (CC) of the e-mail message is sent. 
            Enter names (optional) and the e-mail address, such as "John Doe <john.doe@example.com>".
            Use the comma to separate the addresses
        .PARAMETER Attachments
            Specifies the path and file names of files to be attached to the e-mail message. 
            Use the comma to separate the files
        .Parameter HtmlBody
            Specifies that the value of the Body parameter contains HTML
    #>
    
        [parameter(Mandatory = $true)]
        [string]$MailSender,
        [parameter(Mandatory = $true)]
        [string]$MailRecipients,
        [parameter(Mandatory = $true)]
        [string]$MailSubject,
        [string]$MailBody,
        [bool]$MailUseSsl,
        [ValidateSet('Normal', 'High', 'Low')]    
        [string]$MailPriority = 'Normal',
        [ValidateSet('UTF8', 'ASCII', 'Default', 'UTF32', 'BigEndianUnicode', 'Byte', 'OEM', 'String', 'Unicode', 'UTF7', 'UTF8BOM', 'UTF8NoBOM')]
        [string]$MailBodyEncoding = 'UTF8',
        [string]$MailServer,
        [PSCredential]$MailServerCredential,
        [string]$CopyRecipients, 
        [string]$Attachments,
        [bool]$HtmlBody = $true
    )
    
    try {
        if ([System.String]::IsNullOrEmpty($MailBody) -eq $true) { 
            $MailBody = ' ' 
        } 
        
        $toTmp = $MailRecipients.Split(',')
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
            'BodyAsHtml'                      = $HtmlBody
            'To'                              = $toTmp
            'Subject'                         = $MailSubject
            'Body'                            = $MailBody
            'From'                            = $MailSender
            'Priority'                        = $MailPriority
            'UseSsl'                          = $MailUseSsl
            'Encoding'                        = $MailBodyEncoding
        }
        if ([System.String]::IsNullOrWhiteSpace($MailServer) -eq $false) {
            # Server
            $cmdArgs.Add('SmtpServer' , $MailServer)
        }                                   
        if ([System.String]::IsNullOrWhiteSpace($CopyRecipients) -ne $true) {
            # CC
            $ccTmp = $CopyRecipients.Split(',')
            $cmdArgs.Add('Cc', $ccTmp)
        }
        if ([System.String]::IsNullOrWhiteSpace($Attachments) -ne $true) {
            # Attachments
            $filTmp = $Attachments.Split(',')
            $cmdArgs.Add('Attachments', $filTmp)
        }
        if ($null -ne $MailServerCredential) {
            # Credential
            $cmdArgs.Add('Credential', $MailServerCredential)
        }
        Send-MailMessage @cmdArgs
        Write-Output "Mail sent"
    }
    catch {
        throw $Error[0]
    }
}

function SRXPostToTeamsChannel {
    <#
        .SYNOPSIS
            Function to send a message to a Teams Channel. You can use the function from other scripts
        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH
        .DESCRIPTION
            This function allows you to post messages to a Microsoft Teams channel. 
            It is possible to post the message in card format to the channel via an incoming webhook. 
            You can specify a title, the message, the message color, the title of an activity, 
            the subtitle of an activity and activity facts. 
            It is currently not possible to post attachments to the channel via a webhook.  
        .Parameter WebhookURL
            Enter the URL of the Webhook corresponding to the Teams Channel            
        .Parameter Message
            Enter the Message you want to send
        .Parameter Title
            Give the Message a Title
        .Parameter MessageColor
            Here you can set a color for your message
        .Parameter ActivityTitle
            Set a title for an activitx
        .Parameter ActivitySubtitle
            Set a subtitle for an activity
        .Parameter ActivityFacts
            Enter facts for the activity
    #>

    Param(
        [Parameter(Mandatory = $true)]   
        [string]$WebhookURL,
        [Parameter(Mandatory = $true)]   
        [string]$Message,
        [string]$Title,
        [ValidateSet('Orange', 'Green', 'Red')]
        [string]$MessageColor,
        [string]$ActivityTitle,
        [string]$ActivitySubtitle
    )

    try {        
        [hashtable]$cmdArgs = @{} 
        [hashtable]$section = @{}
        if ([System.String]::IsNullOrWhiteSpace($Title) -eq $false) {
            $cmdArgs.Add('Title', $Title)
        } 
        if ([System.String]::IsNullOrWhiteSpace($ActivityTitle) -eq $false) {
            $section.Add('activityTitle', $ActivityTitle)
        } 
        if ([System.String]::IsNullOrWhiteSpace($ActivitySubtitle) -eq $false) {
            $section.Add('activitySubtitle', $ActivitySubtitle)
        }  
        $cmdArgs.Add('Text', $Message)

        switch ($MessageColor) {
            'Orange' {
                $cmdArgs.Add('themeColor', 'FFC300')            
            }
            'Green' {
                $cmdArgs.Add('themeColor', '008000')            
            }
            'Red' {
                $cmdArgs.Add('themeColor', 'FF0000')
            }
        }  
        
        # Build the request 
        $Params = @{ 
            Headers = @{'accept' = 'application/json' } 
            Body    = $cmdArgs | ConvertTo-Json -Depth 5
            Method  = 'Post' 
            URI     = $WebhookURL  
        } 
        $null = Invoke-RestMethod @Params  
    }
    catch {
        throw $Error[0]
    }
    finally {
    }
    
}

function SRXPostToYammer {
    <#
        .SYNOPSIS
            Sends a message to a Yammer group
        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH
        .DESCRIPTION
            With this function it is possible to post messages to a specific community or group in Yammer. Unlike the functions for MS Teams or Slack
            authentication via OAuth 2.0 and an authorized app in Azure AD is required here. So far, it is not possible to add an attachment to the message.
        .Parameter tokenUri
            Enter the URI to the endpoint where the token is to obtain            
        .Parameter clientId
            Enter the Client ID of your ScriptRunner or self registered App
        .Parameter ClientSecret
            Enter the Client Secret of your ScriptRunner or self registered App
        .Parameter tokenCredential
            Enter the credentials whom allowed to obtain an access token
        .Parameter grantType
            Enter the grant type (in our case it is "password")
        .Parameter scope
            Enter the scope to your app (in our case it should be "https://api.yammer.com/user_impersonation")
        .Parameter method
            Enter the method for the HTTP Request
        .Parameter groupId
            Enter the ID of the group in Yammer you want to send a message to
        .Parameter yammerMessage
            Enter the message
        .Parameter yammerUri
            Specifies the URI to the Yammer API Endpoint
     
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$tokenUri,
        [Parameter(Mandatory = $true)]
        [string]$clientId,
        [Parameter(Mandatory = $true)]
        [string]$clientSecret,
        [Parameter(Mandatory = $true)]
        [pscredential]$tokenCredential,
        [Parameter(Mandatory = $true)]
        [string]$grantType,
        [Parameter(Mandatory = $true)]
        [string]$scope,
        [Parameter(Mandatory = $true)]
        [ValidateSet("POST", "GET", "PUT", "DEL")]
        [string]$method,
        [string]$groupId,
        [string]$yammerMessage,
        [string]$yammerUri
    )

    #Decrypting the Password of the PSCredential Object, because the "password" attribute doesnt take a secure string
    $passTransition = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($tokenCredential.Password)
    $decryptedPass = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($passTransition)

    try {
        [hashtable]$body = @{
            'grant_type'    = $grantType
            'client_id'     = $clientId
            'client_secret' = $clientSecret
            'username'      = $tokenCredential.UserName
            'password'      = $decryptedPass
            'scope'         = $scope
        }
        [hashtable]$headers = @{
            'Accept' = 'application/json'
        }
    
        $tokenResult = Invoke-WebRequest -Uri $tokenUri -Method 'POST' -Headers $headers -Body $body -UseBasicParsing | ConvertFrom-Json
    
        if ($PSVersionTable) {
            if ($PSVersionTable.PSEdition -eq "Core") {
                $authToken = $tokenResult.access_token | ConvertTo-SecureString -AsPlainText -Force
    
                $params = @{
                    "Uri"            = $yammerUri
                    "Authentication" = "Bearer"
                    "Token"          = $authToken 
                    "Method"         = $method
                    "Body"           = @{
                        "body"     = $yammerMessage
                        "group_id" = $groupId
                    }
                }
                $null = Invoke-RestMethod @params | ConvertTo-Json -Depth 5
    
            }
            elseif ($PSVersionTable.PSEdition -eq "Desktop") {
                $authToken = $tokenResult.access_token
                $headers.Remove('Accept')
                $headers.Add('Authorization', "Bearer $($authToken)")
                $blah = @{
                    "body"     = $yammerMessage
                    "group_id" = $groupId  
                }
                $null = Invoke-WebRequest -Uri $yammerUri -Method $method -Headers $headers -Body $blah -UseBasicParsing
    
            }
        }
        else {
            Write-Host "$PSVersionTable is not present"
        }
        
    }
    catch {
        throw $Error[0]
    }    
}

function SRXPostToSlackChannel {
    <#
        .SYNOPSIS
            Sends a message to a Team Channel
        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH
        .DESCRIPTION
            This function allows you to post a message to a Slack channel. Unlike MS Teams or Yammer, however, the options 
            here are severely limited. The message is also transmitted to an incoming webhook, but it is only possible to transmit the message itself. 
            There are few to no formatting options such as a title or font color.
        .Parameter WebhookURL
            Enter the URL of the Webhook corresponding to the Slack Channel           
        .Parameter Message
            Enter the Message you want to send to the Slack Channel    
    #>

    Param(
        [Parameter(Mandatory = $true)]   
        [string]$WebhookURL,
        [Parameter(Mandatory = $true)]   
        [string]$Message
    )

    try {        
        [hashtable]$cmdArgs = @{}
        if ([System.String]::IsNullOrWhiteSpace($Message) -eq $false) {
            $cmdArgs.Add("text", $Message)
        }
  
        # Build the request 
        $Params = @{ 
            Headers = @{'accept' = 'application/json' } 
            Body    = $cmdArgs | ConvertTo-Json -Depth 5
            Method  = 'Post' 
            URI     = $WebhookURL  
        } 
        Invoke-RestMethod @Params  
    }
    catch {
        throw $Error[0]
    }
    finally {
    }
    
}


    


