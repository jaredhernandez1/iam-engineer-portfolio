# Scoped Conditional Access Policy Testing — Methodology

**Portfolio Folder:** `02-conditional-access/`  
**Artifact Type:** Methodology + Lab Runbook  
**Environment:** Lab (Meridian Consulting Group)  
**Status:** 📝 Template — update with each CA policy tested  

---

## Purpose

A methodology for safely building, testing, and validating Conditional Access policies in a lab environment before any production deployment. Every CA policy touched in the portfolio should follow this process.

---

## The Golden Rule of CA Policy Work

> **Never test a CA policy change on yourself or on a production user.** Always test on a dedicated test account in Report-Only mode first. Breaking CA can lock everyone — including admins — out of a tenant.

---

## Pre-Testing Checklist

Before creating or modifying any CA policy:

- [ ] Emergency access (break-glass) accounts are confirmed excluded from ALL CA policies
- [ ] Test user account is created and scoped (not an admin account)
- [ ] Policy will be created in **Report-Only** mode first
- [ ] CA What-If tool is available and will be used to validate before enabling

---

## Break-Glass Account Verification (ALWAYS First)

```
Entra Admin Center → Identity → Protection → Conditional Access → Named Locations
                   → Policies → [Each policy] → Users → Exclusions
```

Confirm at least one break-glass account is explicitly excluded from every policy. If not: **STOP. Fix this before proceeding.**

---

## Testing Process

### Phase 1 — Design

Document the policy intent before building anything:

| Field | Value |
|---|---|
| Policy Name | [Policy Name] |
| Target Users | [Who is in scope] |
| Target Apps | [Which applications] |
| Conditions | [Platform, location, device state, sign-in risk] |
| Grant Controls | [MFA, compliant device, approved app, etc.] |
| Session Controls | [Sign-in frequency, app enforced restrictions, etc.] |
| Exclusions | [Break-glass, service accounts, test users] |
| Report-Only First? | Yes |

---

### Phase 2 — Build in Report-Only Mode

Create the policy exactly as designed but set it to **Report-Only** (not On, not Off).

Report-Only allows the policy to evaluate every sign-in without actually enforcing it. Sign-in logs will show whether the policy would have granted or blocked the session.

---

### Phase 3 — Validate with CA What-If

Use the What-If tool before and after enabling Report-Only:

`Entra Admin Center → Protection → Conditional Access → What If`

Test scenarios:
- Expected allow case (target user, target app, compliant device)
- Expected block case (target user, target app, non-compliant device)
- Break-glass case (break-glass account should show: excluded from policy)
- Admin account case (admins should not be unexpectedly blocked)

---

### Phase 4 — Monitor in Report-Only (Minimum 24 hours in production; immediate in lab)

Review sign-in logs while policy is in Report-Only:

`Entra Admin Center → Monitoring → Sign-in logs → [entry] → Conditional Access tab`

Look for:
- `Report-only: Would have granted` — user would pass
- `Report-only: Would have blocked` — user would be blocked
- Unexpected results that don't match the design intent

---

### Phase 5 — Enable

If Report-Only results match expectations: change policy state from **Report-Only** to **On**.

Monitor sign-in logs for the first 30 minutes after enabling for unexpected blocks.

---

## CA Decision Matrix Template

| Scenario | Expected Policy Result | Actual Result | Match? | Notes |
|---|---|---|---|---|
| Target user, target app, compliant device | Grant (MFA satisfied) | | | |
| Target user, target app, non-compliant device | Block | | | |
| Target user, excluded app | Not Evaluated | | | |
| Excluded user (break-glass), target app | Not Evaluated | | | |
| Guest user, target app | [depends on policy scope] | | | |

---

## SC-300 Concepts Reinforced

- CA policy lifecycle (design → report-only → enable → monitor)
- CA What-If tool
- Grant vs session controls
- Break-glass account exclusions
- Sign-in log interpretation for CA decisions
- Report-Only mode usage

---

## Resume Bullet

> Designed and documented a scoped Conditional Access policy testing methodology using Report-Only mode and the CA What-If tool to safely validate policy behavior before production enablement, ensuring break-glass account exclusions and preventing inadvertent lockouts.
