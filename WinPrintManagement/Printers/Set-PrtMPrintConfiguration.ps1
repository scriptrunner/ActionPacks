#Requires -Version 5.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Sets the configuration information for the specified printer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Printers

.Parameter PrinterName
    [sr-en] Name of the printer from which to retrieve the configuration information

.Parameter ComputerName
    [sr-en] Name of the computer from which to retrieve the printer configuration information
    
.Parameter AccessAccount
    [sr-en] User account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Collate
    [sr-en] Collate the output of the printer by default

.Parameter Color
    [sr-en] Printer should use either color or grayscale printing by default

.Parameter DuplexingMode
    [sr-en] Duplexing mode the printer uses by default

.Parameter PaperSize
    [sr-en] Paper size the printer uses by default
#>
   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [bool]$Collate,
    [bool]$Color,
    [ValidateSet('OneSided','TwoSidedLongEdge','TwoSidedShortEdge')]
    [string]$DuplexingMode,
    [ValidateSet('','Custom', 'Letter', 'LetterSmall', 'Tabloid', 'Ledger','Legal', 'Statement', 'Executive', 'A3', 'A4', 'A4Small', 'A5', 'B4',
                'B5', 'Folio', 'Quarto', 'Sheet10x14', 'Sheet11x17', 'Note', 'Envelope9', 'Envelope10', 'Envelope11', 'Envelope12','Envelope14', 'CSheet', 'DSheet', 'ESheet',
                'EnvelopeDL', 'EnvelopeC5', 'EnvelopeC3', 'EnvelopeC4EnvelopeC6', 'EnvelopeC65', 'EnvelopeB4', 'EnvelopeB5', 'EnvelopeB6', 'EnvelopeItaly', 'EnvelopeMonarch','EnvelopePersonal', 
                'FanfoldUS', 'FanfoldStandardGerman', 'FanfoldLegalGerman', 'ISOB4','JapanesePostcard', 'Sheet9x11', 'Sheet10x11', 'Sheet15x11', 'EnvelopeInvite', 'Reserved48', 'Reserved49',
                'LetterExtra', 'LegalExtra', 'TabloidExtra', 'A4Extra', 'LetterTransverse', 'A4Transverse', 'LetterExtraTransverse','APlus', 'BPlus', 'LetterPlus', 'A4Plus', 'A5Transverse', 'B5Transverse', 'A3Extra', 'A5Extra', 'B5Extra', 'A2', 
                'A3Transverse', 'A3ExtraTransverse', 'JapaneseDoublePostcard', 'A6', 'JapaneseEnvelopeKaku2', 'JapaneseEnvelopeKaku3', 'JapaneseEnvelopeChou3', 'JapaneseEnvelopeChou4', 'LetterRotated',
                'A3Rotated', 'A4Rotated', 'A5Rotated', 'B4JISRotated', 'B5JISRotated', 'JapanesePostcardRotated', 'JapaneseDoublePostcardRotated', 'A6Rotated', 'JapaneseEnvelopeKaku2Rotated', 'JapaneseEnvelopeKaku3Rotated', 'JapaneseEnvelopeChou3Rotated', 
                'JapaneseEnvelopeChou4Rotated', 'B6JIS', 'B6JISRotated', 'Sheet12x11', 'JapaneseEnvelopeYou4', 'JapaneseEnvelopeYou4Rotated', 'PRC16K', 'PRC32K', 'PRC32KBig', 'PRCEnvelope1', 'PRCEnvelope2', 
                'PRCEnvelope3','PRCEnvelope4', 'PRCEnvelope5', 'PRCEnvelope6', 'PRCEnvelope7','PRCEnvelope8','PRCEnvelope9', 'PRCEnvelope10', 'PRC16KRotated', 'PRC32KRotated', 'PRC32KBigRotated', 'PRCEnvelope1Rotated', 
                'PRCEnvelope2Rotated', 'PRCEnvelope3Rotated', 'PRCEnvelope4Rotated','PRCEnvelope5Rotated', 'PRCEnvelope6Rotated', 'PRCEnvelope7Rotated', 'PRCEnvelope8Rotated', 'PRCEnvelope9Rotated', 'PRCEnvelope10Rotated')]
    [string]$PaperSize
)

Import-Module PrintManagement

$Script:Cim = $null
try{
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'PrinterName' = $PrinterName 
                            'ComputerName' = $ComputerName 
                            'CimSession' = $Script:Cim}
    if($PSBoundParameters.ContainsKey('Collate') -eq $true){
        $null = Set-PrintConfiguration @cmdArgs -Collate $Collate
    }
    if($PSBoundParameters.ContainsKey('Color') -eq $true){
        $null = Set-PrintConfiguration @cmdArgs -Color $Color
    }
    if($PSBoundParameters.ContainsKey('DuplexingMode') -eq $true){
        $null = Set-PrintConfiguration @cmdArgs -DuplexingMode $DuplexingMode
    }
    if($PSBoundParameters.ContainsKey('PaperSize') -eq $true){
        $null = Set-PrintConfiguration @cmdArgs -PaperSize $PaperSize
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Printer $($PrinterName) changed"
    }
    else{
        Write-Output "Printer $($PrinterName) changed"
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}