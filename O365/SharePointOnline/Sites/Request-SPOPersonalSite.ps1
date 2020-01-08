#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Requests that one or more users be enqueued for a Personal Site to be created
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Sites

    .Parameter UserEmails 
        Specifies one or more user logins to be enqueued for the creation of a Personal Site, comma separated. 
        You can specify between 1 and 200 users

    .Parameter NoWait
        Continues without the status being polled
#>

param(   
    [Parameter(Mandatory = $true)]  
    [string]$UserEmails ,
    [switch]$NoWait
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{      
    [string[]]$mails = $UserEmails.Split(',')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'UserEmails' = $mails
                            'NoWait' = $NoWait
                            }  
    $result = Request-SPOPersonalSite @cmdArgs | Select-Object *
      
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}