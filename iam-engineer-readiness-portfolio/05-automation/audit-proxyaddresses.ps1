<#
.SYNOPSIS
    Audit-ProxyAddresses.ps1

.DESCRIPTION
    Audits proxyAddress attributes across all mail-enabled user objects in Active Directory.
    Identifies users missing expected routing addresses (.onmicrosoft.us for GCC High,
    .onmicrosoft.com for commercial), duplicate SMTP primary addresses, and malformed entries.
    
    Outputs a CSV report for remediation planning.

.PARAMETER DomainController
    Target domain controller for AD queries.

.PARAMETER OutputPath
    Path for the CSV output report. Defaults to current directory.

.PARAMETER TenantSuffix
    The expected onmicrosoft routing suffix for your tenant.
    Example: "contoso.onmicrosoft.us" for GCC High, "contoso.onmicrosoft.com" for commercial.

.PARAMETER SearchBase
    OU distinguished name to limit scope. Leave blank to search entire domain.

.EXAMPLE
    .\Audit-ProxyAddresses.ps1 -TenantSuffix "meridian.onmicrosoft.us" -OutputPath "C:\Reports\"

.NOTES
    Requirements: ActiveDirectory PowerShell module (RSAT)
    
    Portfolio: IAM Engineer Readiness Portfolio
    Section: 05-automation
    Author: Jared Hernandez
    Environment: Lab (Meridian Consulting Group) / Production-adaptable (GCC High)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantSuffix,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\",
    
    [Parameter(Mandatory = $false)]
    [string]$SearchBase,
    
    [Parameter(Mandatory = $false)]
    [string]$DomainController
)

#region Initialization
$ErrorActionPreference = "Continue"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = Join-Path $OutputPath "ProxyAddress_Audit_$timestamp.csv"

Write-Host "`n=== ProxyAddress Audit Script ===" -ForegroundColor Cyan
Write-Host "Tenant Suffix: $TenantSuffix" -ForegroundColor Gray
Write-Host "Output: $reportFile" -ForegroundColor Gray
Write-Host "================================`n" -ForegroundColor Cyan

$results = [System.Collections.Generic.List[PSCustomObject]]::new()
$issueCount = 0
#endregion

#region Get Mail-Enabled Users
Write-Host "Querying Active Directory for mail-enabled users..." -ForegroundColor Yellow

$adParams = @{
    Filter     = { mail -like "*@*" }
    Properties = "UserPrincipalName", "mail", "proxyAddresses", "Enabled",
                 "DisplayName", "DistinguishedName", "Department", "LastLogonDate"
}

if ($SearchBase)       { $adParams["SearchBase"]       = $SearchBase }
if ($DomainController) { $adParams["Server"]            = $DomainController }

try {
    $users = Get-ADUser @adParams
    Write-Host "Found $($users.Count) mail-enabled user objects." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to query Active Directory: $_" -ForegroundColor Red
    exit 1
}
#endregion

#region Audit Each User
Write-Host "`nAuditing proxy addresses..." -ForegroundColor Yellow

foreach ($user in $users) {
    $issues   = [System.Collections.Generic.List[string]]::new()
    $proxies  = @($user.proxyAddresses)
    
    # --- Check 1: Missing tenant routing address
    $hasRoutingAddress = $proxies | Where-Object { $_ -match [regex]::Escape($TenantSuffix) }
    if (-not $hasRoutingAddress) {
        $issues.Add("MISSING_ROUTING_ADDRESS: No smtp address matching '$TenantSuffix' found")
        $issueCount++
    }
    
    # --- Check 2: Multiple primary SMTP addresses (uppercase SMTP = primary)
    $primaryAddresses = $proxies | Where-Object { $_ -cmatch "^SMTP:" }
    if ($primaryAddresses.Count -eq 0) {
        $issues.Add("MISSING_PRIMARY_SMTP: No primary SMTP (uppercase) address found")
        $issueCount++
    } elseif ($primaryAddresses.Count -gt 1) {
        $issues.Add("DUPLICATE_PRIMARY_SMTP: Multiple SMTP primary addresses found ($($primaryAddresses.Count))")
        $issueCount++
    }
    
    # --- Check 3: UPN/mail mismatch
    if ($user.mail -and $user.UserPrincipalName) {
        # In many orgs, UPN and mail should match. Flag if they don't.
        $upnDomain  = $user.UserPrincipalName.Split("@")[1]
        $mailDomain = $user.mail.Split("@")[1]
        if ($upnDomain -ne $mailDomain) {
            $issues.Add("UPN_MAIL_DOMAIN_MISMATCH: UPN suffix '$upnDomain' != mail suffix '$mailDomain'")
        }
    }
    
    # --- Check 4: Non-routable UPN suffix
    if ($user.UserPrincipalName -match "\.local$") {
        $issues.Add("NON_ROUTABLE_UPN: UPN uses .local suffix — Entra Connect will substitute")
    }
    
    # --- Check 5: Empty proxyAddresses
    if ($proxies.Count -eq 0) {
        $issues.Add("NO_PROXY_ADDRESSES: proxyAddresses attribute is empty")
        $issueCount++
    }
    
    # Build result object
    $result = [PSCustomObject]@{
        DisplayName        = $user.DisplayName
        SamAccountName     = $user.SamAccountName
        UserPrincipalName  = $user.UserPrincipalName
        Mail               = $user.mail
        Enabled            = $user.Enabled
        Department         = $user.Department
        LastLogonDate      = $user.LastLogonDate
        ProxyAddressCount  = $proxies.Count
        ProxyAddresses     = ($proxies -join " | ")
        IssueCount         = $issues.Count
        Issues             = ($issues -join "; ")
        HasIssues          = ($issues.Count -gt 0)
        DistinguishedName  = $user.DistinguishedName
    }
    
    $results.Add($result)
    
    if ($issues.Count -gt 0) {
        Write-Host "  [ISSUE] $($user.DisplayName) ($($user.SamAccountName)) — $($issues.Count) issue(s)" -ForegroundColor Yellow
    }
}
#endregion

#region Export Report
Write-Host "`nExporting report..." -ForegroundColor Yellow
$results | Export-Csv -Path $reportFile -NoTypeInformation -Encoding UTF8
Write-Host "Report saved: $reportFile" -ForegroundColor Green
#endregion

#region Summary
$usersWithIssues = ($results | Where-Object { $_.HasIssues }).Count
$missingRouting  = ($results | Where-Object { $_.Issues -match "MISSING_ROUTING_ADDRESS" }).Count
$multiPrimary    = ($results | Where-Object { $_.Issues -match "DUPLICATE_PRIMARY_SMTP" }).Count
$noProxy         = ($results | Where-Object { $_.Issues -match "NO_PROXY_ADDRESSES" }).Count

Write-Host "`n=== AUDIT SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total users audited        : $($users.Count)"
Write-Host "Users with issues          : $usersWithIssues"
Write-Host "Missing routing address    : $missingRouting  ← Mail delivery risk"
Write-Host "Duplicate primary SMTP     : $multiPrimary"
Write-Host "No proxy addresses at all  : $noProxy"
Write-Host "Total individual issues    : $issueCount"
Write-Host "======================" -ForegroundColor Cyan

if ($usersWithIssues -gt 0) {
    Write-Host "`n[ACTION REQUIRED] Review the CSV report and remediate flagged users." -ForegroundColor Red
    Write-Host "Priority: Fix MISSING_ROUTING_ADDRESS first — these users cannot receive external mail." -ForegroundColor Red
} else {
    Write-Host "`n[OK] No proxy address issues detected." -ForegroundColor Green
}

Write-Host "`nAudit complete.`n" -ForegroundColor Cyan
#endregion
