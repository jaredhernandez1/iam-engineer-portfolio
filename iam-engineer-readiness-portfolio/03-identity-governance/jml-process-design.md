# JML Process Design — Joiner / Mover / Leaver for Meridian Consulting Group

**Portfolio Folder:** `03-identity-governance/`  
**Artifact Type:** Process Design Document  
**Environment:** Lab (Meridian Consulting Group) — applicable to production  
**Status:** 📝 Design draft — automation pipeline to follow in 05-automation/  

---

## Purpose

Design a complete Joiner / Mover / Leaver (JML) identity lifecycle process for a mid-size organization. This document captures the business logic, decision tree, and automation targets for each lifecycle event.

---

## Business Context

JML process failures are the #1 source of identity risk in most organizations:
- **Joiner gaps:** New employees start without access, losing productivity
- **Mover gaps:** Role changes don't update access, creating privilege accumulation
- **Leaver gaps:** Departed employees retain access, creating a security risk

A well-designed JML process eliminates manual steps, reduces provisioning delay, and ensures access is revoked completely and immediately on termination.

---

## Joiner Process

**Trigger:** New hire record created in HR system  

**Required Inputs:**
- Full legal name
- Department
- Manager
- Job title
- Start date
- Location (on-site / remote / hybrid)
- Work email preference (if applicable)

**Provisioning Steps:**

| Step | Action | Tool | Automatable? |
|---|---|---|---|
| 1 | Create AD user object in correct OU | Active Directory | Yes — PowerShell |
| 2 | Set UPN with routable suffix | Active Directory | Yes |
| 3 | Assign license (M365 / Defender) | Entra ID / Graph | Yes |
| 4 | Add to base security groups (All Employees, etc.) | Entra ID | Yes |
| 5 | Add to department-specific groups | Entra ID | Yes — group mapping |
| 6 | Assign access package (Entitlement Management) | Entra ID Governance | Semi-auto — approval workflow |
| 7 | Trigger Entra Connect delta sync | Entra Connect | Yes |
| 8 | Confirm cloud object created | Entra Admin Center | Yes — verification script |
| 9 | Issue Temporary Access Pass for MFA bootstrap | Entra ID | Yes — Graph API |
| 10 | Deliver TAP and credentials via secure channel | Secure comms | Manual |
| 11 | Notify manager when account is ready | Email / Teams | Yes |

**SLA Target:** Account ready within 2 hours of approved request  
**Automation Target:** Steps 1–9 fully automated via PowerShell + Graph API pipeline  

---

## Mover Process

**Trigger:** HR system update — department, manager, or title change  

**Required Inputs:**
- Current OU / group memberships
- New department / role
- Effective date

**Update Steps:**

| Step | Action | Automatable? |
|---|---|---|
| 1 | Move user object to new OU in AD | Yes |
| 2 | Remove old department group memberships | Yes — based on OU mapping |
| 3 | Add new department group memberships | Yes |
| 4 | Update access package assignment (remove old, add new) | Semi-auto — may require approval |
| 5 | Review privileged group memberships (PIM) | Manual — security review required |
| 6 | Update license if role requires different SKU | Yes |
| 7 | Notify new manager | Yes |
| 8 | Trigger delta sync | Yes |

**Key Risk:** Privilege accumulation — users who move roles without losing old access.  
**Mitigation:** Access reviews scheduled quarterly; Mover process removes previous role-based groups explicitly.

---

## Leaver Process

**Trigger:** Termination date in HR system (or immediate trigger for involuntary terminations)  

**Priority:** Leaver process is the most security-critical. Voluntary = planned. Involuntary = same-day execution required.

**Offboarding Steps:**

| Step | Action | Priority | Automatable? |
|---|---|---|---|
| 1 | Disable AD user account | IMMEDIATE | Yes |
| 2 | Revoke all active Entra ID sessions (force sign-out) | IMMEDIATE | Yes — Graph API |
| 3 | Block sign-in in Entra ID | IMMEDIATE | Yes |
| 4 | Remove from all security groups | Same day | Yes |
| 5 | Remove from all distribution groups | Same day | Yes |
| 6 | Convert mailbox to shared mailbox (if needed) | Same day | Semi-auto |
| 7 | Assign mailbox access to manager | Same day | Yes |
| 8 | Revoke all OAuth app consents | Same day | Yes — Graph API |
| 9 | Remove all active MFA and passwordless methods | Same day | Yes — Graph API |
| 10 | Remove all PIM role assignments | Same day | Yes |
| 11 | Revoke device enrollment (Intune) | Same day | Yes |
| 12 | Remove from all access packages | Same day | Yes |
| 13 | Remove license | 30 days (or immediate for cost control) | Yes |
| 14 | Disable/delete AD object (policy-dependent) | 30–90 days | Yes |
| 15 | Archive and delete cloud account | 90 days | Policy-dependent |

**SLA Target:** Steps 1–3 completed within 1 hour of termination trigger (involuntary: immediate)  
**Automation Target:** Steps 1–3 fully automated and triggered by HR system webhook or daily sync  

---

## Access Review Integration

- Access reviews run quarterly for all non-group-policy-driven group memberships
- Any user in a privileged role (Global Admin, Privileged Role Admin, etc.) is reviewed monthly via PIM
- Contractor accounts reviewed monthly regardless of role

---

## Automation Pipeline Design

**Phase 1 (Manual with PowerShell assists):**
- PowerShell scripts for each JML step
- Triggered manually by Help Desk from a runbook

**Phase 2 (Semi-automated):**
- PowerShell scripts run on schedule, reading from a CSV or HR export
- Notifications sent automatically; manual approval for sensitive steps

**Phase 3 (Fully automated):**
- Microsoft Graph API pipeline triggered by HR system event
- Approval workflows via Entra Entitlement Management
- Audit log written to SharePoint or Log Analytics

*Phase 1 automation scripts: see `05-automation/` section*

---

## SC-300 Concepts Reinforced

- Identity lifecycle management (Joiner/Mover/Leaver)
- Entitlement Management (access packages)
- Access reviews
- Session revocation via Graph API
- PIM role assignment management
- Governance-first approach to identity provisioning

---

## Resume Bullet

> Designed a complete Joiner / Mover / Leaver identity lifecycle framework for a simulated enterprise environment, mapping each lifecycle event to automated provisioning steps, Entra Entitlement Management workflows, and Graph API session revocation — targeting same-day leaver execution and fully automated joiner provisioning.
