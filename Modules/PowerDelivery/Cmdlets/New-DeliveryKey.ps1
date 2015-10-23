<#
.Synopsis
Generates a powerdelivery key file used to encrypt credentials.

.Description
Generates a powerdelivery key file used to encrypt credentials.

The key will be created at the path:

<Drive>:\Users\<User>\Documents\PowerDelivery\Keys\<Project>\<KeyName>.key

.Example
New-DeliveryKey MyKey

.Parameter KeyName
The name of the key to generate.
#>
function New-DeliveryKey {
  [CmdletBinding()]
  param(
    [Parameter(Position=0,Mandatory=1)][string] $KeyName
  )

  ValidateNewFileName -FileName $KeyName -Description "key name"
  $projectDir = GetProjectDirectory

  $key = New-Object Byte[] 32
  [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)
  $keyString = [Convert]::ToBase64String($key)

  $myDocumentsFolder = [Environment]::GetFolderPath("MyDocuments")
  $keysFolderPath = Join-Path $myDocumentsFolder "PowerDelivery\Keys\$projectDir"
  $keyFilePath = Join-Path $keysFolderPath "$KeyName.key"

  if (Test-Path $keyFilePath) {
    throw "Key $keyFilePath already exists."
  }

  if (!(Test-Path $keysFolderPath)) {
    New-Item $keysFolderPath -ItemType Directory | Out-Null
  }

  $keyString | Out-File -FilePath $keyFilePath

  Write-Host "Key written to ""$keyFilePath"""
}

Export-ModuleMember -Function New-DeliveryKey