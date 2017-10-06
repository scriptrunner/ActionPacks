<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and gets the address list properties
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

    .Parameter ListName
        Specifies the Name, Display name, Distinguished name or Guid of the address list from which to get properties 

    .Parameter Properties
        List of properties to expand. Use * for all properties
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ListName,
    [string[]]$Properties =@('Name','DisplayName','IncludedRecipients','Path','IsValid','DistinguishedName','Guid')
)

#Clear
    try{
        if([System.String]::IsNullOrWhiteSpace($Properties)){
            $Properties='*'
        }
        $res = Get-AddressList -Identity $ListName  | Select-Object $Properties
        
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
    Finally{
       
    }