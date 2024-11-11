<#
.SYNOPSIS
    AzurePermissionMiddleWare

.DESCRIPTION
    T24-001205 - Hartmut Kreutz Berechtigung erteilen Benutzer zu deaktivieren / deren Anmeldung blockieren

.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does

.INPUTS
    Inputs (if any)

.OUTPUTS
    Output (if any)

.LINK
    GitHub: https://github.com/MichaelSchoenburg/AzurePermissionMiddleWare

.NOTES
    Author: Michael Schönburg
    Version: v1.0
    Creation: 06.11.2024
    Last Edit: 06.11.2024
    
    This projects code loosely follows the PowerShell Practice and Style guide, as well as Microsofts PowerShell scripting performance considerations.
    Style guide: https://poshcode.gitbook.io/powershell-practice-and-style/
    Performance Considerations: https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1
#>

#region FUNCTIONS
<# 
    Declare Functions
#>

function Write-ConsoleLog {
    <#
    .SYNOPSIS
    Logs an event to the console.
    
    .DESCRIPTION
    Writes text to the console with the current date (US format) in front of it.
    
    .PARAMETER Text
    Event/text to be outputted to the console.
    
    .EXAMPLE
    Write-ConsoleLog -Text 'Subscript XYZ called.'
    
    Long form
    .EXAMPLE
    Log 'Subscript XYZ called.
    
    Short form
    #>
    [alias('Log')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        Position = 0)]
        [string]
        $Text
    )

    # Save current VerbosePreference
    $VerbosePreferenceBefore = $VerbosePreference

    # Enable verbose output
    $VerbosePreference = 'Continue'

    # Write verbose output
    Write-Verbose "$( Get-Date -Format 'MM/dd/yyyy HH:mm:ss' ) - $( $Text )"

    # Restore current VerbosePreference
    $VerbosePreference = $VerbosePreferenceBefore
}

#endregion FUNCTIONS
#region INITIALIZATION
<# 
    Libraries, Modules, ...
#>

Log 'Lade Module...'

# Require PowerShell Version 7 for Azure Module
#Requires -Version 7

# Require Azure PowerShell-Module
#Requires -Modules Az.Accounts, Az.Resources
Import-Module -Name Az.Accounts, Az.Resources

# Require Microsoft Graph PowerShell SDK
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users.Actions
Import-Module -Name Microsoft.Graph.Authentication, Microsoft.Graph.Users.Actions

# Check if .NET Framework 4.7.2+ is installed for Microsoft Graph PowerShell SDK
$release = Get-ItemPropertyValue -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release
if ($release -lt 461808) {
    throw '.NET Framework 4.7.2 or later required but not found. Please visit https://learn.microsoft.com/en-us/dotnet/framework/install/'
}

#endregion INITIALIZATION
#region DECLARATIONS
<#
    Declare local variables and global variables
#>

$AzureAplicationId = # Hier eintragen
$AzureTenantId = # Hier eintragen
$LocalCertThumb = # Hier eintragen

#endregion DECLARATIONS
#region EXECUTION
<# 
    Script entry point
#>

try {
    # Assign to $null to suppress console output
    Log 'Verbinde zu Azure...'
    $null = Connect-AzAccount -ApplicationId $AzureAplicationId -TenantId $AzureTenantId -ServicePrincipal:$true -CertificateThumbprint $LocalCertThumb -ErrorAction Stop

    Log 'Bereite Benutzerauswahl durch Mensch vor...'
    $User = Get-AzADUser | 
        Select-Object @{n='Vorname';e={$_.GivenName}}, @{n='Nachname';e={$_.Surname}}, @{n='Anzeigename';e={$_.DisplayName}}, UserPrincipalName, Id | 
        Out-GridView -OutputMode Single -Title 'Bitte wähle den zu deaktivierenden Benutzer aus'

    Log 'Deaktiviere Benutzer...'
    $null = Set-AzADUser -UPNOrObjectId $User.UserPrincipalName -AccountEnabled:$false

    $null = Disconnect-AzAccount

    Log 'Verbinde zu Microsoft Graph API...'
    $null = Connect-MgGraph -ClientID $AzureAplicationId -TenantId $AzureTenantId -CertificateThumbprint $LocalCertThumb -NoWelcome -ErrorAction Stop

    Log 'Wiederrufe alle aktiven Sitzungen des Benutzers...'
    $null = Revoke-MgUserSignInSession -UserId $User.Id -Confirm:$false

    $null = Disconnect-MgGraph

    Log 'Fertig.'
    Log 'Fesnster schließ sich in 3'
    Start-Sleep -Seconds 1
    Log 'Fesnster schließ sich in 2'
    Start-Sleep -Seconds 1
    Log 'Fesnster schließ sich in 1'
    Start-Sleep -Seconds 1
} catch {
    Log 'Ein Fehler ist aufgetreten. Bitte Michael Schönburg unter support@itc-engels.de folgende Fehlermeldung zusenden:'
    $_
}

#endregion EXECUTION
