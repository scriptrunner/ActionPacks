#Requires -Version 5.0

<#
    .SYNOPSIS
        Sample script of a offboarding process
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module ActiveDirectory, AzureAD, MicrosoftTeams
        Requires Library script OnOffBoardingLib.ps1

    .LINK        
        
    .Parameter ADAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter ADCsvFile
        Specifies the path and filename of the CSV file to remove users in Active Directory
        
    .Parameter O365Account
        Azure Active Directory Credential

    .Parameter O365CsvFile
        Specifies the path and filename of the CSV file to remove users in O365

    .Parameter ADUsers    
        Specifies the users to be delete from the Active Directory

    .Parameter O365Users    
        Specifies the users to be delete from the Azure Active Directory

    .Parameter DisableUsers
        Users will be disabled, not deleted

    .Parameter MoveToOU
        Users will be moved, not deleted

    .Parameter HideInAddressbook
        Users will be hides in the address lists

    .Parameter RemoveMailbox
        Removes user mailbox in Exchange

    .Parameter RemoveMailboxPermanent
        Removes user mailbox permanent in Exchange

    .Parameter DisableMailbox
        Disables user mailbox in Exchange

    .Parameter ForwardToMailboxId
        Forwards messages to this mailbox

    .Parameter RemoveFromTeams
        Users are removed from the MS Teams

    .Parameter Delimiter
        Specifies the delimiter that separates the property values in the CSV file

    .Parameter FileEncoding
        Specifies the type of character encoding that was used in the CSV file

    .Parameter AzureDomain
        Name of Azure Domain e.g. Contoso.com

    .Parameter ExchangeAccount
        Credential with sufficient permissions on Microsoft Exchange Server

    .Parameter ExchangeServerFQDN
        Specifies the Fully Qualified Domain Name of the Microsoft Exchange Server    

    .Parameter ExchangeRemoveFromDistributionGroups
        Removes the user in the distribution groups

    .Parameter DomainName
        Name of Active Directory Domain
    
    .Parameter ADAuthType
        Specifies the authentication method to use

    .Parameter O365Tenant
        Specifies the ID of a O365 tenant
        
    .Parameter MSTeamsAccount
        MSTeams Credential

    .Parameter MSTeamsTenant
        Specifies the ID of a Teams tenant
#>

param( 
    [Parameter(Mandatory=$true,ParameterSetName = 'AD Users')]
    [string[]]$ADUsers,
    [Parameter(Mandatory=$true,ParameterSetName = 'O365 Users')]
    [string[]]$O365Users,
    [Parameter(Mandatory=$true,ParameterSetName = 'Csv Files')]
    [string]$ADCsvFile,
    [Parameter(Mandatory=$true,ParameterSetName = 'Csv Files')]
    [string]$O365CsvFile,
    [Parameter(Mandatory=$true,ParameterSetName = 'O365 Users')]
    [Parameter(Mandatory=$true,ParameterSetName = 'Csv Files')]
    [PSCredential]$O365Account,
    [Parameter(Mandatory=$true,ParameterSetName = 'O365 Users')]
    [Parameter(Mandatory =$true,ParameterSetName = 'Csv Files')]   
    [string]$AzureDomain, 
    [Parameter(ParameterSetName = 'AD Users')]
    [Parameter(ParameterSetName = 'O365 Users')]
    [switch]$DisableUsers,
    [Parameter(ParameterSetName = 'AD Users')]
    [string]$MoveToOU,    
    [Parameter(ParameterSetName = 'AD Users')]
    [switch]$RemoveMailbox,    
    [Parameter(ParameterSetName = 'AD Users')]
    [switch]$RemoveMailboxPermanent,    
    [Parameter(ParameterSetName = 'AD Users')]
    [switch]$DisableMailbox,   
    [Parameter(ParameterSetName = 'AD Users')]
    [string]$ForwardToMailboxId,
    [Parameter(ParameterSetName = 'O365 Users')]
    [switch]$HideInAddressbook,
    [Parameter(ParameterSetName = 'O365 Users')]
    [switch]$RemoveFromTeams,
    [Parameter(ParameterSetName = 'Csv Files')]
    [string]$Delimiter= ';',
    [Parameter(ParameterSetName = 'Csv Files')]
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',  
    [Parameter(ParameterSetName = 'AD Users')]
    [Parameter(ParameterSetName = 'Csv Files')]
    [string]$DomainName,
    [Parameter(ParameterSetName = 'AD Users')]
    [Parameter(ParameterSetName = 'Csv Files')]
    [PSCredential]$ADAccount,
    [Parameter(ParameterSetName = 'AD Users')]
    [Parameter(ParameterSetName = 'Csv Files')]
    [PSCredential]$ExchangeAccount,
    [Parameter(ParameterSetName = 'AD Users')]
    [Parameter(ParameterSetName = 'Csv Files')]
    [bool]$ExchangeRemoveFromDistributionGroups,    
    [Parameter(ParameterSetName = 'AD Users')]
    [Parameter(ParameterSetName = 'Csv Files')]
    [string]$ExchangeServerFQDN,
    [Parameter(ParameterSetName = 'AD Users')]
    [Parameter(ParameterSetName = 'Csv Files')]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$ADAuthType = "Negotiate",
    [Parameter(ParameterSetName = 'O365 Users')]
    [Parameter(ParameterSetName = 'Csv Files')]
    [string]$O365Tenant,
    [Parameter(ParameterSetName = 'O365 Users')]
    [Parameter(ParameterSetName = 'Csv Files')]
    [PSCredential]$MSTeamsAccount,
    [Parameter(ParameterSetName = 'O365 Users')]
    [Parameter(ParameterSetName = 'Csv Files')]
    [string]$MSTeamsTenant
)

Import-Module ActiveDirectory,AzureAD,MicrosoftTeams

try{
    [string[]]$output = @()
    # Active Directory
    if($PSCmdlet.ParameterSetName -eq 'Csv Files'){
        if(Test-Path -Path $ADCsvFile -ErrorAction SilentlyContinue){
            $users = Import-Csv -Path $ADCsvFile -Delimiter $Delimiter -Encoding $FileEncoding -ErrorAction Stop `
                                -Header @('UserName','Delete','Disable','MoveTo','DisableMailbox','RemoveMailbox','RemovePermanentMailbox','ForwardToMailbox') 
            }
        else{
            Throw "$($ADCsvFile) does not exist"
        }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'AD Users') {
        [string]$del ='1'
        if($DisableUsers){$del = '0'}
        [string]$dis ='0'
        if($DisableUsers){$dis = '1'}
        [string]$delMb ='0'
        if($RemoveMailbox){$delMb = '1'}
        [string]$delMbPer ='0'
        if($RemoveMailboxPermanent){$delMbPer = '1'}
        [string]$disMb ='0'
        if($DisableMailbox){$disMb = '1'}
        $users = $ADUsers | ForEach-Object{[PSCustomObject]@{
            UserName= $_;
            Delete = $del;
            Disable = $dis;
            MoveTo = $MoveToOU;
            RemoveMailbox = $delMb;
            DisableMailbox = $disMb;
            RemovePermanentMailbox = $delMbPer;
            ForwardToMailbox = $ForwardToMailboxId
            }
        }
    }
    # delete users
    if($null -ne $users){
        if($null -eq $ExchangePassword){
            $ExchangePassword = $ADPassword
        }
        foreach($item in $users){        
            if(($item.UserName -eq 'UserName') -or ([System.String]::IsNullOrWhiteSpace($item.UserName) -eq $true)){ # first line
                continue
            }
            # off boarding the user in Exchange
            if(($null -ne $ExchangeAccount) -and ([System.String]::IsNullOrWhiteSpace($ExchangeServerFQDN) -eq $false)){                
                if($ExchangeRemoveFromDistributionGroups){                    
                    RemoveUserFromExchangeDistributionGroups -UserName $item.UserName -ExCredential $ExchangeAccount -ServerName $ExchangeServerFQDN
                    $output += "User $($item.UserName) removed from distribution groups"         
                }
                OffBoardExchangeMailbox -ServerName $ExchangeServerFQDN -ExCredential $ExchangeAccount -UserName $item.UserName `
                                        -Delete $item.RemoveMailbox -DeletePermanent $item.RemovePermanentMailbox -Disable $item.DisableMailbox `
                                        -ForwardTo $item.ForwardToMailbox
                $output += "User $($item.UserName) Mailbox disabled/removed"                
            }
            else{
                $output += "User $($item.UserName) can´t disbale/remove Mailbox. Missing Parameters"
            }
            # delete users in Active Directory
            DeleteUserInAD -User $item.UserName -Delete $item.Delete -Disable $item.Disable `
                            -MoveToOU $Item.MoveTo `
                            -ADCredential $ADAccount -DomainName $DomainName -AuthType $ADAuthType 
            $output += "User $($item.UserName) in Active Directory off boarded"
        }
    }
    $users = $null
    # Azure Active Directory / O365
    if($PSCmdlet.ParameterSetName -eq 'Csv Files'){
        if(Test-Path -Path $O365CsvFile -ErrorAction SilentlyContinue){
            $users = Import-Csv -Path $O365CsvFile -Delimiter $Delimiter -Encoding $FileEncoding -ErrorAction Stop `
                            -Header @('UserName','Delete','Disable','HideInAddressLists','RemoveFromTeams') 
        }
    }
    elseif($PSCmdlet.ParameterSetName -eq 'O365 Users'){
        [string]$del ='1'
        if($DisableUsers){$del = '0'}
        [string]$dis ='0'
        if($DisableUsers){$dis = '1'}
        [string]$hide ='0'
        if($HideInAddressbook){$hide = '1'}
        [string]$remo ='0'
        if($RemoveFromTeams){$remo='1'}
        $users = $O365Users | ForEach-Object{[PSCustomObject]@{
            UserName= $_;
            Delete = $del;
            Disable = $dis;
            HideInAddressLists = $hide
            RemoveFromTeams = $remo}}
    }
    if($null -ne $users){
        # Delete users in Azure AD          
        [string]$o365Domain = '@' + $AzureDomain
        foreach($item in $users){  
            if(($item.UserName -eq 'UserName') -or ([System.String]::IsNullOrWhiteSpace($item.UserName) -eq $true)){ # first line
                continue
            }
            $tmp = $item.UserName + $o365Domain
            # user removes from all MS Teams
            if($item.RemoveFromTeams -eq '1'){
                if($null -eq $MSTeamsAccount){
                    $MSTeamsAccount = $O365Account
                }
                if([System.String]::IsNullOrWhiteSpace($MSTeamsTenant) -eq $true){
                    $MSTeamsTenant = $Tenant
                } 
                RemoveO365UserFromTeams -UserName $tmp -TeamsCredential $MSTeamsAccount -TeamsTenant $MSTeamsTenant 
                $output += "User $($item.UserName) in removed from all MS Teams"
            }
            # delete users in Active Directory
            DeleteUserInO365 -O365Credential $O365Account -Tenant $O365Tenant -UserName $tmp `
                            -Delete $item.Delete -Disable $item.Disable -HideInAddressLists $item.HideInAddressLists 
            $output += "User $($item.UserName) in O365 off boarded"
        }
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output
    } 
    else {
        Write-Output $output
    }
}
catch{
    Write-Output $_.exception.message
    throw 
}
finally{
    
}