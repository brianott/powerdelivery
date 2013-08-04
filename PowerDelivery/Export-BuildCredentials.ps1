﻿function Export-BuildCredentials {

    $currentDirectory = Get-Location
    $credentialsPath = Join-Path $currentDirectory Credentials

    if (!(Test-Path $credentialsPath)) {
        mkdir -Force $credentialsPath | Out-Null
    }

    "Enter the username of an account to export credentials of:"
    $userName = Read-Host

    $userNameFile = $userName -replace "\\", "#"

    $userNamePath = Join-Path $credentialsPath "$($userNameFile).txt"

    "Enter the password of the account:"
    $password = Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $userNamePath -Force

    "Credentials exported at $userNamePath"
}