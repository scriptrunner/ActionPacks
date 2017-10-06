<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and removes the address list
        Requirements 
        ScriptRunner Version 4.x or higher
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG
        © AppSphere AG

    .Parameter ListName
        Specifies the Name, Display name, Distinguished name or Guid of the address list to remove
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ListName
)

#Clear
    try{
        Remove-AddressList -Identity $ListName -Recursive -Confirm:$false
        
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Address list $($ListName) removed"
        } 
        else{
            Write-Output   "Address list $($ListName) removed"
        }
        
    }
    Finally{
        
    }