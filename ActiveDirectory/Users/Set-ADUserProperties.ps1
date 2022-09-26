#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Sets the properties of the Active Directory user.
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
        Requires Module ActiveDirectory

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Users

    .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter Username
        Display name, SAMAccountName, DistinguishedName or user principal name of Active Directory account
        [sr-de] Anzeigename, SAMAccountName, Distinguished-Name oder UPN des Benutzerkontos

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP

    .Parameter GivenName
        Specifies the user's given name
        [sr-de] Gibt den Vornamen des Benutzers an

    .Parameter Surname
        Specifies the user's last name or surname
        [sr-de] Gibt den Nachnamen des Benutzers an

    .Parameter DisplayName
        Specifies the display name of the user        
        [sr-de] Gibt den Anzeigenamen des Benutzers an

    .Parameter Description
        Specifies a description of the user
        [sr-de] Gibt die Beschreibung des Benutzers an

    .Parameter CannotChangePassword
        Specifies whether the account password can be changed
        [sr-de] Gibt an, ob der Benutzer das Passwort ändern kann

    .Parameter PasswordNeverExpires
        Specifies whether the password of an account can expire
        [sr-de] Gibt an, ob das Passwort nie abläuft

    .Parameter ChangePasswordAtLogon
        Specifies whether a password must be changed during the next logon attempt
        [sr-de] Gibt an, ob der Benutzer das Passwort bei der ersten Anmeldung ändern muss

    .Parameter NewSAMAccountName
        The new SAMAccountName of Active Directory account
        [sr-de] Neuer SAMAccountName des Benutzers

    .Parameter Office
        Specifies the location of the user's office or place of business
        [sr-de] Gibt das Büro des Benutzers an
    
    .Parameter EmailAddress
        Specifies the user's e-mail address
        [sr-de] Gibt die Mailadresse des Benutzers an

    .Parameter Phone
        Specifies the user's office telephone number
        [sr-de] Gibt die Telefonnummer des Benutzers an

    .Parameter Title
        Specifies the user's title
        [sr-de] Gibt die Position des Benutzers an

    .Parameter Department
        Specifies the user's department
        [sr-de] Gibt die Abteilung des Benutzers an

    .Parameter Company
        Specifies the user's company
        [sr-de] Gibt die Firma des Benutzers an

    .Parameter Street
        Specifies the user's street address
        [sr-de] Gibt die Strasse des Benutzers an

    .Parameter PostalCode
        Specifies the user's postal code or zip code
        [sr-de] Gibt die Postleitzahl des Benutzers an

    .Parameter City
        Specifies the user's town or city
        [sr-de] Gibt den Ort des Benutzers an

    .Parameter DomainName
        Name of Active Directory Domain
        [sr-de] Name der Active Directory Domäne

    .Parameter SearchScope
        Specifies the scope of an Active Directory search
        [sr-de] Gibt den Suchumfang einer Active Directory-Suche an

    .Parameter AuthType
        Specifies the authentication method to use
        [sr-de] Gibt die zu verwendende Authentifizierungsmethode an
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,   
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Username,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$GivenName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Surname,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DisplayName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Description,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$ChangePasswordAtLogon,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$CannotChangePassword,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$PasswordNeverExpires,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Office,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$EmailAddress,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Phone,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Title,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Department,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Company,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Street,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$PostalCode,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$City,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$NewSAMAccountName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

try{
    $Script:User 
    $Script:Domain
    $Script:Properties = @('GivenName','Surname','SAMAccountName','UserPrincipalname','Name','DisplayName','Description','EmailAddress', 'CannotChangePassword','PasswordNeverExpires' `
                            ,'Department','Company','PostalCode','City','StreetAddress','DistinguishedName')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AuthType' = $AuthType
                            }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $cmdArgs.Add("Current", 'LocalComputer')
    }
    else {
        $cmdArgs.Add("Identity", $DomainName)
    }
    $Domain = Get-ADDomain @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Filter' = {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)}
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                'Properties' = '*'
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    $Script:User= Get-ADUser @cmdArgs

    if($null -ne $Script:User){
        $cmdArgs = @{'ErrorAction' = 'Stop'
                    'Server' = $Domain.PDCEmulator
                    'AuthType' = $AuthType
                    'PassThru' = $null
                    'Confirm' = $false           
                    }
        if($null -ne $DomainAccount){
            $cmdArgs.Add("Credential", $DomainAccount)
        }

        if(-not [System.String]::IsNullOrWhiteSpace($GivenName)){
            $Script:User.GivenName = $GivenName
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Surname)){
            $Script:User.Surname = $Surname
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Description)){
            $Script:User.Description = $Description
        }
        if(-not [System.String]::IsNullOrWhiteSpace($DisplayName)){
            $Script:User.DisplayName = $DisplayName
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Office)){
            $Script:User.Office = $Office
        }
        if(-not [System.String]::IsNullOrWhiteSpace($EmailAddress)){
            $Script:User.EmailAddress = $EmailAddress
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Phone)){
            $Script:User.OfficePhone = $Phone
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Title)){
            $Script:User.Title = $Title
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Department)){
            $Script:User.Department = $Department
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Company)){
            $Script:User.Company = $Company
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Street)){
            $Script:User.StreetAddress = $Street
        }
        if(-not [System.String]::IsNullOrWhiteSpace($PostalCode)){
            $Script:User.PostalCode = $PostalCode
        }
        if(-not [System.String]::IsNullOrWhiteSpace($City)){
            $Script:User.City = $City
        }
        if($PSBoundParameters.ContainsKey('CannotChangePassword') -eq $true ){
            $Script:User.CannotChangePassword = $CannotChangePassword.ToBool()
        }
        if($PSBoundParameters.ContainsKey('PasswordNeverExpires') -eq $true){
            $Script:User.PasswordNeverExpires = $PasswordNeverExpires.ToBool()
        }
        $cmdArgs.Add('Instance', $Script:User)
        $Script:User = Set-ADUser @cmdArgs
        
        if($PSBoundParameters.ContainsKey('ChangePasswordAtLogon') -eq $true ){ # is not a property from the user object
            $Script:User = Set-ADUser @cmdArgs -ChangePasswordAtLogon:$ChangePasswordAtLogon.ToBool()
        }
        if(-not [System.String]::IsNullOrWhiteSpace($NewSAMAccountName)){ # user must changed with replace parameter
            $Script:User = Set-ADUser @cmdArgs -Replace @{'SAMAccountName'=$NewSAMAccountName}            
        }
        Start-Sleep -Seconds 5 # wait
        $cmdArgs.Remove('Confirm')
        $cmdArgs.Remove('PassThru')
        $cmdArgs.Remove('Instance')
        $cmdArgs.Add('Identity' , $Script:User.SAMAccountName)
        $Script:User = Get-ADUser @cmdArgs -Properties $Script:Properties
        
        $res=New-Object 'System.Collections.Generic.Dictionary[string,string]'
        $tmp=($Script:User.DistinguishedName  -split ",",2)[1]
        $res.Add('Path:', $tmp)
        foreach($item in $Script:Properties){
            if(-not [System.String]::IsNullOrWhiteSpace($Script:User[$item])){
                $res.Add($item + ':', $Script:User[$item])
            }
        }
        $Out =@()
        $Out +="User $($Username) changed"
        $Out +=$res | Format-Table -HideTableHeaders
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $out
        }
        else {
            Write-Output $out 
        }    
        if($SRXEnv) {
            $SRXEnv.ResultMessage ="User $($Username) changed"
        }
        else {
            Write-Output "User $($Username) changed"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User $($Username) not found"
        }    
        Throw "User $($Username) not found"
    }   
}
catch{
    throw
}
finally{
}