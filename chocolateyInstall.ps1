try { 
    $powerdeliveryDir = Split-Path -parent $MyInvocation.MyCommand.Definition
  
    Write-Host "Updating PSModulePath to include $powerdeliveryDir..."

    $psModulePath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PSModulePath).PSModulePath
  
    $newEnvVar = $powerdeliveryDir

    $caseInsensitive = [StringComparison]::InvariantCultureIgnoreCase

    $pathSegment = "chocolatey\lib\powerdelivery"

    if (![String]::IsNullOrWhiteSpace($psModulePath)) {
        if ($psModulePath.IndexOf($pathSegment, $caseInsensitive) -lt 0) { # First time installing
			if ($psModulePath.EndsWith(";")) {
				$psModulePath = $psModulePath.TrimEnd(";")
			}
            $newEnvVar = "$($psModulePath);$($powerdeliveryDir)"
        }
        else { # Replacing an existing install
            $indexOfSegment = $psModulePath.IndexOf($pathSegment, $caseInsensitive)
            $startingSemicolon = $psModulePath.LastIndexOf(";", $indexOfSegment, $caseInsensitive)
            $trailingSemicolon = $psModulePath.IndexOf(";", $indexOfSegment + $pathSegment.Length, $caseInsensitive)

            if ($startingSemicolon -ne -1) {
                $psModulePrefix = $psModulePath.Substring(0, $startingSemicolon)
				$newEnvVar = "$($psModulePrefix);$($powerdeliveryDir)"
			}			
			if ($trailingSemicolon -ne -1) {
                $newEnvVar += $psModulePath.Substring($trailingSemicolon)
            }
        }
    }
	
	Start-ChocolateyProcessAsAdmin @"
		Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'PSModulePath' -Value '$newEnvVar'
"@

	Update-SessionEnvironment

	$env:PSModulePath = $newEnvVar

    Write-ChocolateySuccess 'powerdelivery'
} 
catch {
    Write-ChocolateyFailure 'powerdelivery' "$($_.Exception.Message)"
    throw 
}