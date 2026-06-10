# IAM Skills Matrix

**Last Updated:** June 2026  
**Rating Scale:** Novice → Developing → Capable → Strong → Role-Ready → Advanced  

> Ratings are honest. Do not inflate. Each rating requires documented evidence.

---

## Core IAM Domains

| Domain | Current Rating | Target (6mo) | Evidence | Gap |
|---|---|---|---|---|
| Hybrid Identity (Entra Connect, AD, PHS) | Developing | Strong | INC-2847 lab, proxyAddress remediation (production) | On-prem AD depth, ADFS |
| Entra ID Administration | Developing | Strong | Daily production work, GCC High tenants | Advanced user lifecycle, bulk ops |
| Conditional Access | Developing | Role-Ready | Jon Rannabargar AVD ticket (CA root cause) | Policy design from scratch, What-If mastery |
| MFA / Authentication Methods | Developing | Strong | MFA registration block diagnosis | Authentication strength policies, FIDO2 |
| Identity Governance | Novice | Capable | JML process design (in progress) | Entitlement management, access reviews hands-on |
| Privileged Access (PIM) | Novice | Capable | Design review planned | PIM activation flows, JIT access |
| Security Investigation | Developing | Strong | Defender XDR email investigation, JAMF/Intune triage | Identity Protection risky sign-in triage |
| Device Identity (Intune, JAMF) | Developing | Capable | Daniel Walker MDM loop, Stephen Malone JAMF (production) | Autopilot, compliance policy design |
| Exchange Identity Integration | Developing | Capable | Data Haven proxyAddress email delivery failure (production) | Hybrid Exchange, mail routing |
| PowerShell / Automation | Developing | Strong | Scripts in progress (05-automation/) | Microsoft Graph API, JML pipeline |
| Documentation | Capable | Strong | Portfolio artifacts, client-facing guides | Executive briefing format |
| Executive Communication | Developing | Capable | Manager review packets | Business value framing |
| Zero Trust Design | Novice | Capable | Design reviews planned | Architecture diagramming, GSA |
| Troubleshooting Methodology | Capable | Strong | Systematic triage across multiple client tickets | Speed, hypothesis discipline |

---

## Skill Evidence Requirements

To move from one level to the next, you need:

| From → To | Requirement |
|---|---|
| Novice → Developing | Can describe the concept; has attempted it in lab or guided scenario |
| Developing → Capable | Has independently resolved at least one real or simulated issue using this skill |
| Capable → Strong | Has multiple documented examples; can explain trade-offs and edge cases |
| Strong → Role-Ready | Can design, not just operate; can teach it; has automated or improved a process |
| Role-Ready → Advanced | Can architect, govern policy, and advise others |

---

## SC-300 Exam Domain Coverage

| SC-300 Domain | Weight | Current Coverage | Artifacts |
|---|---|---|---|
| Implement and manage user identities | 20–25% | Developing | Hybrid identity section |
| Implement authentication and access management | 25–30% | Developing | CA section |
| Implement access management for applications | 15–20% | Novice | To be built |
| Plan and implement identity governance | 20–25% | Novice | Governance section |

---

## Technical Skills Checklist

### Microsoft Entra ID
- [ ] Create, manage, and delete users and groups
- [ ] Configure UPN suffixes and custom domains
- [ ] Manage authentication methods policy
- [ ] Configure SSPR and combined registration
- [ ] Read and interpret sign-in logs
- [ ] Investigate risky users and risky sign-ins
- [ ] Configure emergency access (break-glass) accounts
- [ ] Manage Entra Connect Sync health and rules

### Active Directory (On-Premises)
- [ ] Navigate ADUC, manage OU structure
- [ ] Modify proxyAddresses and mail attributes
- [ ] Understand and modify GPOs affecting auth
- [ ] Diagnose replication issues
- [ ] Manage UPN suffixes in AD Domains and Trusts
- [ ] Use `Get-ADUser`, `Set-ADUser`, `Sync-ADObject`

### Conditional Access
- [ ] Build a CA policy from scratch targeting a test user
- [ ] Use What-If tool to predict policy behavior
- [ ] Test Named Locations and trusted IPs
- [ ] Test device compliance requirements
- [ ] Configure authentication strength requirements
- [ ] Design a CA baseline for an organization

### PowerShell / Microsoft Graph
- [ ] Connect to Entra ID via `Connect-MgGraph`
- [ ] Query users, groups, sign-in logs via Graph
- [ ] Report on stale users and licenses
- [ ] Audit proxyAddresses across mailbox users
- [ ] Check hybrid sync health for a specific user
- [ ] Export CA policy inventory

### Identity Governance
- [ ] Create an access package with approval workflow
- [ ] Run an access review and complete decisions
- [ ] Configure PIM for an Entra role
- [ ] Activate a PIM role and document the audit trail
- [ ] Design a JML process for a fictional org

---

## Weekly Update Log

| Week | Notable Progress | Gaps Surfaced |
|---|---|---|
| Week 1 (June 9, 2026) | Portfolio initialized; lab env built; INC-2847 broken state created | Need to complete INC-2847 RCA |
| Week 2 | | |
| Week 3 | | |
| Week 4 | | |
