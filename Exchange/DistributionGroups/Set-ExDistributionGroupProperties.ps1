#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and sets the Universal distribution group properties
        Only parameters with value are set

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
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/DistributionGroups

    .Parameter GroupName
        Specifies the Name, Alias, Display name, Distinguished name, Guid or Mail address of the Universal distribution group that you want to modify

    .Parameter Alias
        Specifies the Exchange alias (also known as the mail nickname) for the recipient
    
    .Parameter DisplayName
        Specifies the display name of the group

    .Parameter ManagedBy
        Specifies specifies an owner for the group. You can use the Alias, Display name, Distinguished name, Guid or Mail address that uniquely identifies the group owner
    
    .Parameter PrimarySmtpAddress
        Specifies the primary return email address that's used for the recipient
    
    .Parameter MemberDepartRestriction
        Specifies the restrictions that you put on requests to leave the group

    .Parameter MemberJoinRestriction 
        Specifies the restrictions that you put on requests to join the group
#>

param(
    [Parameter(Mandatory = $true)]    
    [string]$GroupName,
    [string]$Alias,
    [string]$DisplayName,
    [string]$ManagedBy,
    [string]$PrimarySmtpAddress ,
    [string]$MemberDepartRestriction='Open',
    [ValidateSet('ApprovalRequired','Open','Closed')]
    [string]$MemberJoinRestriction='Closed'
)

try{
    $Script:grp = Get-DistributionGroup -Identity $GroupName
    
    if($null -ne $Script:grp){    
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'Identity' = $Script:grp.Name
                        'ForceUpgrade' = $null
                        'Confirm' = $false
                        }
        if($PSBoundParameters.ContainsKey('Alias') -eq $true ){
            Set-DistributionGroup @cmdArgs -Alias $Alias
        }
        if($PSBoundParameters.ContainsKey('DisplayName') -eq $true ){
            Set-DistributionGroup  @cmdArgs -DisplayName $DisplayName
        }
        if($PSBoundParameters.ContainsKey('ManagedBy') -eq $true ){
            Set-DistributionGroup  @cmdArgs -ManagedBy $ManagedBy
        }
        if($PSBoundParameters.ContainsKey('PrimarySmtpAddress') -eq $true ){
            Set-DistributionGroup  @cmdArgs -PrimarySmtpAddress $PrimarySmtpAddress
        }
        if($PSBoundParameters.ContainsKey('MemberDepartRestriction') -eq $true ){
            Set-DistributionGroup  @cmdArgs -MemberDepartRestriction $MemberDepartRestriction
        }            
        if($PSBoundParameters.ContainsKey('MemberJoinRestriction') -eq $true ){
            Set-DistributionGroup  @cmdArgs -MemberJoinRestriction $MemberJoinRestriction
        }
        $res=@("Universal distribution group $($GroupName) modified")
        $res += Get-DistributionGroup -Identity $Script:grp.Name | Select-Object *
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $res  
        }
        else{
            Write-Output $res
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Universal distribution group $($GroupName) not found"
        } 
        else{
            Write-Output  "Universal distribution group $($GroupName) not found"
        }
    }
}
catch{
    throw
}
Finally{
    
}