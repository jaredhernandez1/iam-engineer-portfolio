<#
.SYNOPSIS
    Report-StaleUsers.ps1

.DESCRIPTION
    Generates a stale user report combining Active Directory last logon data with
    Entra ID sign-in activity and license assignment. Identifies users who may be
    inactive, should be reviewed for offboarding, or represent unnecessary license spend.
    
    Outputs a CSV report categorized by staleness tier.

.PARAMETER StaleThresholdDays
    Number of days without sign-in activity to consider a user stale. Default: 90.

.PARAMETER CriticalThresholdDays
    Number of days without sign-in activity to flag as critical (likely departed). Default: 180.

.PARAMETER OutputPath
    Directory for CSV output. Defaults to current directory.

.PARAMETER ExcludeOU
    OU distinguished name to exclude from the report (e.g., service accounts OU).

.EXAMPLE
    .\Report-StaleUsers.ps1 -StaleThresholdDays 90 -CriticalThresholdDays 180 -OutputPath "C:\Reports\"

.NOTES
    Requirements:
    - ActiveDirectory PowerShell module (RSAT)
    - Microsoft.Graph PowerShell module
    - Graph permissions: User.Read.All, AuditLog.Read.All
    
    Portfolio: IAM Engineer Readiness Portfolio
    Section: 05-automation
    Author: Jared Hernandez
    Environment: Lab (Meridian Consulting Group) / Production-adaptable
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$StaleThresholdDays    = 90,
    
    [Parameter(Mandatory = $false)]
    [int]$CriticalThresholdDays = 180,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\",
    
    [Parameter(Mandatory = $false)]
    [string]$ExcludeOU
)

#region Initialization
$ErrorActionPreference = "Continue"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = Join-Path $OutputPath "StaleUser_Report_$timestamp.csv"
$today = Get-Date

Write-Host "`n=== Stale User Report ===" -ForegroundColor Cyan
Write-Host "Stale threshold   : $StaleThresholdDays days"
Write-Host "Critical threshold: $CriticalThresholdDays days"
Write-Host "Output            : $reportFile"
Write-Host "========================`n" -ForegroundColor Cyan

$results = [System.Collections.Generic.List[PSCustomObject]]::new()
#endregion

#region Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
try {
    Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All" -NoWelcome
    Write-Host "Connected." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Graph connection failed: $_" -ForegroundColor Red
    exit 1
}
#endregion

#region Get AD Users
Write-Host "`nQuerying Active Directory..." -ForegroundColor Yellow

$adParams = @{
    Filter     = { Enabled -eq $true }
    Properties = "UserPrincipalName", "mail", "DisplayName", "Department",
                 "Manager", "LastLogonDate", "PasswordLastSet", "Created",
                 "DistinguishedName", "Title", "Enabled"
}

$adUsers = Get-ADUser @adParams | Where-Object {
    # Exclude service accounts and computer-associated accounts
    $_.SamAccountName -notmatch "^\$" -and
    $_.DistinguishedName -notmatch "CN=Users"  # Optionally exclude default Users container
}

if ($ExcludeOU) {
    $adUsers = $adUsers | Where-Object { $_.DistinguishedName -notmatch [regex]::Escape($ExcludeOU) }
}

Write-Host "Found $($adUsers.Count) enabled AD user accounts." -ForegroundColor Green
#endregion

#region Process Each User
Write-Host "`nProcessing users (this may take a while for large directories)..." -ForegroundColor Yellow

$processed = 0
foreach ($adUser in $adUsers) {
    $processed++
    if ($processed % 25 -eq 0) {
        Write-Host "  Progress: $processed / $($adUsers.Count)" -ForegroundColor Gray
    }
    
    # --- Get Entra ID sign-in activity
    $lastCloudSignIn = $null
    $cloudEnabled    = $null
    $licenseCount    = 0
    $syncEnabled     = $false
    
    try {
        $cloudUser = Get-MgUser -UserId $adUser.UserPrincipalName `
            -Property "id,accountEnabled,assignedLicenses,onPremisesSyncEnabled,signInActivity" `
            -ErrorAction SilentlyContinue
        
        if ($cloudUser) {
            $cloudEnabled   = $cloudUser.AccountEnabled
            $licenseCount   = $cloudUser.AssignedLicenses.Count
            $syncEnabled    = $cloudUser.OnPremisesSyncEnabled
            $lastCloudSignIn = $cloudUser.SignInActivity.LastSignInDateTime
        }
    }
    catch {
        # User may not exist in Entra ID (not synced yet or orphaned)
        $cloudEnabled = "NOT_FOUND"
    }
    
    # --- Calculate staleness
    $lastActivity = $null
    if ($lastCloudSignIn) {
        $lastActivity = $lastCloudSignIn
    } elseif ($adUser.LastLogonDate) {
        $lastActivity = $adUser.LastLogonDate
    }
    
    $daysSinceActivity = $null
    $stalenessCategory = "Unknown"
    
    if ($lastActivity) {
        $daysSinceActivity = [int](($today - $lastActivity).TotalDays)
        
        $stalenessCategory = switch ($daysSinceActivity) {
            { $_ -le 30 }                                                    { "Active" }
            { $_ -gt 30  -and $_ -le $StaleThresholdDays }                  { "Moderate" }
            { $_ -gt $StaleThresholdDays -and $_ -le $CriticalThresholdDays }{ "Stale" }
            { $_ -gt $CriticalThresholdDays }                                { "Critical" }
            default                                                           { "Unknown" }
        }
    } else {
        $stalenessCategory = "Never_Logged_In"
    }
    
    # --- Recommended action
    $recommendedAction = switch ($stalenessCategory) {
        "Active"          { "No action needed" }
        "Moderate"        { "Monitor" }
        "Stale"           { "Review with manager — confirm still active" }
        "Critical"        { "DISABLE and remove license — likely departed" }
        "Never_Logged_In" { "Review — account never used, confirm is needed" }
        default           { "Manual review required" }
    }
    
    $result = [PSCustomObject]@{
        DisplayName          = $adUser.DisplayName
        SamAccountName       = $adUser.SamAccountName
        UserPrincipalName    = $adUser.UserPrincipalName
        Department           = $adUser.Department
        Title                = $adUser.Title
        ADEnabled            = $adUser.Enabled
        CloudEnabled         = $cloudEnabled
        IsSynced             = $syncEnabled
        LicenseCount         = $licenseCount
        ADLastLogon          = $adUser.LastLogonDate
        CloudLastSignIn      = $lastCloudSignIn
        MostRecentActivity   = $lastActivity
        DaysSinceActivity    = $daysSinceActivity
        StalenessCategory    = $stalenessCategory
        RecommendedAction    = $recommendedAction
        AccountCreated       = $adUser.Created
        PasswordLastSet      = $adUser.PasswordLastSet
        DistinguishedName    = $adUser.DistinguishedName
    }
    
    $results.Add($result)
}
#endregion

#region Export and Summary
Write-Host "`nExporting report..." -ForegroundColor Yellow
$results | Sort-Object DaysSinceActivity -Descending | 
    Export-Csv -Path $reportFile -NoTypeInformation -Encoding UTF8

Write-Host "Report saved: $reportFile" -ForegroundColor Green

$categoryGroups = $results | Group-Object StalenessCategory

Write-Host "`n=== STALE USER SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total users analyzed: $($results.Count)"
Write-Host ""
foreach ($group in $categoryGroups | Sort-Object Name) {
    $color = switch ($group.Name) {
        "Active"          { "Green" }
        "Moderate"        { "White" }
        "Stale"           { "Yellow" }
        "Critical"        { "Red" }
        "Never_Logged_In" { "Magenta" }
        default           { "Gray" }
    }
    Write-Host "  $($group.Name.PadRight(20)): $($group.Count) users" -ForegroundColor $color
}

$criticalCount  = ($results | Where-Object { $_.StalenessCategory -eq "Critical" }).Count
$licenseWaste   = ($results | Where-Object { $_.StalenessCategory -in @("Critical","Stale") } | 
                   Measure-Object -Property LicenseCount -Sum).Sum

Write-Host ""
Write-Host "Critical users (>$CriticalThresholdDays days): $criticalCount  ← Immediate review recommended" -ForegroundColor Red
Write-Host "Estimated licenses on stale/critical users: $licenseWaste" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Cyan
Write-Host "`nReport complete.`n" -ForegroundColor Cyan
#endregion
