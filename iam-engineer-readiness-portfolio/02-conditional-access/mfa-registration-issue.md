# MFA Registration Block — New User Enrollment Investigation

**Portfolio Folder:** `02-conditional-access/`  
**Artifact Type:** Incident Pattern + Runbook  
**Environment:** Lab + Production patterns  
**Status:** 📝 Template — populate with real or simulated ticket  

---

## Problem Pattern

New users (or users whose MFA registration was reset) are unable to complete MFA registration. They hit a block during the combined security info registration flow. Root cause is typically one of three things:

1. A CA policy requires MFA before allowing access to the MFA registration portal — creating a chicken-and-egg deadlock
2. The user's Authentication Methods policy does not permit the registration method they're attempting
3. A Temporary Access Pass (TAP) was not issued and the user has no way to bootstrap registration

---

## Diagnosis Steps

### Step 1 — Check sign-in logs during the failed registration

Look for the failed session. Under the CA tab, identify which policy is applying grant controls.

If a policy requires MFA to access `Microsoft Account Management` (the registration endpoint), and the user has no MFA method registered — that's the deadlock.

### Step 2 — Check Authentication Methods Policy

`Entra Admin Center → Protection → Authentication methods → Policies`

Confirm:
- Is the intended registration method (Authenticator app, SMS, FIDO2, etc.) enabled for this user?
- Is TAP enabled for bootstrapping new users?

### Step 3 — Issue a Temporary Access Pass (TAP)

TAP is the correct answer to this problem in modern Entra ID. It allows a user to bypass MFA for a defined time window to complete registration.

```
Entra Admin Center → Users → [User] → Authentication methods → + Add authentication method → Temporary Access Pass
```

Configure:
- Lifetime: 60–240 minutes (use-once is safest)
- One-time use: Yes (prevents reuse after registration)

Provide the TAP to the user through a secure out-of-band channel (not email to the same account that's locked).

### Step 4 — User completes registration

User signs in with their UPN + TAP (no MFA challenge).
User is directed to `aka.ms/mysecurityinfo` to register their MFA method.
User registers Authenticator app or other method.
TAP is consumed or expires.

---

## CA Policy Design Consideration

To prevent this deadlock permanently, create a CA policy specifically for the MFA registration endpoint:

```
Policy: Allow MFA Registration — Unregistered Users
Target App: Microsoft Account Management
Target Users: Users who are members of [New Users] group (or all users)
Conditions: None (or Named Location if on-site)
Grant: Require TAP (or: block if no method, require TAP to bootstrap)
```

The Microsoft recommended approach is to scope this policy to a specific group of onboarding users and remove them from the group after registration is complete.

---

## SC-300 Concepts Reinforced

- Authentication methods policy
- Temporary Access Pass (TAP) provisioning
- MFA registration deadlock diagnosis
- Combined security info registration (`mysecurityinfo`)
- CA policy targeting for the registration endpoint

---

## Resume Bullet

> Diagnosed and resolved MFA registration deadlocks caused by Conditional Access policy conflicts during new user onboarding; implemented a Temporary Access Pass (TAP) provisioning workflow and documented CA policy design to prevent recurring registration blocks.
