# IAM Accomplishments — Resume Bullets

**Purpose:** Ready-to-use resume bullets generated from portfolio work. Each bullet follows the format: Action verb + Technical scope + Business/security outcome + Tooling + Observable impact.

**Update this file after every 2–3 completed artifacts.**

---

## Hybrid Identity

> Diagnosed and resolved an external email delivery failure in a Microsoft 365 GCC High tenant caused by a missing `.onmicrosoft.us` proxy address on a synced Active Directory user; remediated at the on-premises source, initiated a targeted Entra Connect delta sync, and restored mail flow within 15 minutes.

> Built and documented a layered hybrid identity troubleshooting runbook for Entra Connect Sync environments, covering OU filtering, attribute flow errors, connector space validation, and delta/full sync operations across lab and production GCC High scenarios.

> Developed a PowerShell script (`audit-proxyaddresses.ps1`) to proactively audit proxy address configurations across all mail-enabled AD users, identifying missing tenant routing addresses, duplicate primary SMTP designations, and UPN/mail mismatches — enabling proactive remediation before mail delivery failures occur.

---

## Conditional Access

> Diagnosed an Azure Virtual Desktop access failure in a GCC High environment by identifying a Conditional Access device compliance block on an unmanaged personal Mac; used Entra sign-in logs and the CA What-If tool to confirm root cause, preserved the security policy, and guided the user to a managed-device resolution path.

> Designed a tiered Conditional Access policy baseline following Zero Trust principles, including MFA for all users, phishing-resistant MFA for privileged roles, device compliance enforcement, legacy authentication blocking, and risk-based controls — with documented build order and break-glass exclusion validation.

> Developed and documented a scoped CA policy testing methodology using Report-Only mode and the CA What-If tool, enabling safe policy validation in production environments before enablement.

---

## Security Investigation

> Built a structured risky sign-in triage runbook for Entra Identity Protection alerts, covering detection type classification, sign-in log cross-reference, out-of-band user verification, and graduated remediation from MFA re-registration through session revocation and sign-in block.

> Developed a compromised account response playbook with Phase 1 containment (sign-in block, session revocation, password reset, MFA method wipe) executable within 15 minutes of confirmed compromise, plus scope assessment and full remediation procedures.

---

## Identity Governance

> Designed a complete Joiner/Mover/Leaver (JML) identity lifecycle framework mapping each lifecycle event to automated provisioning steps, Entra Entitlement Management workflows, and Graph API session revocation — targeting same-day leaver execution and sub-2-hour joiner provisioning.

> Designed a recurring access review framework for contractor and B2B guest accounts using Entra ID Governance, with monthly review cycles, 14-day auto-deny on non-response, and lifecycle policies covering account creation through automated offboarding.

---

## Privileged Access

> Designed a Privileged Identity Management (PIM) tiered role model eliminating standing privilege for all human admin accounts, with activation requirements scaled by role sensitivity — ranging from self-service MFA for reader roles to two-person approval with written justification for Global Administrator.

---

## Device Identity

> Diagnosed and resolved an Intune MDM enrollment loop (Event 52 NULL fault) caused by a missing Intune license assignment, restoring device management capability and documenting the resolution pattern for recurrence prevention.

> Diagnosed a JAMF MDM enrollment failure caused by an unapproved MDM management profile; coordinated device record deletion, fresh enrollment invitation, and documented the JAMF-specific approval requirement to prevent repeat occurrences.

---

## Automation

> Built a PowerShell hybrid user health check script (`check-hybrid-user-health.ps1`) combining Active Directory attribute inspection with Microsoft Graph sign-in data to validate UPN routing, proxy address completeness, sync state, license assignment, and sign-in activity in a single diagnostic run.

> Developed a stale user reporting script combining Active Directory last logon and Entra ID sign-in activity with license assignment data, categorizing users into four staleness tiers and generating actionable remediation recommendations — enabling license reclamation and access hygiene at scale.

---

## GCC High / Federal Identity

> Accumulated daily hands-on experience administering Microsoft 365 GCC High tenants for DoD contractor organizations, developing expertise in GCC High-specific identity patterns including `.onmicrosoft.us` routing, `.azure.us` workspace URLs, Classic Outlook requirements, and federal compliance posture differences from commercial M365.

---

## Bullet Bank — To Be Built

*These bullets will be created as the corresponding portfolio work is completed:*

- [ ] CA policy design: phishing-resistant MFA enforcement for admin roles
- [ ] PIM: first PIM role activation with audit trail documentation
- [ ] Access package: first entitlement management package built and tested
- [ ] JML pipeline: PowerShell automation for user provisioning
- [ ] Zero Trust design: GCC High reference architecture document
- [ ] SC-300 pass (when complete)
