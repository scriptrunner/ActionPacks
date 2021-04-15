# Communication

+ [Send-SRMail.ps1](./Send-SRMail.ps1)

   Sends an e-mail message<br>
   You can use the script as a function script. The script must be tagged \_Lib_ for this purpose. <br>
   To load the script into the Powershell session automatically, it should be included in the PowerShell options of the action. Not all parameters are necessary.<br>
   You can also work with a variable in the main script.<br><br>
   Example 1 for calling the SendMail function in your main script:<br> SendMail 'sender@example.com>' 'receipient@example.com>' 'My subject' 'Body text' $true 'Normal' 'smtp.fabrikam.com'<br><br>
   Example 2 for calling the SendMail function in your main script:<br> 
   SendMail -MailSender 'sender@example.com' -MailRecipients 'receipient1@example.com,receipient2@example.com' -MailSubject 'My subject' -MailBody 'Body text' -MailUseSsL $true -MailPriority 'Normal' -MailServer 'smtp.fabrikam.com'<br><br>
   Example 3 for calling the SendMail function in your main script:<br>
   $sender = 'sender@example.com'<br>
   $receipient = 'receipient@example.com'<br>
   $subject = 'MysubjectText'<br>
   $mailhost = 'smtp.example.com'<br>
   SendMail $sender $receipient $subject 'Mybodytext' $mailhost<br>
   
