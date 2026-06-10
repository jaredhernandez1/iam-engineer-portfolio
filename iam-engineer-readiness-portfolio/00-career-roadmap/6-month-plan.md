# 6-Month IAM Engineer Transition Plan

**Owner:** Jared Hernandez  
**Start Date:** June 2026  
**Target Role:** IAM Analyst / IAM Engineer  
**Target Compensation:** $100,000+  
**Competitive Edge:** GCC High / Azure Government daily production experience  

---

## The Goal

Transition from Help Desk Support Technician at an MSP into a dedicated IAM Analyst or IAM Engineer role within 6 months. Not by studying harder — by building documented, demonstrable evidence that I can operate like an IAM engineer right now.

---

## Month-by-Month Breakdown

### Month 1 — Foundation and Lab Build (June 2026)
**Theme:** Establish the environment. Understand what broken looks like.

**Cert Focus:** MD-102 prep begins  
**Lab Focus:** Meridian Consulting Group lab — Entra Connect Sync, OU hierarchy, bulk users, INC-2847 investigation  
**Portfolio Focus:** Document first 3 hybrid identity scenarios  
**Skill Targets:** Hybrid identity, PHS, UPN routing, proxyAddress, Entra Connect health  

**Deliverables:**
- [ ] INC-2847 root cause analysis complete
- [ ] `01-hybrid-identity/` section populated with 3 artifacts
- [ ] PowerShell: `check-hybrid-user-health.ps1` functional
- [ ] `audit-proxyaddresses.ps1` functional
- [ ] First manager review packet drafted

---

### Month 2 — Conditional Access and MFA (July 2026)
**Theme:** Understand how access decisions are made and enforced.

**Cert Focus:** MD-102 exam attempt  
**Lab Focus:** Build and break CA policies in lab tenant; test Named Locations, device compliance, MFA registration  
**Portfolio Focus:** 3 CA artifacts + scoped testing methodology  
**Skill Targets:** CA policy logic, MFA registration, authentication methods policy, named locations  

**Deliverables:**
- [ ] MD-102 exam attempted
- [ ] `02-conditional-access/` populated with 3 artifacts
- [ ] CA decision matrix template built
- [ ] Lab: reproduce and resolve an MFA registration block

---

### Month 3 — Identity Governance and PIM (August 2026)
**Theme:** Learn how access is granted, reviewed, and removed at scale.

**Cert Focus:** SC-300 study begins  
**Lab Focus:** Entitlement Management, Access Reviews, PIM role assignments  
**Portfolio Focus:** 2 governance artifacts + JML process design  
**Skill Targets:** Access packages, access reviews, PIM activation, approval workflows  

**Deliverables:**
- [ ] `03-identity-governance/` populated
- [ ] JML process design doc complete
- [ ] PIM admin model design doc complete

---

### Month 4 — Security Investigation and Defender XDR (September 2026)
**Theme:** Learn to detect, triage, and respond to identity threats.

**Cert Focus:** SC-300 — Identity Protection and Governance domains  
**Lab Focus:** Identity Protection risky user simulations, Defender XDR identity incidents  
**Portfolio Focus:** 3 security investigation artifacts  
**Skill Targets:** Risk policies, risky sign-in triage, impossible travel, UEBA basics  

**Deliverables:**
- [ ] `04-security-investigations/` populated with 3 artifacts
- [ ] Identity Protection risk policy design documented

---

### Month 5 — Automation and PowerShell (October 2026)
**Theme:** Build automation that proves I can operate at scale.

**Cert Focus:** SC-300 — full review, exam scheduled  
**Lab Focus:** PowerShell + Microsoft Graph automation pipeline  
**Portfolio Focus:** 3+ automation scripts with documentation; JML pipeline draft  
**Skill Targets:** Microsoft Graph API, PowerShell modules, batch reporting  

**Deliverables:**
- [ ] SC-300 exam booked
- [ ] `05-automation/` section complete with 4+ scripts
- [ ] JML automation pipeline draft functional

---

### Month 6 — Portfolio Polish and Job Application (November 2026)
**Theme:** Stop building. Start showing.

**Cert Focus:** SC-300 exam attempt  
**Portfolio Focus:** Final polish, GitHub publish, resume update, interview prep  
**Job Activity:** Active applications, recruiter outreach, networking  

**Deliverables:**
- [ ] SC-300 attempted
- [ ] GitHub portfolio public and complete
- [ ] Resume updated with portfolio bullets
- [ ] Target: 3-5 active interviews by end of month

---

## Cert Roadmap

```
AZ-104 ✅ (May 8, 2026 — Score: 750)
    ↓
MD-102: Endpoint Administrator (Target: Q3 2026)
    ↓
SC-300: Identity and Access Administrator (Target: Q4 2026)
```

---

## Weekly Operating Rhythm

| Day | Activity |
|---|---|
| Odd days | 3–5 question quiz from current study domain |
| Even days | Rebuild something from scratch without reference |
| Sunday | Cumulative quiz + timed artifact rebuild (convergence ritual) |

---

## Compensation Target

| Role | Target Range | Why Achievable |
|---|---|---|
| IAM Analyst | $80K–$95K | Baseline with certs + MSP experience |
| IAM Engineer | $95K–$115K | SC-300 + GCC High + automation portfolio |
| Federal IAM Engineer | $110K–$140K | Clearance exposure + CMMC/FedRAMP documentation |

> The GCC High differentiator alone thins the candidate pool significantly. Pair it with SC-300 and a documented portfolio and the $100K target is realistic within 6 months.
