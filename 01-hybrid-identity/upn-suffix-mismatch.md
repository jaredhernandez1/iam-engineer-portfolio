# UPN Suffix Mismatch — Synced User Authentication Failure

**Portfolio Folder:** `01-hybrid-identity/`  
**Artifact Type:** Root Cause Analysis + Remediation Guide  
**Environment:** Lab (Meridian Consulting Group) — applicable to production  
**Status:** 📝 Template — populate with INC-2847 findings  

---

## Purpose

Document the diagnosis and resolution of authentication failures caused by UPN suffix mismatches in hybrid identity environments — one of the most common root causes of "user can't sign in" tickets in Entra Connect deployments.

---

## Problem Pattern

A synced user exists in both Active Directory and Entra ID but cannot authenticate to Microsoft 365 or Azure services. Sign-in logs show a failure. The user's on-premises UPN uses a suffix that is either:
1. Not verified in Entra ID (e.g., `user@mcglab.local`)
2. Different from the UPN Entra Connect is configured to use
3. Correct but routed to the wrong tenant (rare in multi-tenant MSP environments)

---

## Why This Happens

In hybrid environments, Entra Connect syncs the on-premises `userPrincipalName` attribute to Entra ID. If the domain suffix in that UPN (e.g., `@mcglab.local`) is not a verified custom domain in Entra ID, Entra Connect substitutes the `.onmicrosoft.com` (or `.onmicrosoft.us` for GCC High) domain instead.

This substitution causes a mismatch between what the user types and what Entra ID expects — especially if the user was told to sign in with their AD username.

---

## Environment

- **On-Premises AD:** `mcglab.local` (non-routable internal domain — cannot be verified in Entra ID)
- **Entra ID Tenant:** `[lab-tenant].onmicrosoft.com`
- **Verified Domains:** `[lab-tenant].onmicrosoft.com` only (no custom domain yet in lab)
- **Sync Method:** Entra Connect with PHS

---

## Diagnosis Steps

### Step 1 — Check the user's UPN in Active Directory

```powershell
Get-ADUser -Identity "jsmith" -Properties UserPrincipalName | Select-Object UserPrincipalName
# Expected output example: jsmith@mcglab.local
```

### Step 2 — Check what Entra Connect synced to Entra ID

In Entra Admin Center → Users → [Affected User] → Properties:
- Check the `User principal name` field
- If it shows `jsmith@[tenant].onmicrosoft.com`, Entra Connect substituted the UPN because `mcglab.local` is unverifiable

### Step 3 — Confirm the sign-in failure in Entra ID logs

Entra Admin Center → Monitoring → Sign-in logs → filter by user  
Look for: `User account not found in the directory` or `Invalid username or password`

If the user is trying to sign in as `jsmith@mcglab.local` but their Entra UPN is `jsmith@[tenant].onmicrosoft.com`, authentication will fail every time.

---

## Remediation Options

### Option A — Add and verify a routable custom domain (Recommended for production)

1. Purchase or use an existing routable domain (e.g., `meridian-consulting.com`)
2. Add the domain in Entra Admin Center → Custom domain names
3. Add the DNS TXT verification record at your registrar
4. Verify the domain in Entra ID
5. Update users' UPNs in AD to use the new suffix:

```powershell
# Update a single user's UPN in AD
Set-ADUser -Identity "jsmith" -UserPrincipalName "jsmith@meridian-consulting.com"

# Bulk update all users in an OU
Get-ADUser -Filter * -SearchBase "OU=Users,DC=mcglab,DC=local" |
    ForEach-Object {
        $newUPN = $_.SamAccountName + "@meridian-consulting.com"
        Set-ADUser $_ -UserPrincipalName $newUPN
    }
```

6. Run a delta sync to push updated UPNs to Entra ID:

```powershell
Start-ADSyncSyncCycle -PolicyType Delta
```

---

### Option B — Configure Entra Connect Alternate Login ID (For non-routable domains)

If the domain cannot be changed, configure Alternate Login ID so users can sign in with their `mail` attribute instead of their UPN.

In Entra Connect configuration wizard → Optional features → Alternate Login ID → select the `mail` attribute.

> **Trade-off:** Some applications and protocols do not support Alternate Login ID. Test thoroughly before deploying.

---

### Option C — Communicate the correct sign-in UPN to the user

If neither option A nor B is immediately actionable, inform the user of their actual Entra UPN:

- What they have in AD: `jsmith@mcglab.local`
- What Entra ID assigned: `jsmith@[tenant].onmicrosoft.com`
- What they should use to sign in: `jsmith@[tenant].onmicrosoft.com`

This is a stopgap, not a solution.

---

## Key Decisions

- **Option A is always preferred** for production environments — routable UPNs provide a consistent, user-friendly sign-in experience and avoid Alternate Login ID compatibility limitations.
- **In a lab with a `.local` domain**, Option B or C is typical because purchasing a domain is outside lab scope.

---

## Security Considerations

- UPN changes can affect MFA registrations, SSPR configurations, and app sign-in if users have registered with their old UPN. Communicate changes before executing.
- In GCC High, verify custom domains against the Government portal, not the commercial portal.

---

## SC-300 Concepts Reinforced

- Custom domain verification in Entra ID
- Entra Connect UPN attribute flow
- Alternate Login ID configuration
- Sign-in log analysis for authentication failures
- Hybrid identity sign-in flow

---

## Resume Bullet

> Diagnosed and documented authentication failures caused by non-routable UPN suffixes in hybrid Entra Connect environments; built a remediation playbook covering custom domain verification, bulk UPN updates via PowerShell, and Alternate Login ID configuration.
