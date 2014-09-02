$ErrorActionPreference = "Stop"

$scriptPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$sharedScript = Join-Path $scriptPath "uninstallExtension.ps1"

. $sharedScript

# Uninstalls the Visual Studio 2012 Extension for PowerDelivery
#
Uninstall-Extension -scriptPath $scriptPath -ExtensionVersion 2012 -VSVersion 11 -vsixId "8d0861c8-1688-40be-bdcd-cffa25e18d40"