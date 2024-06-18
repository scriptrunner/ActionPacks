#Requires -Version 5.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and creates the address list
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/AddressLists

    .Parameter ListName
        [sr-en] Unique name of the address list. The maximum length is 64 characters.

    .Parameter NameOfList
        [sr-en] Unique name of the address list. The maximum length is 64 characters.

    .Parameter DisplayName
        [sr-en] Display name of the address list

    .Parameter MailContacts
        [sr-en] Adds mail contacts to the recipients of the address list
    
    .Parameter MailboxUsers
        [sr-en] Adds mailbox users to the recipients of the address list

    .Parameter MailGroups
        [sr-en] Adds mail groups to the recipients of the address list

    .Parameter MailUsers
        [sr-en] Adds mail users to the recipients of the address list

    .Parameter Resources
        [sr-en] Adds resources to the recipients of the address list
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [Parameter(Mandatory = $true)]
    [PSCredential]$AdminAccount,
    [Parameter(Mandatory = $true,ParameterSetName="All Recipients")]
    [string]$ListName,
    [Parameter(Mandatory = $true,ParameterSetName="Selected Recipients")]    
    [string]$NameOfList,
    [Parameter(ParameterSetName="All Recipients")]
    [Parameter(ParameterSetName="Selected Recipients")]
    [string]$DisplayName,
    [Parameter(ParameterSetName="Selected Recipients")]
    [bool]$MailContacts,
    [Parameter(ParameterSetName="Selected Recipients")]
    [bool]$MailboxUsers,
    [Parameter(ParameterSetName="Selected Recipients")]
    [bool]$MailGroups,
    [Parameter(ParameterSetName="Selected Recipients")]
    [bool]$MailUsers,
    [Parameter(ParameterSetName="Selected Recipients")]
    [bool]$Resources
)

try{
    if([System.String]::IsNullOrWhiteSpace($DisplayName)){
        $DisplayName=$ListName
    }
    if($PSCmdlet.ParameterSetName  -eq "Selected Recipients"){
        $resi=@()
        if($MailContacts -eq $true){
            $resi+='MailContacts'
        }
        if($MailboxUsers -eq $true){
            $resi+='MailboxUsers'
        }
        if($MailGroups -eq $true){
            $resi+='MailGroups'
        }
        if($MailUsers -eq $true){
            $resi+='MailUsers'
        }
        if($Resources -eq $true){
            $resi+='Resources'
        }
        if([System.String]::IsNullOrWhiteSpace($resi)){
            $resi+='AllRecipients'
        }
        $res = New-AddressList  -Name $NameOfList -DisplayName $DisplayName -IncludedRecipients ($resi -join ',') -Confirm:$false
    }
    else{
        $res = New-AddressList  -Name $ListName -DisplayName $DisplayName -IncludedRecipients 'AllRecipients' -Confirm:$false
    }
    if($null -ne $res){        
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $res  
        }
        else{
            Write-Output $res
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Address list not created"
        } 
        else{
            Write-Output  "Address list not created"
        }
    }
}
catch{
    throw
}
Finally{
    
}