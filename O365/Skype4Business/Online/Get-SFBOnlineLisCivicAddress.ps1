#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Retrieve information about existing emergency civic addresses defined in the Location Information Service (LIS.) 
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module SkypeOnlineConnector
        Requires Library script SFBLibrary.ps1
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/Online

    .Parameter SFBCredential
        Credential object containing the Skype for Business user/password

    .Parameter AssignmentStatus
        Specifies whether the retrieved addresses have been assigned to users or not

    .Parameter City
        Specifies the city of the target civic address

    .Parameter CivicAddressId
        Specifies the identification number of the civic address to return

    .Parameter CountryOrRegion
        Specifies the country or region of the target civic address

    .Parameter Description
        Specifies the administrator defined description of the target civic address
    
    .Parameter NumberOfResultsToSkip
        Specifies the number of results to skip

    .Parameter ResultSize
        Specifies the maximum number of results to return

    .Parameter ValidationStatus
        Specifies the validation status of the addresses to be returned
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [ValidateSet('Assigned', 'Unassigned')]
    [string]$AssignmentStatus,
    [string]$City,
    [string]$CivicAddressId,
    [string]$CountryOrRegion,
    [string]$Description,
    [int]$NumberOfResultsToSkip,
    [int]$ResultSize,
    [ValidateSet('Valid', 'Invalid','Notvalidated')]
    [string]$ValidationStatus
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Force' = $true
                            }      
    if([System.String]::IsNullOrWhiteSpace($AssignmentStatus) -eq $false){
        $cmdArgs.Add('AssignmentStatus',$AssignmentStatus)
    } 
    if([System.String]::IsNullOrWhiteSpace($City) -eq $false){
        $cmdArgs.Add('City',$City)
    }     
    if([System.String]::IsNullOrWhiteSpace($CivicAddressId) -eq $false){
        $cmdArgs.Add('CivicAddressId',$CivicAddressId)
    }     
    if([System.String]::IsNullOrWhiteSpace($CountryOrRegion) -eq $false){
        $cmdArgs.Add('CountryOrRegion',$CountryOrRegion)
    }     
    if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
        $cmdArgs.Add('Description',$Description)
    }    
    if([System.String]::IsNullOrWhiteSpace($ValidationStatus) -eq $false){
        $cmdArgs.Add('ValidationStatus',$ValidationStatus)
    } 
    if($NumberOfResultsToSkip -gt 0){
        $cmdArgs.Add('NumberOfResultsToSkip',$NumberOfResultsToSkip)
    }    
    if($ResultSize -gt 0){
        $cmdArgs.Add('ResultSize',$ResultSize)
    }    

    $result = Get-CsOnlineLisCivicAddress @cmdArgs | Select-Object *

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
    DisconnectS4B
}