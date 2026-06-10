# Conditional Access Baseline Design — Meridian Consulting Group

**Portfolio Folder:** `06-design-reviews/`  
**Artifact Type:** Architecture Design Document  
**Environment:** Lab (Meridian Consulting Group)  
**Status:** 📝 Design — to be built in lab  

---

## Purpose

Design a complete, defense-in-depth Conditional Access policy baseline for a mid-size organization. This is an architecture exercise, not a single policy — it covers the full policy set needed for a Zero Trust access foundation.

---

## Design Principles

1. **Start with break-glass.** Before building any policy, confirm emergency access accounts exist and are excluded from ALL policies.
2. **Report-Only first.** Every new policy goes through Report-Only validation before enabling.
3. **Least disruption path.** Design policies that enforce security without unnecessarily blocking legitimate workflows.
4. **Named exclusions over disabling.** Never disable a policy to fix a problem — add a scoped exclusion and investigate.

---

## Break-Glass Account Requirements (Non-Negotiable)

Before building ANY of the policies below:

- [ ] Two break-glass accounts created: `bga1@[tenant]` and `bga2@[tenant]`
- [ ] Both accounts: cloud-only (not synced), strong random password (vault-stored), no MFA registered
- [ ] Both accounts: explicitly excluded from EVERY CA policy
- [ ] Both accounts: monitored via alert rule for any sign-in activity
- [ ] Credentials stored in a physical safe AND a separate password manager from normal admin accounts

---

## Policy Baseline

### Tier 0 — Emergency and Exclusions

| Policy | State | Purpose |
|---|---|---|
| CA000 — Break-Glass Monitor Alert | On | Alert on any break-glass sign-in |

---

### Tier 1 — Require MFA for All Users

| Policy Name | CA001 — Require MFA for All Users |
|---|---|
| **Users** | All users |
| **Exclude** | Break-glass accounts, Emergency service accounts |
| **Apps** | All cloud apps |
| **Conditions** | None |
| **Grant** | Require MFA (authentication strength: Multifactor) |
| **Session** | None |
| **State** | Report-Only → On after validation |

**Rationale:** MFA is the single highest-value control in identity security. This is the foundation everything else builds on.

---

### Tier 2 — Protect Admin Roles

| Policy Name | CA002 — Require Phishing-Resistant MFA for Admins |
|---|---|
| **Users** | Directory roles: Global Admin, Privileged Role Admin, Security Admin, Conditional Access Admin |
| **Exclude** | Break-glass accounts |
| **Apps** | All cloud apps |
| **Conditions** | None |
| **Grant** | Require authentication strength: Phishing-resistant MFA (FIDO2 / Windows Hello for Business) |
| **Session** | Sign-in frequency: 4 hours, No persistent browser session |
| **State** | Report-Only → On after validation |

**Rationale:** Admin accounts are the highest-value targets. Phishing-resistant MFA (not just TOTP) is required.

---

### Tier 3 — Device Compliance

| Policy Name | CA003 — Require Compliant or Hybrid-Joined Device |
|---|---|
| **Users** | All users |
| **Exclude** | Break-glass, Guest/B2B users (separate policy), Specific onboarding group |
| **Apps** | All cloud apps |
| **Conditions** | Platforms: Windows, macOS (not mobile — handled separately) |
| **Grant** | Require device to be marked as compliant OR Hybrid Azure AD joined |
| **State** | Report-Only → On after validation |

**Rationale:** Extends Zero Trust to the device. Prevents credential-only access from unmanaged endpoints.

---

### Tier 4 — Block Legacy Authentication

| Policy Name | CA004 — Block Legacy Authentication |
|---|---|
| **Users** | All users |
| **Apps** | All cloud apps |
| **Conditions** | Client apps: Exchange ActiveSync, Other clients (legacy auth protocols) |
| **Grant** | Block |
| **State** | Report-Only (monitor for impacted legacy clients) → On |

**Rationale:** Legacy auth protocols cannot satisfy MFA. Most credential spray attacks use legacy auth.

---

### Tier 5 — Guest / External User Controls

| Policy Name | CA005 — Require MFA for Guest Users |
|---|---|
| **Users** | All guest and external users |
| **Apps** | All cloud apps |
| **Grant** | Require MFA |
| **State** | On |

---

### Tier 6 — Risk-Based Policies

| Policy Name | CA006 — Block High Sign-In Risk |
|---|---|
| **Users** | All users (exclude break-glass) |
| **Apps** | All cloud apps |
| **Conditions** | Sign-in risk: High |
| **Grant** | Block |
| **State** | On (after Identity Protection is configured) |

| Policy Name | CA007 — Require Password Change on High User Risk |
|---|---|
| **Users** | All users (exclude break-glass) |
| **Apps** | All cloud apps |
| **Conditions** | User risk: High |
| **Grant** | Require password change (with MFA) |
| **State** | On |

---

## Implementation Order

Build and validate in this order (each must pass Report-Only before enabling the next):

```
1. Create break-glass accounts and confirm exclusions
2. CA004 — Block Legacy Auth (low disruption risk, high impact)
3. CA001 — Require MFA for All Users
4. CA005 — Require MFA for Guests
5. CA002 — Phishing-Resistant MFA for Admins
6. CA003 — Device Compliance (most disruptive — longest monitoring period)
7. CA006/007 — Risk-based policies (requires Identity Protection)
```

---

## Zero Trust Alignment

| ZT Principle | Policy |
|---|---|
| Verify explicitly (identity) | CA001 — MFA for all users |
| Verify explicitly (device) | CA003 — Device compliance |
| Verify explicitly (risk) | CA006/007 — Risk-based |
| Least privilege access | CA002 — Admin-specific controls |
| Assume breach | CA004 — Block legacy auth; CA006 — Block high risk |

---

## SC-300 Concepts Reinforced

- CA policy design and architecture
- Authentication strength requirements (phishing-resistant MFA)
- Risk-based CA policies
- Legacy authentication blocking
- Break-glass account design
- CA policy implementation order

---

## Resume Bullet

> Designed a tiered Conditional Access policy baseline for a simulated enterprise environment following Zero Trust principles, covering MFA enforcement, phishing-resistant admin authentication, device compliance requirements, legacy auth blocking, and risk-based access controls — with documented implementation order and break-glass account exclusion requirements.
