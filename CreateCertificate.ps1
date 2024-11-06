# Password for certificate export
$PW = Read-Host -Prompt 'Please type in a password for the certificate export'
$SecurePW = ConvertTo-SecureString -String $PW -AsPlainText -Force

# Path to certificate files
$Path = "C:\TSD.CenterVision\Daten\Zertifikate\"
if (-not (Test-Path -Path $Path)) {
    New-Item -Path $Path -ItemType Directory -Force
}

# Create certificate
# Valid for 100 years
$MyCert = New-SelfSignedCertificate -Subject 'T24-001205_Script' -CertStoreLocation 'cert:\CurrentUser\My' -KeySpec KeyExchange -NotAfter (Get-Date).AddYears(100)

# Export certificate to .pfx file
$MyCert | Export-PfxCertificate -FilePath "$( $Path )\T24-001205_Script.pfx" -Password $SecurePW

# Export certificate to .cer file
$MyCert | Export-Certificate -FilePath "$( $Path )\T24-001205_Script.cer"
