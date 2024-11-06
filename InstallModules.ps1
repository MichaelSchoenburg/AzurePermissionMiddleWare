# PowerShell 7 installieren

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Install-Module PowerShellGet

Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Install-Module -Name Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
