# Break-Glass Account Design — Emergency Access for Meridian Consulting Group

**Portfolio Folder:** `06-design-reviews/`  
**Artifact Type:** Security Design Document  
**Environment:** Lab (Meridian Consulting Group) — production-applicable  
**Status:** ✅ Design complete — implement before any CA policy work  

---

## Purpose

Document the design and configuration requirements for emergency access (break-glass) accounts in a Microsoft Entra ID tenant. Break-glass accounts are the safety net that prevents an organization from being permanently locked out of their own tenant.

---

## Why Break-Glass Accounts Are Non-Negotiable

Every CA policy has the potential to lock out administrators — especially when:
- A Conditional Access policy requires a device that's suddenly unavailable
- MFA devices are lost, broken, or stolen
- The identity provider (Entra ID) experiences a service disruption
- An admin account is compromised and blocked

Without break-glass accounts, a misconfigured CA policy can lock EVERYONE — including all Global Admins — out of the tenant. Recovery requires a Microsoft support case that can take days.

**This is not theoretical. It happens in production.**

---

## Design Requirements

### Account 1: BGA-001
- **UPN:** `bga001@[tenant].onmicrosoft.com` (cloud-only, never synced)
- **Display Name:** `BREAK GLASS 01 — DO NOT USE`
- **Account Type:** Cloud-only (never hybrid-synced)
- **Directory Role:** Global Administrator
- **MFA:** NONE — password authentication only
- **Password:** Minimum 48 characters, randomly generated, stored in physical safe
- **License:** None required (Global Admin works without a license)
- **Location:** Exclude from all CA policies

### Account 2: BGA-002
- Same design as BGA-001 but stored in a separate physical location
- Provides redundancy if BGA-001 credentials are lost or compromised

---

## Why Cloud-Only Matters

Break-glass accounts MUST be cloud-only (not synced from on-premises AD).

If a break-glass account is synced from on-premises:
- An on-premises AD outage or account lock prevents break-glass use
- The account inherits whatever CA policies or attribute issues caused the original problem
- It cannot be used to recover from a sync-related outage

Cloud-only accounts are independent of the on-premises infrastructure.

---

## Why No MFA

MFA on break-glass accounts creates a circular dependency:
- If MFA is required and the MFA device is unavailable → break-glass is useless
- If MFA is required and Entra ID is partially unavailable → MFA challenge may fail
- The entire purpose of break-glass is access when normal auth fails

**Mitigation:** The password length (48+ chars) and secure storage replace MFA as the security control.

---

## CA Policy Exclusion Requirements

```
For EVERY Conditional Access policy in the tenant:
  Users → Exclude → [Select both break-glass accounts]
```

This is the #1 item to verify before enabling any new CA policy.

**Verification PowerShell:**
```powershell
# List all CA policies and check for break-glass exclusions
Connect-MgGraph -Scopes "Policy.Read.All"
$policies = Get-MgIdentityConditionalAccessPolicy
foreach ($policy in $policies) {
    $exclusions = $policy.Conditions.Users.ExcludeUsers
    Write-Host "$($policy.DisplayName): Excluded users = $($exclusions -join ', ')"
}
```

---

## Monitoring and Alerting

Any use of a break-glass account is either:
1. A legitimate emergency
2. Unauthorized access — treat as a critical incident

**Required alert:** Configure a Log Analytics / Microsoft Sentinel rule (or Entra ID diagnostic setting) to alert immediately when either break-glass account signs in.

```
Alert Name: CRITICAL — Break-Glass Account Sign-In
Trigger: Any successful sign-in from bga001@ or bga002@
Notify: Security team, IT Manager — immediate (SMS + email)
```

---

## Operational Procedures

| Scenario | Procedure |
|---|---|
| CA policy locked out all admins | Break out the physical safe, retrieve BGA-001 credentials, sign in, fix the CA policy |
| MFA device lost/stolen for all admins | Use break-glass to disable the CA policy requiring MFA, recover admin accounts |
| Entra ID partial outage | Use break-glass to access tenant management, assess scope, contact Microsoft support |
| After break-glass use | Rotate the password, re-seal the new password, investigate and document the incident |

---

## Password Management

- Passwords are generated using a password manager or `[System.Web.Security.Membership]::GeneratePassword(48, 12)` in PowerShell
- Printed and stored in a sealed envelope in a physical safe
- A second copy stored in an offline, air-gapped password manager (not cloud-synced)
- Passwords rotated after any use and annually at minimum
- Access to the physical safe requires two-person authorization

---

## Zero Trust Alignment

- **Assume breach:** Break-glass use is treated as a potential security event regardless of context
- **Verify explicitly:** Monitoring ensures any break-glass sign-in is immediately visible
- **Least privilege:** Break-glass accounts have no licenses, no day-to-day access, and exist solely for emergency use

---

## SC-300 Concepts Reinforced

- Emergency access account design
- Conditional Access exclusion management
- Cloud-only vs hybrid account considerations
- Monitoring for privileged account activity
- Zero Trust break-glass architecture

---

## Resume Bullet

> Designed a dual break-glass account architecture for an Entra ID tenant, including cloud-only account requirements, CA policy exclusion verification, physical credential storage procedures, and automated alerting on any emergency access sign-in — preventing potential tenant lockout from CA policy misconfiguration.
