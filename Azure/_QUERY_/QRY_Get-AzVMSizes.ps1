#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Gets available virtual machine sizes
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az.Compute
        Requires Library script AzureAzLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/_QUERY_ 

    .Parameter VMName
        [sr-en] Specifies the name of the virtual machine that this cmdlet gets the available virtual machine sizes for resizing
        [sr-de] Name der virtuellen Maschine

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group of the virtual machine
        [sr-de] Name der resource group der virtuellen Maschine
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$VMName
)

Import-Module Az.Compute

try{
    $result = Get-AzVMSize -ResourceGroupName $ResourceGroupName -VMName $VMName -ErrorAction Stop | Sort-Object Name

    foreach($item in $result){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($item.Name)
            $null = $SRXEnv.ResultList2.Add($item.Name) # Display
        }
        else{
            Write-Output $item.Name
        }
    }
}
catch{
    throw
}
finally{    
}