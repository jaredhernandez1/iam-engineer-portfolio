<#
.SYNOPSIS
    Check-HybridUserHealth.ps1
    
.DESCRIPTION
    Performs a health check on a specific synced (hybrid) user object, validating
    Entra Connect sync status, UPN routing, proxy addresses, and cloud account state.
    
    Designed for use in hybrid identity troubleshooting (on-prem AD + Entra ID).
    
.PARAMETER UserPrincipalName
    The UPN of the user to investigate. Can be the on-premises UPN or cloud UPN.
    
.PARAMETER SamAccountName
    The SAM account name of the user in Active Directory.

.EXAMPLE
    .\Check-HybridUserHealth.ps1 -SamAccountName "jsmith"
    
.NOTES
    Requirements:
    - ActiveDirectory PowerShell module (RSAT)
    - Microsoft.Graph PowerShell module (Install-Module Microsoft.Graph)
    - Run from the domain-joined Entra Connect server or a machine with AD access
    - Microsoft Graph: Requires User.Read.All and AuditLog.Read.All permissions
    
    Portfolio: IAM Engineer Readiness Portfolio
    Section: 05-automation
    Author: Jared Hernandez
    Environment: Lab (Meridian Consulting Group) / Production-adaptable
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$UserPrincipalName,
    
    [Parameter(Mandatory = $false)]
    [string]$SamAccountName
)

#region Initialization
$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "`n=== Hybrid User Health Check ===" -ForegroundColor Cyan
Write-Host "Run Time: $timestamp" -ForegroundColor Gray
Write-Host "================================`n" -ForegroundColor Cyan
#endregion

#region Active Directory Check
Write-Host "[1/5] Checking Active Directory object..." -ForegroundColor Yellow

try {
    if ($SamAccountName) {
        $adUser = Get-ADUser -Identity $SamAccountName -Properties `
            UserPrincipalName, mail, proxyAddresses, Enabled, `
            PasswordLastSet, LastLogonDate, DistinguishedName, `
            msDS-cloudExtensionAttribute1, extensionAttribute1
    } elseif ($UserPrincipalName) {
        $adUser = Get-ADUser -Filter {UserPrincipalName -eq $UserPrincipalName} -Properties `
            UserPrincipalName, mail, proxyAddresses, Enabled, `
            PasswordLastSet, LastLogonDate, DistinguishedName, `
            msDS-cloudExtensionAttribute1, extensionAttribute1
    } else {
        Write-Error "Provide either -UserPrincipalName or -SamAccountName."
        exit 1
    }
    
    if (-not $adUser) {
        Write-Host "  [!] User NOT FOUND in Active Directory." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "  [OK] AD Object found." -ForegroundColor Green
    Write-Host "       Display Name : $($adUser.Name)"
    Write-Host "       SAM Account  : $($adUser.SamAccountName)"
    Write-Host "       UPN          : $($adUser.UserPrincipalName)"
    Write-Host "       Enabled      : $($adUser.Enabled)"
    Write-Host "       OU           : $($adUser.DistinguishedName -replace '^CN=[^,]+,','')"
    Write-Host "       Last Logon   : $($adUser.LastLogonDate)"
    Write-Host "       Pwd Last Set : $($adUser.PasswordLastSet)"
    
    # Check UPN suffix
    $upnSuffix = $adUser.UserPrincipalName.Split("@")[1]
    Write-Host "`n  UPN Suffix Check:" -ForegroundColor Yellow
    Write-Host "       Suffix: $upnSuffix"
    
    if ($upnSuffix -match "\.local$") {
        Write-Host "  [WARN] Non-routable UPN suffix detected (.local). " -ForegroundColor Yellow
        Write-Host "         Entra Connect will substitute with .onmicrosoft.com or .onmicrosoft.us" -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] UPN suffix appears routable." -ForegroundColor Green
    }
    
    # Check proxy addresses
    Write-Host "`n  ProxyAddress Check:" -ForegroundColor Yellow
    $proxies = $adUser.proxyAddresses
    if (-not $proxies) {
        Write-Host "  [WARN] No proxyAddresses found on AD object." -ForegroundColor Yellow
    } else {
        foreach ($proxy in $proxies) {
            $flag = if ($proxy -cmatch "^SMTP:") { "[PRIMARY]" } else { "[alias  ]" }
            Write-Host "       $flag $proxy"
        }
        
        # Check for .onmicrosoft.us (GCC High routing address)
        $hasGccHigh = $proxies | Where-Object { $_ -match "\.onmicrosoft\.us$" }
        $hasGccCom  = $proxies | Where-Object { $_ -match "\.onmicrosoft\.com$" }
        
        if ($hasGccHigh) {
            Write-Host "  [OK] GCC High routing address (.onmicrosoft.us) present." -ForegroundColor Green
        } elseif ($hasGccCom) {
            Write-Host "  [OK] Commercial routing address (.onmicrosoft.com) present." -ForegroundColor Green
        } else {
            Write-Host "  [WARN] No .onmicrosoft routing address found. Mail delivery may fail." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "  [ERROR] AD check failed: $_" -ForegroundColor Red
}
#endregion

#region Entra Connect Sync Check
Write-Host "`n[2/5] Checking Entra Connect Sync service..." -ForegroundColor Yellow

try {
    $syncService = Get-Service -Name "ADSync" -ErrorAction SilentlyContinue
    
    if ($syncService) {
        Write-Host "  Service Status: $($syncService.Status)" -ForegroundColor $(if ($syncService.Status -eq "Running") {"Green"} else {"Red"})
        
        $scheduler = Get-ADSyncScheduler
        Write-Host "  Sync Enabled        : $($scheduler.SyncCycleEnabled)"
        Write-Host "  Last Sync Started   : $($scheduler.LastSyncCycleStarted)"
        Write-Host "  Last Sync Result    : $($scheduler.LastSyncCycleResult)"
        Write-Host "  Next Sync Due       : $($scheduler.NextSyncCyclePolicyType)"
    } else {
        Write-Host "  [INFO] ADSync service not found on this machine." -ForegroundColor Gray
        Write-Host "         Run the Entra Connect checks from the sync server." -ForegroundColor Gray
    }
}
catch {
    Write-Host "  [INFO] ADSync module not available on this machine: $_" -ForegroundColor Gray
}
#endregion

#region Microsoft Graph / Entra ID Check
Write-Host "`n[3/5] Checking Entra ID (Microsoft Graph)..." -ForegroundColor Yellow

try {
    # Connect to Graph (interactive)
    Write-Host "  Connecting to Microsoft Graph..." -ForegroundColor Gray
    Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All" -NoWelcome
    
    $cloudUser = Get-MgUser -UserId $adUser.UserPrincipalName `
        -Property "id,displayName,userPrincipalName,accountEnabled,onPremisesSyncEnabled,onPremisesImmutableId,proxyAddresses,assignedLicenses,lastPasswordChangeDateTime,signInActivity" `
        -ErrorAction Stop
    
    Write-Host "  [OK] Entra ID object found." -ForegroundColor Green
    Write-Host "       Cloud UPN         : $($cloudUser.UserPrincipalName)"
    Write-Host "       Account Enabled   : $($cloudUser.AccountEnabled)"
    Write-Host "       On-Prem Sync      : $($cloudUser.OnPremisesSyncEnabled)"
    Write-Host "       Immutable ID Set  : $(-not [string]::IsNullOrEmpty($cloudUser.OnPremisesImmutableId))"
    Write-Host "       Licenses Assigned : $($cloudUser.AssignedLicenses.Count)"
    
    # Check sync state match
    Write-Host "`n  Sync State Validation:" -ForegroundColor Yellow
    if ($cloudUser.OnPremisesSyncEnabled -eq $true) {
        Write-Host "  [OK] User is confirmed as cloud-synced (hybrid identity)." -ForegroundColor Green
    } else {
        Write-Host "  [WARN] OnPremisesSyncEnabled is FALSE or null. User may be cloud-only." -ForegroundColor Yellow
    }
    
    # UPN match check
    $adUpn    = $adUser.UserPrincipalName
    $cloudUpn = $cloudUser.UserPrincipalName
    
    Write-Host "`n  UPN Consistency Check:" -ForegroundColor Yellow
    Write-Host "       AD UPN    : $adUpn"
    Write-Host "       Cloud UPN : $cloudUpn"
    
    if ($adUpn -eq $cloudUpn) {
        Write-Host "  [OK] UPNs match." -ForegroundColor Green
    } else {
        Write-Host "  [WARN] UPN mismatch detected. Entra Connect may have substituted the UPN." -ForegroundColor Yellow
        Write-Host "         This is expected if the AD UPN uses a non-routable suffix." -ForegroundColor Gray
    }
}
catch {
    Write-Host "  [ERROR] Graph check failed: $_" -ForegroundColor Red
    Write-Host "         Ensure the account has User.Read.All permissions." -ForegroundColor Gray
}
#endregion

#region Last Sign-In Check
Write-Host "`n[4/5] Checking recent sign-in activity..." -ForegroundColor Yellow

try {
    $signInActivity = (Get-MgUser -UserId $adUser.UserPrincipalName -Property "signInActivity").SignInActivity
    
    if ($signInActivity) {
        Write-Host "  Last Successful Sign-In    : $($signInActivity.LastSignInDateTime)"
        Write-Host "  Last Non-Interactive Login : $($signInActivity.LastNonInteractiveSignInDateTime)"
        
        $daysSinceLogin = (Get-Date) - $signInActivity.LastSignInDateTime
        if ($daysSinceLogin.Days -gt 90) {
            Write-Host "  [WARN] Last sign-in was $($daysSinceLogin.Days) days ago. Account may be stale." -ForegroundColor Yellow
        } else {
            Write-Host "  [OK] Active sign-in within the last $($daysSinceLogin.Days) days." -ForegroundColor Green
        }
    } else {
        Write-Host "  [INFO] No sign-in activity data available." -ForegroundColor Gray
    }
}
catch {
    Write-Host "  [INFO] Sign-in activity requires AuditLog.Read.All permission." -ForegroundColor Gray
}
#endregion

#region Summary
Write-Host "`n[5/5] Summary" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "User           : $($adUser.Name) ($($adUser.SamAccountName))"
Write-Host "AD Enabled     : $($adUser.Enabled)"
Write-Host "AD UPN         : $($adUser.UserPrincipalName)"
Write-Host "ProxyAddresses : $($adUser.proxyAddresses.Count) entries"
Write-Host "Sync Enabled   : $($cloudUser.OnPremisesSyncEnabled)"
Write-Host "Cloud Enabled  : $($cloudUser.AccountEnabled)"
Write-Host "Licenses       : $($cloudUser.AssignedLicenses.Count)"
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Health check complete. Review any [WARN] or [ERROR] entries above.`n" -ForegroundColor Cyan
#endregion
