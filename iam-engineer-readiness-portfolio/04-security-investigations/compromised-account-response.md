# Compromised Account Response — Incident Response Playbook

**Portfolio Folder:** `04-security-investigations/`  
**Artifact Type:** Incident Response Playbook  
**Environment:** Lab + Production patterns  
**Status:** 📝 Template  

---

## Purpose

A step-by-step response playbook for a confirmed or suspected account compromise. Designed to be executed quickly and in order. Speed matters — every minute a compromised account is active extends the attacker's window.

---

## Phase 1 — Immediate Containment (First 15 minutes)

**Do these in order. Do not skip steps.**

### Step 1.1 — Block sign-in immediately

```
Entra Admin Center → Users → [Compromised User] → Block sign-in → Yes
```

This prevents any new authentication. Active sessions may persist until revoked (next step).

### Step 1.2 — Revoke all active sessions

```powershell
Revoke-MgUserSignInSession -UserId "[user-object-id]"
```

Or via portal: `Users → [User] → Revoke sessions`

This kills all active tokens, forcing re-authentication (which will fail due to Step 1.1).

### Step 1.3 — Reset the password

```
Entra Admin Center → Users → [User] → Reset password → Auto-generate
```

Do not share the new password with anyone until the investigation is complete.

### Step 1.4 — Revoke MFA methods and require re-registration

```
Users → [User] → Authentication methods → Delete all methods → Require MFA re-registration
```

Attacker may have registered their own MFA device. Clearing methods removes attacker-controlled auth factors.

---

## Phase 2 — Scope Assessment (First hour)

### Step 2.1 — Review sign-in logs for the attack window

`Entra Admin Center → Monitoring → Sign-in logs → [Compromised user]`

Identify:
- When did unauthorized access begin?
- Which applications were accessed?
- Which IP addresses and locations were used?
- Were any admin portals accessed?

### Step 2.2 — Review audit logs for account changes

`Entra Admin Center → Monitoring → Audit logs → [Compromised user]`

Look for:
- Password changes
- MFA method registrations (did the attacker register their own MFA?)
- Role assignments (did the attacker escalate privileges?)
- App registrations or OAuth consents
- Group membership changes

### Step 2.3 — Review Defender XDR for malicious activity

`Defender XDR → Incidents → [Search by user or IP]`

Look for:
- Email forwarding rules (to attacker-controlled address)
- Business Email Compromise (BEC) patterns
- Data exfiltration indicators
- Lateral movement to other accounts

### Step 2.4 — Check for email forwarding rules

```powershell
# Connect to Exchange Online
Get-InboxRule -Mailbox "compromised.user@domain.com" | 
    Select-Object Name, ForwardTo, ForwardAsAttachmentTo, DeleteMessage, Enabled
```

If unauthorized forwarding rules exist: remove them immediately and document.

---

## Phase 3 — Remediation and Recovery (Hour 1–4)

### Step 3.1 — Remove unauthorized changes

- Delete any MFA methods the attacker registered
- Remove any unauthorized group memberships
- Revoke any OAuth app consents granted by the attacker
- Delete any email forwarding rules
- Remove any role assignments created by the attacker

### Step 3.2 — Unblock the account and restore access

Only after all cleanup is verified:
- Unblock sign-in
- Assist user with MFA re-registration via TAP
- Confirm user can authenticate with new password and MFA

### Step 3.3 — Review for lateral spread

If the compromised account had admin privileges or access to sensitive resources:
- Review sign-in logs for any accounts the attacker may have accessed
- Check for new accounts created during the attack window
- Review Defender XDR for lateral movement indicators

---

## Phase 4 — Documentation and Lessons Learned

### Required documentation:

- [ ] Timeline of attack (first unauthorized sign-in to containment)
- [ ] Applications and data accessed
- [ ] Changes made by attacker (email rules, roles, MFA methods)
- [ ] Remediation steps taken and timestamps
- [ ] Whether data was exfiltrated (confirm or unknown)
- [ ] Root cause (phishing? Password spray? Credential stuffing?)

### Lessons learned questions:

1. How did the attacker obtain credentials?
2. Was MFA enabled? If yes — did they bypass it (AiTM phishing)?
3. Were there any missed alerts that could have caught this earlier?
4. Did any CA policy limit the blast radius?
5. What would have prevented this?

---

## SC-300 Concepts Reinforced

- Incident response for compromised accounts
- Session revocation and sign-in block
- MFA method management
- Audit log and sign-in log forensics
- Exchange Online rule investigation
- Identity Protection risk confirmation

---

## Resume Bullet

> Developed a comprehensive compromised account response playbook covering immediate containment (sign-in block, session revocation, password reset, MFA wipe), scope assessment via Entra audit logs and Defender XDR, and full remediation and recovery steps — designed for execution within 15 minutes of confirmed compromise.
