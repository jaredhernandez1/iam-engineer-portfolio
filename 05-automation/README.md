# Automation Scripts — IAM PowerShell Library

**Portfolio Section:** `05-automation/`  
**Language:** PowerShell 5.1+ / PowerShell 7+  
**Modules Required:** ActiveDirectory (RSAT), Microsoft.Graph  

---

## Script Index

| Script | Purpose | Environment | Status |
|---|---|---|---|
| `check-hybrid-user-health.ps1` | Per-user hybrid identity health check (AD + Entra ID) | Lab + Production | ✅ Complete |
| `audit-proxyaddresses.ps1` | Bulk audit of proxyAddress attributes across all mail-enabled AD users | Lab + Production | ✅ Complete |
| `report-stale-users.ps1` | Stale user report combining AD last logon + Entra ID sign-in activity + license data | Lab + Production | ✅ Complete |

**Planned:**
- `new-employee-provisioning.ps1` — JML Joiner automation (Phase 1 of JML pipeline)
- `offboard-user.ps1` — JML Leaver automation (session revoke, group removal, disable)
- `export-ca-policy-inventory.ps1` — Export all CA policies to JSON/CSV for documentation
- `audit-privileged-roles.ps1` — Report on all users holding Entra directory roles

---

## Prerequisites

### PowerShell Modules

```powershell
# Active Directory module (requires RSAT on Windows)
# Enable via Windows Features or:
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"

# Microsoft Graph PowerShell SDK
Install-Module Microsoft.Graph -Scope CurrentUser
```

### Microsoft Graph Permissions Required

| Script | Required Permissions |
|---|---|
| `check-hybrid-user-health.ps1` | `User.Read.All`, `AuditLog.Read.All` |
| `report-stale-users.ps1` | `User.Read.All`, `AuditLog.Read.All` |
| `audit-proxyaddresses.ps1` | Active Directory only (no Graph required) |

---

## Sanitization Notes

All scripts in this library:
- Use no hardcoded tenant IDs, object IDs, or credentials
- Accept all environment-specific values as parameters
- Are safe for public GitHub publication in their current form
- Use `-TenantSuffix` and `-OutputPath` parameters rather than hardcoded values

---

## Usage Examples

```powershell
# Check a single user's hybrid health
.\check-hybrid-user-health.ps1 -SamAccountName "jsmith"

# Audit all proxy addresses in domain for GCC High tenant
.\audit-proxyaddresses.ps1 -TenantSuffix "contoso.onmicrosoft.us" -OutputPath "C:\Reports\"

# Generate stale user report (90-day threshold, 180-day critical)
.\report-stale-users.ps1 -StaleThresholdDays 90 -CriticalThresholdDays 180
```

---

## Design Philosophy

These scripts follow the **operator, not archivist** principle:

- Built to solve real problems, not to demonstrate knowledge
- Designed for reuse: parameterized, not hardcoded
- Outputs actionable reports, not raw data dumps
- Errors fail loudly with clear messages

Each script was built to address a real or simulated production scenario documented in the portfolio.

---

## SC-300 Concepts Reinforced

- Microsoft Graph PowerShell SDK (`Microsoft.Graph` module)
- Entra ID user management via Graph API
- Sign-in activity and audit log access
- Active Directory attribute management
- Identity lifecycle automation principles
