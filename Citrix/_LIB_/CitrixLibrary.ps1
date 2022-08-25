#Requires -Version 5.0

$VerbosePreference = 'SilentlyContinue'

function StartCitrixSession(){
    <#
        .SYNOPSIS
            Add the PSSnapIns

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires PSSnapIn Citrix*

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Citrix/_LIB_
        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            $tmp = Get-Command -Name 'Get-LicCertificate' -ErrorAction Ignore
            if($null -eq $tmp){
                $null = Add-PSSnapin -Name Citrix*
            }
        }
        catch{
            throw
        }
        finally{
        }
}
function CloseCitrixSession(){
    <#
        .SYNOPSIS
            Removes the PSSnapIn

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires PSSnapIn Citrix*

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Citrix/_LIB_
        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            $tmp = Get-Command -Name 'Get-LicCertificate' -ErrorAction Ignore
            if($null -ne $tmp){
                $null = Remove-PSSnapin -Name Citrix* -ErrorAction Ignore
            }                    
        }
        catch{
            throw
        }
        finally{
        }
}
function CheckCitrixServer(){

    [CmdLetBinding()]
    Param(
        [ref]$ServerName
    )

    try{
        if([System.String]::IsNullOrWhiteSpace($ServerName.Value) -eq $true){
            $ServerName.Value = "localhost"
        }                   
    }
    catch{
        throw
    }
    finally{
    }
}
function StartCitrixSessionAdv(){
    <#
        .SYNOPSIS
            Add the PSSnapIns and checks Server name

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires PSSnapIn Citrix*

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Citrix/_LIB_
        #>

        [CmdLetBinding()]
        Param(
            [ref]$ServerName
        )

        try{
            StartCitrixSession
            [string]$srvName
            if(($null -eq $ServerName) -or ($null -eq $ServerName.Value) -or ($ServerName.Value.Length -le 0)){
                $srvname = ''
            }
            else{
                $srvName = $ServerName.Value
            }
            CheckCitrixServer -ServerName ([ref]$srvName)
            $ServerName.Value = $srvName
        }
        catch{
            throw
        }
        finally{
        }
}
function GetLicenseLocation(){
    [CmdLetBinding()]
    Param(
        [string]$ServerName,
        [int]$ServerPort = 27000,
        [string]$AddressType,
        [ref]$Address
    )

    try{
        CheckCitrixServer ([ref]$ServerName)
        $Address.Value = Get-LicLocation -AddressType $AddressType -LicenseServerAddress $ServerName -LicenseServerPort $ServerPort -ErrorAction Stop
    }
    catch{
        throw
    }
    finally{
    }
}
function GetLicenseCertificate(){

    [CmdLetBinding()]
    Param(        
        [ref]$ServerName,
        [int]$ServerPort = 27000,
        [string]$AddressType = 'WSL',
        [ref]$Certificate
    )

    try{        
        $ServerAddress = $null
        GetLicenseLocation -Address ([ref]$ServerAddress) -ServerName $ServerName.Value -ServerPort $ServerPort -AddressType $AddressType
        $ServerName.Value = $ServerAddress
        $Certificate.Value = Get-LicCertificate -AdminAddress $ServerAddress -ErrorAction Stop
    }
    catch{
        throw
    }
    finally{
    }
}
function StartLogging(){
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerAddress,
        [Parameter(Mandatory = $true)]
        [string]$LogText,
        [Parameter(Mandatory = $true)]
        [ref]$LoggingID,
        [string]$LoggedBy = 'ScriptRunner'
    )

    try{
        $logObject = Start-LogHighLevelOperation -AdminAddress $ServerAddress -Text $LogText -Source $LoggedBy
        $LoggingID.Value = $logObject.Id
    }
    catch{
        throw
    }
}
function StopLogging(){
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerAddress,
        [string]$LoggingID,
        [bool]$IsSuccessful = $true
    )

    try{
        if($null -eq $LoggingID){
            return
        }
        [guid]$LogId =[System.Guid]::NewGuid()
        if([System.Guid]::TryParse($LoggingID,[ref]$LogId) -eq $false){
            return
        }
        if($LogId -ne [System.Guid]::NewGuid()){
            $null = Stop-LogHighLevelOperation -HighLevelOperationId $LogId -IsSuccessful $IsSuccessful  -AdminAddress $ServerAddress
        }
    }
    catch{
        throw
    }
}

[scriptblock]$Script:ImportFunctions = {
    Invoke-Expression $Using:function:StartCitrixSession.Ast.Extent.Text
    Invoke-Expression $Using:function:CloseCitrixSession.Ast.Extent.Text
    Invoke-Expression $Using:function:CheckCitrixServer.Ast.Extent.Text
    Invoke-Expression $Using:function:StartCitrixSessionAdv.Ast.Extent.Text
    Invoke-Expression $Using:function:GetLicenseLocation.Ast.Extent.Text
    Invoke-Expression $Using:function:GetLicenseCertificate.Ast.Extent.Text
    Invoke-Expression $Using:function:StartLogging.Ast.Extent.Text
    Invoke-Expression $Using:function:StopLogging.Ast.Extent.Text
}