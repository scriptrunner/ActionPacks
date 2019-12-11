#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and sets the address list properties
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/AddressLists

    .Parameter ListName
        Specifies the unique name of the address list from which to set properties

    .Parameter NameOfList
        Specifies the unique name of the address list from which to set properties

    .Parameter DisplayName
        Specifies the display name of the address list

    .Parameter MailContacts
        Adds mail contacts to the recipients of the address list
    
    .Parameter MailboxUsers
        Adds mailbox users to the recipients of the address list

    .Parameter MailGroups
        Adds mail groups to the recipients of the address list

    .Parameter MailUsers
        Adds mail users to the recipients of the address list

    .Parameter Resources
        Adds resources to the recipients of the address list
#>

param(
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
    $Script:resi=@()
    $Script:list=$ListName
    if($PSCmdlet.ParameterSetName  -eq "Selected Recipients"){
        if($MailContacts -eq $true){
            $Script:resi+='MailContacts'
        }
        if($MailboxUsers -eq $true){
            $Script:resi+='MailboxUsers'
        }
        if($MailGroups -eq $true){
            $Script:resi+='MailGroups'
        }
        if($MailUsers -eq $true){
            $Script:resi+='MailUsers'
        }
        if($Resources -eq $true){
            $Script:resi+='Resources'
        }
        $Script:list= $NameOfList 
    }
    if([System.String]::IsNullOrWhiteSpace($resi)){
        $Script:resi+='AllRecipients'
    }
    $res= Get-AddressList -Identity $Script:list | Select-Object Name,DisplayName
    if([System.String]::IsNullOrWhiteSpace($DisplayName)){
        $DisplayName=$res.DisplayName
    }
    Set-AddressList -Identity $res.Name -DisplayName $DisplayName -IncludedRecipients ($resi -join ',') -ForceUpgrade -Confirm:$false
    $res= Get-AddressList -Identity $res.Name | Select-Object *
    
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
            $SRXEnv.ResultMessage = "Address list not found"
        } 
        else{
            Write-Output  "Address list not found"
        }
    }
}
catch{
    throw
}
Finally{
        
}