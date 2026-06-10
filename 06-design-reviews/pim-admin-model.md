# Privileged Identity Management (PIM) Admin Model Design

**Portfolio Folder:** `06-design-reviews/`  
**Artifact Type:** Architecture Design Document  
**Environment:** Lab (Meridian Consulting Group)  
**Status:** 📝 Design — to be implemented in lab  

---

## Purpose

Design a Privileged Identity Management (PIM) model for Entra ID directory roles that enforces Just-In-Time (JIT) access, eliminates standing privilege, and creates a full audit trail for all privileged role activations.

---

## The Problem with Standing Privilege

Without PIM, a Global Administrator is a Global Administrator 24/7/365 — even when they're sleeping, on vacation, or compromised. This means:

- An attacker who compromises the account has unlimited time to operate with Global Admin rights
- There is no audit trail of when the admin actually needed the privilege vs when they just had it
- Accidental misuse is possible at any time (privilege always active)

PIM solves this by making privilege time-limited and request-gated.

---

## PIM Concepts

| Term | Definition |
|---|---|
| Eligible assignment | User can request to activate the role, but is not permanently assigned |
| Active assignment | User holds the role continuously (use sparingly — only for break-glass or service accounts) |
| Activation | Process of requesting to use an eligible role for a defined time window |
| Activation requirement | What's required to activate (MFA, justification, approval) |
| Maximum activation duration | How long the role is active after activation (1–24 hours) |
| Assignment duration | How long the eligible assignment lasts (1 day – permanent) |

---

## Role Tier Model

### Tier 0 — Critical (Never Permanent for Humans)

| Role | Assignment Type | Activation Requires | Max Duration | Approver |
|---|---|---|---|---|
| Global Administrator | Eligible only | MFA + written justification + approval | 4 hours | Two-person approval |
| Privileged Role Administrator | Eligible only | MFA + justification + approval | 4 hours | Global Admin or Privileged Role Admin |
| Conditional Access Administrator | Eligible only | MFA + justification | 4 hours | Security Admin |

**Permanent active exception:** Break-glass accounts only. No human should permanently hold any Tier 0 role.

---

### Tier 1 — High (Eligible, Self-Activate with MFA)

| Role | Assignment Type | Activation Requires | Max Duration |
|---|---|---|---|
| Security Administrator | Eligible | MFA + justification | 8 hours |
| Intune Administrator | Eligible | MFA + justification | 8 hours |
| Exchange Administrator | Eligible | MFA + justification | 8 hours |
| User Administrator | Eligible | MFA + justification | 8 hours |
| Groups Administrator | Eligible | MFA | 4 hours |

---

### Tier 2 — Moderate (Eligible, Self-Activate with MFA)

| Role | Assignment Type | Activation Requires | Max Duration |
|---|---|---|---|
| Security Reader | Eligible | MFA | 8 hours |
| Reports Reader | Eligible | MFA | 8 hours |
| Directory Readers | Eligible | MFA | 8 hours |

---

## Activation Workflow (Global Admin Example)

```
1. Admin navigates to: My Roles → Eligible assignments → Global Administrator
2. Clicks "Activate"
3. Provides justification text: "Deploying new CA policy for project X — ticket INC-XXXX"
4. MFA challenge presented and completed
5. Approval request sent to approvers (two-person approval)
6. Approvers review justification in PIM portal
7. Approved: Role activates for 4 hours
8. Admin completes work, deactivates role manually (or waits for expiry)
9. Full audit trail written to Entra audit log
```

---

## Alert and Monitoring Requirements

| Alert | Trigger | Notify |
|---|---|---|
| Global Admin activation | Any Global Admin PIM activation | Security team |
| Permanent active role assignment | Any new permanent active assignment to Tier 0/1 role | Security team |
| PIM role assignment change | Any change to eligible assignments | Security Admin |
| Activation outside business hours | Any role activation between 10pm–6am local time | Security team |

---

## Access Review Integration

All PIM eligible assignments should be reviewed quarterly:
- Reviewer: Privileged Role Administrator
- Scope: All eligible assignments across Tier 0 and Tier 1 roles
- Auto-deny on non-response after 14 days (for Tier 0)

---

## Zero Trust Alignment

- **Least privilege:** No standing privilege — roles granted only when needed
- **Verify explicitly:** MFA + justification required for every activation
- **Assume breach:** Time-limited activation minimizes blast radius if account is compromised

---

## SC-300 Concepts Reinforced

- PIM eligible vs active assignments
- JIT access model
- Activation requirements (MFA, justification, approval)
- PIM access reviews
- Privileged role monitoring and alerting
- Tier model for role classification

---

## Resume Bullet

> Designed a Privileged Identity Management (PIM) tiered role model eliminating standing privilege for all human admin accounts, with activation requirements scaled by role sensitivity — ranging from self-service MFA for reader roles to two-person approval with written justification for Global Administrator — and integrated quarterly access reviews for all eligible assignments.
