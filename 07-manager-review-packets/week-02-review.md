# Manager Review Packet — Week 2

**Period:** June 9 – June 23, 2026  
**Prepared by:** Jared Hernandez  
**Audience:** Manager / Direct Supervisor  
**Format:** Informal 1:1 talking points — not a formal report  

---

## Executive Summary

Over the past two weeks, I've been systematically building the foundation for my transition into an IAM Analyst / IAM Engineer role. This involved setting up a hybrid identity lab environment that mirrors our production GCC High client scenarios, investigating an active simulated IAM incident (INC-2847), and documenting production tickets as portfolio artifacts.

The goal isn't just studying — it's building demonstrable evidence that I can operate in an IAM role today.

---

## Tickets Completed / Work Highlights

| Item | Type | Outcome |
|---|---|---|
| ProxyAddress email delivery failure | Production ticket (sanitized) | Resolved; runbook created |
| AVD access failure — CA compliance block | Production ticket (sanitized) | Resolved; RCA documented |
| INC-2847 hybrid sync investigation | Lab simulation | In progress — broken state under investigation |
| Entra Connect Sync troubleshooting runbook | Lab documentation | Complete |
| UPN suffix mismatch RCA guide | Lab documentation | Complete |

---

## Technical Skills Demonstrated

- Hybrid identity troubleshooting (Entra Connect, AD, proxyAddresses)
- Conditional Access root cause analysis (sign-in logs, CA What-If)
- GCC High-specific identity patterns (`.onmicrosoft.us`, `.azure.us` workspace URLs)
- PowerShell: hybrid user health check script, proxy address auditor, stale user report
- Portfolio documentation using professional incident report format

---

## Identity Risks Identified and Addressed

During production ticket work this week:

1. **ProxyAddress gap (GCC High):** A missing `.onmicrosoft.us` routing address caused a mail delivery failure. A bulk audit script (`audit-proxyaddresses.ps1`) was built to proactively find this issue across all clients before it causes tickets.

2. **CA policy blocking AVD on unmanaged Mac:** The security control worked as designed. Risk was that the user (and potentially the organization) would have requested a CA policy weakening to "fix" it. Instead, root cause was isolated and the policy was preserved.

---

## Tools Used

Microsoft Entra Admin Center, Exchange Admin Center (GCC High), ADUC, Entra Connect Sync, PowerShell (AD module + Microsoft Graph), Defender XDR, CA What-If tool

---

## Automation / Documentation Created

- `check-hybrid-user-health.ps1` — per-user hybrid identity health check
- `audit-proxyaddresses.ps1` — proactive bulk proxyAddress audit for all clients
- `report-stale-users.ps1` — stale user report combining AD + Entra sign-in data
- Portfolio: 8 professional incident/design documents created

---

## Business Value Delivered

- Restored email delivery for affected client user (resolved ticket)
- Prevented a CA policy weakening that would have reduced security posture
- Built three reusable automation scripts that reduce future investigation time for similar tickets across all MSP clients
- Started documenting GCC High-specific patterns that new techs typically lack

---

## Zero Trust Work

- Documented CA device compliance enforcement as a Zero Trust control (verify explicitly — device state as signal)
- Designed break-glass account requirements as foundation for any CA deployment
- Designed CA policy baseline following Zero Trust tiering (identity → device → risk)

---

## SC-300 Concepts Reinforced This Week

Hybrid identity (Entra Connect, PHS, proxyAddresses), Conditional Access design and troubleshooting, authentication strength, sign-in log analysis, GCC High environment differences

---

## Growth Areas / Honest Gaps

- **On-premises Active Directory depth:** Still developing comfort with advanced ADUC operations, GPO, and replication troubleshooting
- **Identity Governance (hands-on):** Entitlement Management and PIM are designed but not yet lab-tested
- **SC-300 exam prep:** Study structured but exam is 5 months out — need to be more consistent with daily quiz cadence

---

## Next 2-Week Focus (Week 4)

1. Resolve INC-2847 and complete the RCA document
2. Build the Conditional Access baseline in the lab tenant (Report-Only first)
3. Begin MD-102 structured study (targeting exam within 6 weeks)
4. Lab: implement PIM for at least two roles in the Meridian lab tenant
5. Complete the entitlement package design and test one access package

---

## Resume-Ready Bullets Generated This Week

> Diagnosed and resolved an external email delivery failure in a GCC High tenant caused by a missing `.onmicrosoft.us` proxy address on a synced AD user; built a reusable PowerShell audit script to proactively detect this issue across all MSP clients.

> Identified the root cause of an Azure Virtual Desktop access failure as a Conditional Access device compliance block on an unmanaged personal Mac; preserved the security policy and guided the user to a compliant resolution path using Entra sign-in logs and the CA What-If tool.

---

## One Ask

If any CA redesign, Intune compliance policy work, or PIM implementation comes through on any client, I'd like to be looped in — even just to observe the ticket. That's exactly where I'm building toward.
