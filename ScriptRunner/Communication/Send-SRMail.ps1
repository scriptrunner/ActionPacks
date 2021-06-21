#Requires -Version 4.0
  
function SRSendMail
{
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
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]$MailSender,
        [parameter(Mandatory = $true)]
        [string]$MailRecipients,
        [parameter(Mandatory = $true)]
        [string]$MailSubject,
        [string]$MailBody,
        [bool]$MailUseSsl,
        [ValidateSet('Normal','High','Low')]    
        [string]$MailPriority ='Normal',
        [ValidateSet('UTF8','ASCII','Default','UTF32','BigEndianUnicode','Byte','OEM','String','Unicode','UTF7','UTF8BOM','UTF8NoBOM')]
        [string]$MailBodyEncoding = 'UTF8',
        [string]$MailServer ,
        [PSCredential]$MailServerCredential,
        [string]$CopyRecipients, 
        [string]$Attachments,
        [bool]$HtmlBody = $true
    )
    
    try{
        if([System.String]::IsNullOrEmpty($MailBody) -eq $true){ 
            $MailBody = ' ' 
        } 
        
        $toTmp = $MailRecipients.Split(',')
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'BodyAsHtml' = $HtmlBody
                                'To' = $toTmp
                                'Subject' = $MailSubject
                                'Body' = $MailBody
                                'From' = $MailSender
                                'Priority' = $MailPriority
                                'UseSsl' = $MailUseSsl
                                'Encoding' = $MailBodyEncoding
                                }
        if([System.String]::IsNullOrWhiteSpace($MailServer) -eq $false){    # Server
            $cmdArgs.Add('SmtpServer' ,$MailServer)
        }                                   
        if([System.String]::IsNullOrWhiteSpace($CopyRecipients) -ne $true){ # CC
            $ccTmp = $CopyRecipients.Split(',')
            $cmdArgs.Add('Cc', $ccTmp)
        }
        if([System.String]::IsNullOrWhiteSpace($Attachments) -ne $true){  # Attachments
            $filTmp = $Attachments.Split(',')
            $cmdArgs.Add('Attachments', $filTmp)
        }
        if($null -ne $MailServerCredential){# Credential
            $cmdArgs.Add('Credential', $MailServerCredential)
        }
        Send-MailMessage @cmdArgs
        Write-Output "Mail sent out"
    }
    catch{
        throw
    }
}