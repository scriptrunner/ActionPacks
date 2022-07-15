#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Mail 

<#
    .SYNOPSIS
        Updates user mail folder child folder message
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Mail 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Mail

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter MailFolderId
        [sr-en] Id of the mail folder
        [sr-de] Ordner ID

    .Parameter ChildFolderId
        [sr-en] Mail folder child folder identifier
        [sr-de] Mailordner-Unterordner ID

    .Parameter MessageId
        [sr-en] Id of the message
        [sr-de] Mail ID

    .Parameter Subject
        [sr-en] Mail subject
        [sr-de] Betreff

    .Parameter BodyPreview
        [sr-en] First 255 characters of the message body
        [sr-de] Die ersten 255 Zeichen des Mail-Bodys

    .Parameter Categories
        [sr-en] Categories associated with the item
        [sr-de] Kategorien
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$MailFolderId,
    [Parameter(Mandatory = $true)]
    [string]$ChildFolderId,
    [Parameter(Mandatory = $true)]
    [string]$MessageId,
    [string]$Subject,
    [string]$BodyPreview,
    [string[]]$Categories
)

Import-Module Microsoft.Graph.Mail 

try{
    [string[]]$Properties = @('Subject','Id','BodyPreview','ReceivedDateTime','SentDateTime','Categories')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'UserId' = $UserId
                        'MailFolderId' = $MailFolderId
                        'MailFolderId1' = $ChildFolderId
                        'MessageId' = $MessageId
                        'Confirm' = $false
                        'PassThru' = $null
    }
    if($PSBoundParameters.ContainsKey('Subject') -eq $true){
        $cmdArgs.Add('Subject',$Subject)
    }
    if($PSBoundParameters.ContainsKey('BodyPreview') -eq $true){
        $cmdArgs.Add('BodyPreview',$BodyPreview)
    }
    if($PSBoundParameters.ContainsKey('Categories') -eq $true){
        $cmdArgs.Add('Categories',$Categories)
    }
    $null = Update-MgUserMailFolderChildFolderMessage  @cmdArgs | Select-Object $Properties

    $result = Get-MgUserMailFolderChildFolderMessage -MessageId $MessageId -UserId $UserId -MailFolderId $MailFolderId `
                                 -MailFolderId1 $ChildFolderId | Select-Object $Properties
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