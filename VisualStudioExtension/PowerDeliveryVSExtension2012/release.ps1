$ErrorActionPreference = "Stop"
$originalDirectory = Get-Location

function UpdateVsix {

	"Updating VSIX manifest to $newVersion..."
	
	$vsixManifestPath = Join-Path $currentDirectory .\source.extension.vsixManifest
	
	[xml]$vsixFile = Get-Content $vsixManifestPath
	
	$vsixNs = New-Object Xml.XmlNamespaceManager $vsixFile.NameTable
    $vsixNs.AddNamespace('vs', 'http://schemas.microsoft.com/developer/vsx-schema/2010')

    $versionElement = $vsixFile.SelectSingleNode('//vs:Vsix/vs:Identifier/vs:Version', $vsixNs)
	$versionElement.'#text' = "$newVersion"
	
	$vsixFile.Save($vsixManifestPath)
}

function BuildSource {

	msbuild PowerDeliveryVSExtension.2012.csproj "/consoleloggerparameters:Verbosity=q" /p:Configuration=Release /nologo
	
	if ($LASTEXITCODE -ne 0) {
		throw "MSBuild compilation failed. Last exit code was $LASTEXITCODE"
	}
}

function UpdateAssemblyInfo {

	"Updating AssemblyInfo.cs to $newVersion..."
	
	$filename = Join-Path $currentDirectory .\Properties\AssemblyInfo.cs
	
	$assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $assemblyVersion = "AssemblyVersion(""$newVersion"")"
    $fileVersion = "AssemblyFileVersion(""$newVersion"")"
	
	(Get-Content $filename) | % {
        % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
        % {$_ -replace $fileVersionPattern, $fileVersion }
    } | Set-Content $filename
}

function UpdateNuspec {

	$script:nuspecFullPath = Join-Path $currentDirectory .\PowerDelivery-VSExtension-2012.nuspec

	[xml]$nuspecFile = Get-Content $nuspecFullPath

    $namespaces = New-Object Xml.XmlNamespaceManager $nuspecFile.NameTable
    $namespaces.AddNamespace('nu', 'http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd')

    $versionElement = $nuspecFile.SelectSingleNode('//nu:package/nu:metadata/nu:version', $namespaces)

    "Updating .nuspec to $newVersion..."

    $versionElement.'#text' = "$newVersion"

    $nuspecFile.Save($nuspecFullPath)
}

function PackageChocolatey {

	"$nuspecFullPath -> PowerDelivery-VSExtension-2012.$($newVersion).nupkg"

	Exec -errorMessage "Error creating .nupkg" -ErrorAction Stop {
    	cpack "$nuspecFullPath"
	}
}

function PushChocolatey {

	$nuPkgFile = (gci *.nupkg).Name

	"$nuPkgFile -> http://www.chocolately.org..."

	Exec -errorMessage "Error pushing new package to chocolatey" -ErrorAction Stop {
	    cpush $nuPkgFile
	}
}

"----------------------------------------------------------"
"Releasing new version of powerdelivery-vsextension-2012..."
"----------------------------------------------------------"

del *.nupkg

$latestVersionMessage = $(clist powerdelivery-vsextension-2012)

$script:currentDirectory = Get-Location

if ($latestVersionMessage.Trim() -eq "No packages found.") {
    $latestVersion = "1.0.0"
    $script:newVersion = "1.0.0"
}
else {

    $latestVersion = ""

    if ($latestVersionMessage.GetType().Name -eq "Object[]") {
        $latestVersionMessage | ForEach-Object {
            if ($_.StartsWith("PowerDelivery ")) {
                $latestVersion = $_.split(' ')[1].split('.')
            }
        }
    }
    else {
        $latestVersion = $latestVersionMessage.split(' ')[1].split('.')  
    }

    $oldVersion = $latestVersion -join '.'
    $latestVersion[$latestVersion.Length-1] = $(([int]$latestVersion[$latestVersion.Length-1]) + 1)
    $script:newVersion = $latestVersion -join '.'

    "Lastest version on chocolatey is $oldVersion"

    UpdateNuspec
	UpdateAssemblyInfo
	UpdateVsix
}

BuildSource
PackageChocolatey
PushChocolatey