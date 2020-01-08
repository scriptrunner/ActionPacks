#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and modifies the user.
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
        Azure Active Directory Powershell Module v2
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Users
    
    .Parameter UserObjectId
        Specifies the unique ID of the user from which to set properties

    .Parameter UserName
        Specifies the Display name or user principal name of the user from which to set properties

    .Parameter DisplayName
        Specifies the display name of the user

    .Parameter FirstName
        Specifies the first name of the user

    .Parameter LastName
        Specifies the last name of the user

    .Parameter PostalCode
        Specifies the postal code of the user

    .Parameter City
        Specifies the city of the user

    .Parameter Street
        Specifies the street address of the user

    .Parameter PhoneNumber
        Specifies the phone number of the user

    .Parameter MobilePhone
        Specifies the mobile phone number of the user

    .Parameter Department
        Specifies the department of the user

    .Parameter Enabled
        Specifies whether the user is able to log on using their user ID
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "User name")]
    [string]$UserName,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$DisplayName,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$FirstName,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$LastName,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$PostalCode,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$City,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$Street,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$PhoneNumber,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$MobilePhone,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$Department,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [bool]$Enabled
)

try{
    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:User = Get-AzureADUser -ObjectId $UserObjectId | Select-Object ObjectID,DisplayName
    }
    else{
        $Script:User = Get-AzureADUser -All $true | `
            Where-Object {($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
                Select-Object ObjectID,DisplayName
    }
    if($null -ne $Script:User){
        if($PSBoundParameters.ContainsKey('DisplayName') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -DisplayName $DisplayName
        }
        if($PSBoundParameters.ContainsKey('FirstName') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -GivenName $FirstName
        }
        if($PSBoundParameters.ContainsKey('LastName') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -Surname $LastName
        }
        if($PSBoundParameters.ContainsKey('PostalCode') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -PostalCode $PostalCode
        }
        if($PSBoundParameters.ContainsKey('City') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -City $City
        }
        if($PSBoundParameters.ContainsKey('Street') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -StreetAddress $Street
        }
        if($PSBoundParameters.ContainsKey('PhoneNumber') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -TelephoneNumber $PhoneNumber
        }
        if($PSBoundParameters.ContainsKey('MobilePhone') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -Mobile $MobilePhone
        }
        if($PSBoundParameters.ContainsKey('Department') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -Department $Department
        }
        if($PSBoundParameters.ContainsKey('Enabled') -eq $true ){
            $null = Set-AzureADUser -ObjectId $Script:User.ObjectId -AccountEnabled $Enabled
        }
        $Script:User = Get-AzureADUser -ObjectId $Script:User.ObjectId | Select-Object *
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:User
        } 
        else{
            Write-Output $Script:User 
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User not found"
        }    
        Throw "User not found"
    }
}
finally{
}    