# ProxyAddress Remediation — Email Delivery Failure for Synced User

**Portfolio Folder:** `01-hybrid-identity/`  
**Artifact Type:** Incident Root Cause Analysis + Remediation Runbook  
**Environment:** Production (Sanitized) — MSP Client, GCC High  
**Ticket Reference:** [Sanitized — internal reference removed]  
**Status:** ✅ Resolved  

---

## Purpose

Document the investigation and resolution of an email delivery failure caused by a missing `.onmicrosoft.us` proxy address on a synced user object. Serves as a repeatable runbook for similar hybrid identity/Exchange Online scenarios in GCC High environments.

---

## Business Context

Client operates in a Microsoft 365 GCC High environment with on-premises Active Directory synced to Entra ID via Entra Connect. All mailboxes are hosted in Exchange Online (GCC High). The affected user was unable to receive external email, blocking a business-critical communication channel.

---

## Problem

A user at the client organization stopped receiving external email. Internal mail routed successfully. External senders received either NDRs or silent delivery failures.

---

## Environment

- **Platform:** Microsoft 365 GCC High
- **Identity Source:** On-premises Active Directory → Entra Connect Sync → Entra ID
- **Exchange:** Exchange Online (GCC High)
- **Affected Object Type:** Synced (hybrid) user with cloud mailbox

---

## Tools Used

- Microsoft Entra Admin Center (Azure Government)
- Exchange Admin Center (GCC High)
- Active Directory Users and Computers (ADUC)
- Active Directory Module for PowerShell
- Entra Connect Sync (Azure AD Connect)
- Microsoft 365 Message Trace

---

## Skills Demonstrated

- Hybrid identity troubleshooting
- Exchange Online mail flow diagnosis
- proxyAddress attribute management in Active Directory
- Entra Connect Sync delta cycle initiation
- Root cause isolation in a hybrid environment
- GCC High-specific domain routing (.onmicrosoft.us vs .onmicrosoft.com)

---

## Technical Walkthrough

### Step 1 — Reproduce the Failure

Ran a message trace in Exchange Admin Center to confirm external messages were not being delivered. Internal messages succeeded. Confirmed the mailbox existed and was licensed.

### Step 2 — Inspect the User Object in Entra ID

Reviewed the user's profile in Entra Admin Center. Noted the user's email addresses listed under the account. The `.onmicrosoft.us` routing address was absent from the proxy address list.

**Expected proxy addresses for a GCC High user:**
```
SMTP:firstname.lastname@clientdomain.com       ← primary (uppercase = primary)
smtp:firstname.lastname@[tenant].onmicrosoft.us ← GCC High routing address (MISSING)
```

### Step 3 — Trace to Source (On-Premises AD)

Connected to the on-premises domain controller. Opened ADUC, located the user object, and inspected the `proxyAddresses` attribute via Attribute Editor.

Confirmed the `.onmicrosoft.us` address was not present in the on-premises `proxyAddresses` attribute. Because Entra Connect syncs this attribute from on-premises to cloud, the missing address was never populated in Exchange Online.

### Step 4 — Remediate in Active Directory

Added the missing proxy address directly to the user's `proxyAddresses` attribute in ADUC:

```
smtp:firstname.lastname@[tenant].onmicrosoft.us
```

> **Important:** In GCC High environments, the routing suffix is `.onmicrosoft.us`, not `.onmicrosoft.com`. Using the wrong suffix will not resolve the issue and may create a duplicate routing conflict.

### Step 5 — Force Entra Connect Sync Delta Cycle

After saving the change in AD, initiated a delta sync to push the change to Entra ID without waiting for the default 30-minute cycle:

```powershell
Start-ADSyncSyncCycle -PolicyType Delta
```

### Step 6 — Verify in Entra ID and Exchange Admin Center

Waited approximately 2–5 minutes post-sync. Confirmed the `.onmicrosoft.us` proxy address now appeared on the user object in Entra Admin Center. Verified in Exchange Admin Center that the email address was listed under the mailbox.

### Step 7 — Confirm Resolution

Sent a test message from an external address. Message delivered successfully. Ran a new message trace to confirm delivery.

---

## Key Decisions

- **Remediated at the source (on-premises AD) rather than cloud:** Changing the address in Entra directly would have been overwritten at the next sync cycle. Root cause must be fixed in the authoritative source.
- **Used delta sync rather than full sync:** Full sync would process all objects unnecessarily. Delta sync targeted only changed objects, reducing scope and risk.

---

## Security Considerations

- Changes to `proxyAddresses` directly affect mail routing and can introduce spoofing surface if incorrect addresses are added.
- Always confirm the target routing suffix matches the tenant's GCC High domain.
- Document changes with a before/after in the ticket before touching the attribute.

---

## Zero Trust Alignment

- **Verify explicitly:** Root cause investigation confirmed the identity's authoritative source was the problem — cloud appearance masked an on-prem misconfiguration.
- **Least privilege:** Remediation was performed by an admin with only the required scope (AD attribute editor access, Exchange admin).

---

## SC-300 Concepts Reinforced

- Hybrid identity attribute flow (on-premises → Entra Connect → Entra ID → Exchange Online)
- ProxyAddress attribute management in Active Directory
- Entra Connect Sync cycle management
- GCC High vs commercial tenant domain routing differences

---

## Business Value

Restored external email delivery for the affected user. Prevented continued business communication disruption. Created a repeatable runbook for future proxy address issues in GCC High environments — reducing resolution time for similar tickets from hours to minutes.

---

## Screenshots to Include

- [ ] ADUC Attribute Editor showing `proxyAddresses` before remediation (address missing)
- [ ] ADUC Attribute Editor after adding the `.onmicrosoft.us` address
- [ ] Entra Admin Center user profile showing proxy addresses post-sync
- [ ] Exchange Admin Center showing the mailbox email address list
- [ ] Message trace showing successful delivery post-fix

*Sanitize: Remove tenant name, user email, and any domain-identifying information from screenshots.*

---

## Lessons Learned

1. **GCC High uses `.onmicrosoft.us`**, not `.onmicrosoft.com`. This is a common source of confusion for admins coming from commercial environments.
2. **ProxyAddress is authoritative in on-prem AD** for synced users. Never fix it in the cloud if the user is hybrid — the sync will overwrite it.
3. **Message trace is the first tool** to reach for on delivery failures. It tells you exactly where the message stopped and why.
4. **Delta sync is your friend.** Don't make a change in AD and then sit waiting 30 minutes — force the delta and verify immediately.

---

## Future Improvements

- Build a PowerShell script to audit all synced users for missing `.onmicrosoft.us` proxy addresses (see `05-automation/audit-proxyaddresses.ps1`)
- Add this scenario to onboarding documentation for new MSP techs supporting GCC High clients
- Create a proactive health check that flags missing routing addresses before they cause delivery failures

---

## Resume Bullet

> Diagnosed and resolved an external email delivery failure for a GCC High tenant by identifying a missing `.onmicrosoft.us` proxy address on a synced Active Directory user object; remediated at the on-premises source and initiated a targeted Entra Connect delta sync, restoring mail flow within 15 minutes.
