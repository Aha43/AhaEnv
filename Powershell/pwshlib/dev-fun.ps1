
# This file contains functions that are useful for development work.

function dev-help {
    Write-Host
    Write-Host "Development functions:"
    Write-Host "    dev-help:                       Show this help"
    Write-Host "    csln:                           Clear a solution of all build artifacts"
    Write-Host "    create-self-signed-cert:        Create a self-signed certificate for localhost"
    Write-Host
}

# Clears a solution of all build artifacts.
function csln {
    if (-not (Test-Path "*.sln")) {
        Write-Host "No solution file found in the current directory."
        return
    }

    Get-ChildItem -Recurse -Filter "obj" | Remove-Item -Recurse -Force
    Get-ChildItem -Recurse -Filter "bin" | Remove-Item -Recurse -Force
}

function create-self-signed-cert {
    $certName = "localhost"
    $certPassword = "at_starbucks-basar"
    $certPath = "~/certs/$certName.pfx"

    if (-not (Test-Path "certs")) {
        New-Item -ItemType Directory -Path "certs"
    }

    if (Test-Path $certPath) {
        Write-Host "Certificate already exists at $certPath"
        return
    }

    $cert = New-SelfSignedCertificate -DnsName $certName -CertStoreLocation "cert:\LocalMachine\My" -KeyExportPolicy Exportable -KeySpec Signature
    $cert | Export-PfxCertificate -FilePath $certPath -Password (ConvertTo-SecureString -String $certPassword -Force -AsPlainText)
}