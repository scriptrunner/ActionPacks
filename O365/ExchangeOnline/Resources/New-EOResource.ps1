#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Exchange Online and creates the resource
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/Resources

    .Parameter Name
        Specifies the unique name of the resource. The maximum length is 64 characters.
    
    .Parameter AccountDisabled
        Specifies whether to disable the account that's associated with the resource

    .Parameter Alias
        Specifies the alias name of the resource

    .Parameter DisplayName
        Specifies the display name of the resource

    .Parameter ResourceCapacity
        Specifies the capacity of the resource

    .Parameter WindowsEmailAddress
        Specifies the windows mail address of the resource
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [switch]$AccountDisabled,    
    [string]$Alias,
    [string]$DisplayName,
    [int]$ResourceCapacity,
    [string]$WindowsEmailAddress
)

try{
    [string[]]$Properties = @('AccountDisabled','Alias','DisplayName','ResourceCapacity','WindowsEmailAddress')

    $box = New-Mailbox -Name  $Name -Room -Force
    if($null -ne $box){
        if(-not [System.String]::IsNullOrWhiteSpace($Alias)){
            $null = Set-Mailbox -Identity $Name -Alias $Alias
        }
        if(-not [System.String]::IsNullOrWhiteSpace($DisplayName)){
            $null = Set-Mailbox -Identity $Name -DisplayName $DisplayName
        }
        if($PSBoundParameters.ContainsKey('ResourceCapacity') -eq $true ){
            $null = Set-Mailbox -Identity $Name -ResourceCapacity $ResourceCapacity
        }
        if(-not [System.String]::IsNullOrWhiteSpace($WindowsEmailAddress)){
            $null = Set-Mailbox -Identity $Name -WindowsEmailAddress $WindowsEmailAddress
        }
        if($PSBoundParameters.ContainsKey('AccountDisabled') -eq $true ){
            $null = Set-Mailbox -Identity $Name -AccountDisabled $AccountDisabled.ToBool() -Confirm:$false
        }
        
        $resultMessage = Get-Mailbox -Identity $box.UserPrincipalName | Select-Object $Properties            
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $resultMessage  
        }
        else{
            Write-Output $resultMessage
        }
    }
}
catch{
    throw
}
finally{
   
}