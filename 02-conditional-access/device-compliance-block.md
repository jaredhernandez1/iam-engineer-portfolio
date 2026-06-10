# Conditional Access — Device Compliance Block Investigation

**Portfolio Folder:** `02-conditional-access/`  
**Artifact Type:** Incident Root Cause Analysis  
**Environment:** Production (Sanitized) — MSP Client, GCC High  
**Ticket Reference:** [Sanitized — AVD access failure, unmanaged Mac]  
**Status:** ✅ Resolved  

---

## Purpose

Document the diagnosis and resolution of an Azure Virtual Desktop access failure caused by a Conditional Access policy requiring device compliance — where the user was authenticating from a personal, unmanaged Mac. Serves as a model for future CA-related access block investigations.

---

## Business Context

A user at a client organization was unable to access Azure Virtual Desktop (AVD) from their personal Mac. They had recently been forced to reset their password and had not yet completed the reset on a managed corporate device. The user was remote and had no managed device immediately available.

---

## Problem

User could not authenticate to AVD. Sign-in was blocked. Error message was generic ("You can't get there from here" or "Device doesn't meet requirements"). User believed it was related to their recent password change.

---

## Tools Used

- Entra Admin Center — Sign-in logs
- Entra Admin Center — Conditional Access policies
- Entra Admin Center — CA What-If tool
- Microsoft Intune Admin Center — Device compliance
- GCC High Admin Portal (`.azure.us` workspace URL)

---

## Skills Demonstrated

- Reading and interpreting Entra ID sign-in logs
- Identifying CA policy as the root cause of an access failure
- Understanding device compliance requirements in CA
- Distinguishing between managed and unmanaged device states
- Communicating CA block reasons to non-technical users
- Using the CA What-If tool to validate policy logic

---

## Technical Walkthrough

### Step 1 — Review Sign-In Logs

Pulled sign-in logs in Entra Admin Center filtered by the affected user and the timeframe of the failure.

Located the failed sign-in entry. Under the **Conditional Access** tab of the sign-in log entry:
- Policy status: **Failure**
- Grant controls not satisfied: **Require device to be marked as compliant**
- Device: Unmanaged (not Intune-enrolled)
- Platform: macOS

### Step 2 — Identify the Blocking Policy

The specific CA policy targeting AVD had a grant control requiring **Device Compliance**. The user's personal Mac was not enrolled in Intune, so it was not compliant.

**Policy logic:**
```
IF user = [Client Users]
AND app = Azure Virtual Desktop
THEN require: Device marked as compliant
```

Because the Mac was unmanaged, it could not satisfy the compliance requirement — full stop.

### Step 3 — Understand Why the Password Reset Made It Worse

The user had been forced to reset their password. On a managed Windows device, the password reset would have been smooth. On an unmanaged Mac:
1. The password reset completed (cloud-side)
2. The user then tried to access AVD from the same unmanaged Mac
3. The CA compliance policy blocked the session before authentication could succeed with the new password

The user incorrectly concluded the password reset broke their access. The CA policy was the actual blocker — it would have blocked the Mac regardless of whether a password reset occurred.

### Step 4 — Communicate the Root Cause

Explained to the user:
- Their password reset was successful
- Their account was fine
- The block was caused by a security policy requiring a managed, corporate device
- The Mac they were using was personal and not enrolled in the company's device management system
- Resolution required access from a managed device or temporary policy exception (admin decision)

### Step 5 — Resolution Path

Options presented to client admin:
1. **User accesses from a managed corporate device** (recommended — maintain security posture)
2. **Temporary named location exclusion** for the user (break-glass style — document and time-limit)
3. **Enroll the Mac in Intune and establish compliance** (longer path — appropriate for permanent remote work from Mac)

Client chose Option 1. User was directed to a managed device and gained access immediately.

---

## CA What-If Validation

Used the Entra CA What-If tool to confirm which policy would fire for this scenario:

- User: [affected user]
- App: Azure Virtual Desktop
- Device Platform: macOS
- Device: Unmanaged

Result: Policy correctly identified as the blocking control. Confirmed behavior was expected, not a misconfiguration.

---

## Key Decisions

- Did not modify the CA policy. The policy was working as designed to protect AVD.
- Educated the user on why the block existed rather than treating it as an error.
- Documented the scenario as a pattern for future similar tickets.

---

## Security Considerations

- CA compliance policies on AVD protect the organization from unmanaged devices accessing sensitive virtual desktop environments. They should not be bypassed without documented justification and time limits.
- Any temporary exclusion should use a named location, not a user exclusion, to maintain audit trail hygiene.
- In GCC High, AVD workspace URLs use `.azure.us` — confirm the correct URL is being tested before diagnosing a CA block.

---

## Zero Trust Alignment

- **Verify explicitly:** CA policy enforced device health as an authentication signal — exactly the Zero Trust model. Unverified device = no access.
- **Assume breach:** Requiring managed device compliance prevents credential-only attacks from personal or compromised endpoints.

---

## SC-300 Concepts Reinforced

- Conditional Access grant controls (device compliance)
- Sign-in log analysis for CA-related failures
- CA What-If tool usage
- Device identity and Intune compliance integration
- Entra ID authentication signals (device state)

---

## Business Value

Resolved a critical remote access block, identified the true root cause (preventing further misdiagnosis), and educated the client on the compliance requirement. Avoided an unnecessary and risky CA policy modification that would have weakened the organization's security posture.

---

## Screenshots to Include

- [ ] Sign-in log entry showing the CA failure and grant control details
- [ ] CA policy configuration (sanitized — show compliance requirement, remove org-specific names)
- [ ] CA What-If tool showing the policy match result

---

## Lessons Learned

1. **"I can't get there from here" errors are almost always CA.** Check sign-in logs and filter the CA tab before doing anything else.
2. **Password resets and CA blocks are often confused.** Users experience them simultaneously. Separate the two in your diagnosis.
3. **GCC High AVD uses `.azure.us` workspace URLs.** If the user is navigating to a `.azure.com` URL, that's a separate issue entirely.
4. **CA What-If tool is non-negotiable** before modifying any policy. Always validate behavior before touching a live policy.

---

## Resume Bullet

> Diagnosed an Azure Virtual Desktop access failure in a GCC High environment by identifying a Conditional Access device compliance block on an unmanaged personal Mac; used Entra sign-in logs and the CA What-If tool to confirm root cause, preserved the security policy, and guided the user to a managed-device resolution path.
