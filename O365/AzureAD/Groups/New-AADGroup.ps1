#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and adds a new group

    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Azure Active Directory Powershell Module v2
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Groups

    .Parameter GroupName
        Specifies the display name of the group

    .Parameter Description
        Specifies a description of the group

    .Parameter MailEnabled
        Indicates whether mail is enabled

    .Parameter SecurityEnabled
        Indicates whether the group is security-enabled
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    [string]$Description<#,
    [bool]$MailEnabled,
    [bool]$SecurityEnabled#>
)

try{
    if([System.String]::IsNullOrEmpty($Description)){
        $Description = ' '
    }
    $Script:Grp = New-AzureADGroup -DisplayName $GroupName -SecurityEnabled $true -Description $Description `
                    -MailEnabled $false -MailNickName 'NotSet' | Select-Object *    
    if($null -ne $Script:Grp){
        $res=@("Group $($GroupName) created",$Script:Grp)
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group $($GroupName) created"
        } 
        else{
            Write-Output $res
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group not created"
        }    
        Throw "Group not created"
    }
}
finally{
 
}