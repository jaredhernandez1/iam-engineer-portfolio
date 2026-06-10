# Risky Sign-In Investigation — Identity Protection Triage Runbook

**Portfolio Folder:** `04-security-investigations/`  
**Artifact Type:** Investigation Runbook  
**Environment:** Lab (Meridian Consulting Group) — production patterns  
**Status:** 📝 Template — populate with simulated or production ticket  

---

## Purpose

A structured runbook for triaging risky sign-in alerts from Entra ID Identity Protection. Every risky sign-in should be worked through this process before deciding to dismiss, remediate, or escalate.

---

## Identity Protection Risk Levels

| Risk Level | What It Means | Required Action |
|---|---|---|
| Low | Unusual but not necessarily malicious | Review if pattern continues |
| Medium | Moderate confidence of compromise | Investigate; consider requiring MFA re-verification |
| High | High confidence of compromise | Block or force password reset immediately |

---

## Triage Steps

### Step 1 — Open the alert in Entra Identity Protection

`Entra Admin Center → Protection → Identity Protection → Risky sign-ins`

Filter by: Risk level (High first), Date range

For the alert in question, review:
- User affected
- Risk level
- Risk detection type (see below)
- Sign-in location and IP
- App accessed
- Sign-in time

---

### Step 2 — Identify the Risk Detection Type

| Detection Type | What It Means | Typical Response |
|---|---|---|
| Anonymous IP address | Sign-in from Tor, VPN, proxy | High suspicion — verify with user |
| Unfamiliar sign-in properties | New device, new location, new IP | Confirm with user |
| Atypical travel | Two sign-ins from geographically impossible locations | Block + investigate |
| Malware-linked IP | IP associated with known botnet | Block immediately |
| Password spray | Multiple failed logins across accounts | Investigate scope — may be org-wide attack |
| Leaked credentials | Credentials found in breach database | Force password reset immediately |
| AI-generated risk | Microsoft's ML flagged anomalous behavior | Context-dependent |

---

### Step 3 — Cross-Reference with Sign-In Logs

`Entra Admin Center → Monitoring → Sign-in logs`

Filter by the affected user for the same time window.

Look for:
- Multiple failed attempts before a success
- Access to sensitive apps (SharePoint admin, Azure portal, Exchange admin)
- Session duration anomalies
- Multiple simultaneous sessions from different locations

---

### Step 4 — Contact the User (For medium/low risk)

Out-of-band verification: call the user directly (not email — the account may be compromised).

Questions:
1. Were you signing in from [location] at [time]?
2. Were you using [device/browser]?
3. Have you noticed any unusual account activity?

If user confirms: dismiss the risk, document confirmation.  
If user cannot confirm: treat as high risk, proceed to Step 5.

---

### Step 5 — Remediation Actions (For high risk or unconfirmed)

**Option A — Require MFA re-registration (if credential compromise suspected):**
```
Entra Admin Center → Users → [User] → Authentication methods → Require re-register MFA
```

**Option B — Force password reset:**
```
Entra Admin Center → Users → [User] → Reset password
```

**Option C — Revoke all active sessions (immediate containment):**
```powershell
# Via Microsoft Graph
Revoke-MgUserSignInSession -UserId "[user-object-id]"
```
Or via portal: `Users → [User] → Revoke sessions`

**Option D — Block sign-in (most severe — for confirmed compromise):**
```
Entra Admin Center → Users → [User] → Block sign-in → Yes
```

---

### Step 6 — Document the Investigation

Record in the ticket:
- Alert type and risk level
- Detection type
- Sign-in details reviewed
- User contact outcome
- Remediation action taken
- Rationale for dismissal or escalation
- Time from alert to resolution

---

### Step 7 — Dismiss or Confirm Risk

After remediation:
- If false positive (confirmed by user): `Risky sign-ins → [entry] → Dismiss`
- If confirmed compromise: `Risky users → [user] → Confirm compromise`

Confirming compromise feeds back into Microsoft's risk models and improves future detections.

---

## Risk Policy Design (Proactive Controls)

Rather than triaging every alert manually, configure risk policies to automate responses:

**User risk policy:**
- Trigger: User risk = High
- Action: Require password change (with MFA)

**Sign-in risk policy:**
- Trigger: Sign-in risk = High
- Action: Block OR require MFA

These policies enforce Zero Trust continuously without manual triage for every event.

---

## SC-300 Concepts Reinforced

- Entra ID Identity Protection
- Risky sign-in detection types
- Risky user remediation
- Session revocation via Graph API
- Risk policy configuration
- Risk-based Conditional Access

---

## Resume Bullet

> Built a structured risky sign-in triage runbook for Entra ID Identity Protection alerts, covering detection type interpretation, cross-reference with sign-in logs, out-of-band user verification, and graduated remediation actions from MFA re-registration through session revocation and sign-in block.
