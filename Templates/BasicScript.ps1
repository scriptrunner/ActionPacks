<#
	.SYNOPSIS
	Basic ScriptRunner script template

	.DESCRIPTION

	.COMPONENT
	
    .LINK
    
#>

[CmdLetBinding()]
Param(
    [string]$Param1
)

if ($SRXEnv) {
    $SRXEnv.ResultMessage = $Param1
}