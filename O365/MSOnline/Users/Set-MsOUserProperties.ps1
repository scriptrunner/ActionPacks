#Requires -Version 5.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and modifies a user in Azure Active Directory.
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
        Azure Active Directory Powershell Module

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/Users

    .Parameter UserObjectId
        [sr-en] Unique ID of the user from which to set properties

    .Parameter UserName
        [sr-en] Display name, Sign-In Name or user principal name of the user from which to set properties

    .Parameter DisplayName
        [sr-en] Display name of the user

    .Parameter FirstName
        [sr-en] First name of the user

    .Parameter LastName
        [sr-en] Last name of the user

    .Parameter PostalCode
        [sr-en] Postal code of the user

    .Parameter City
        [sr-en] City of the user

    .Parameter Street
        [sr-en] Street address of the user

    .Parameter PhoneNumber
        [sr-en] Phone number of the user

    .Parameter MobilePhone
        [sr-en] Mobile phone number of the user

    .Parameter Office
        [sr-en] Office of the user

    .Parameter Department
        [sr-en] Department of the user

    .Parameter PasswordNeverExpires
        [sr-en] User password expires periodically

    .Parameter Enabled
        [sr-en] User is able to log on using their user ID

    .Parameter TenantId
        [sr-en] Unique ID of the tenant on which to perform the operation
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
    [string]$Office,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [string]$Department,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [switch]$ForceChangePassword,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [switch]$PasswordNeverExpires,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [switch]$Enabled,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [guid]$TenantId
)

try{
    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:User = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId  | Select-Object ObjectID
    }
    else{
        $Script:User = Get-MsolUser -TenantId $TenantId | `
                            Where-Object {($_.DisplayName -eq $UserName) -or ($_.SignInName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
                            Select-Object ObjectID,DisplayName
    }
    if($null -ne $Script:User){
        if(-not [System.String]::IsNullOrWhiteSpace($DisplayName)){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -DisplayName $DisplayName
        }
        if(-not [System.String]::IsNullOrWhiteSpace($FirstName)){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -FirstName $FirstName
        }
        if(-not [System.String]::IsNullOrWhiteSpace($LastName)){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -LastName $LastName
        }
        if(-not [System.String]::IsNullOrWhiteSpace($PostalCode)){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -PostalCode $PostalCode
        }
        if(-not [System.String]::IsNullOrWhiteSpace($City)){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -City $City
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Street)){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -StreetAddress $Street
        }
        if(-not [System.String]::IsNullOrWhiteSpace($PhoneNumber)){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -PhoneNumber $PhoneNumber
        }
        if(-not [System.String]::IsNullOrWhiteSpace($MobilePhone)){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -MobilePhone $MobilePhone
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Office)){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -Office $Office
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Department)){
            $null =  Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -Department $Department
        }
        if($PSBoundParameters.ContainsKey('PasswordNeverExpires') -eq $true ){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -PasswordNeverExpires $PasswordNeverExpires.ToBool()
        }
        if($PSBoundParameters.ContainsKey('Enabled') -eq $true ){
            $null = Set-MsolUser -TenantId $TenantId -ObjectId $Script:User.ObjectId -BlockCredential (-not $Enabled)
        }

        $Script:User = Get-MsolUser -ObjectId $Script:User.ObjectId -TenantId $TenantId  | Select-Object *
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
catch{
    throw
}