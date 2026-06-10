# Impossible Travel Alert — Triage and Investigation

**Portfolio Folder:** `04-security-investigations/`  
**Artifact Type:** Investigation Runbook + Decision Tree  
**Environment:** Lab + Production patterns  
**Status:** 📝 Template  

---

## Purpose

A focused runbook for triaging Entra ID Identity Protection "atypical travel" (impossible travel) risk detections — one of the most common and most frequently misunderstood identity alerts.

---

## What Impossible Travel Actually Means

Entra ID Identity Protection flags a sign-in as "atypical travel" (commonly called impossible travel) when:
1. Sign-in A occurs from Location X at time T
2. Sign-in B occurs from Location Y at time T + delta
3. The geographic distance between X and Y divided by the time delta would require faster-than-possible travel

**Important:** This does NOT mean the account is compromised. It means the system detected a physical impossibility in the sign-in pattern that warrants investigation.

---

## Common False Positive Causes

| Cause | Why It Triggers | How to Confirm |
|---|---|---|
| VPN usage | User's VPN exits in a different country than their physical location | Ask user if they use a VPN |
| Corporate proxy / split tunnel | Traffic routed through a proxy with a different IP geolocation | Check proxy IP vs physical IP |
| Mobile data vs Wi-Fi | Phone may register different IPs for cellular vs Wi-Fi connections | Ask user about device switching |
| Travel (actual) | User genuinely flew from one city to another | Confirm with user itinerary |
| IP geolocation error | Geolocation database incorrectly places an IP in the wrong region | Cross-reference IP with multiple geo tools |
| Shared IP space | Two users in the same building share an outbound IP — different users' sessions collide in the log | Check if both sign-ins belong to the same account |

---

## Triage Decision Tree

```
IMPOSSIBLE TRAVEL ALERT
│
├── Is the risk level HIGH?
│   ├── YES → Block sign-in + revoke sessions immediately → then investigate
│   └── NO → Investigate first → then remediate if confirmed
│
├── What was the time delta between the two sign-ins?
│   ├── < 1 hour, > 500 miles apart → High suspicion → verify out-of-band
│   └── > 4 hours → May be legitimate travel → verify with user
│
├── Did the user have a VPN or proxy active?
│   ├── YES → Likely false positive → verify IP and dismiss if confirmed
│   └── NO → Investigate further
│
├── Out-of-band user verification (call, not email)
│   ├── User confirms both sign-ins → Dismiss risk, document
│   └── User cannot confirm one sign-in → Treat as compromise → full playbook
│
└── FINAL DECISION
    ├── Confirmed false positive → Dismiss risk
    ├── Confirmed legitimate → Dismiss risk + add trusted location if appropriate
    └── Confirmed compromise → Run compromised-account-response.md playbook
```

---

## Investigation Steps

### Step 1 — Pull both sign-in events

In Entra sign-in logs, find the two events that triggered the alert.

Document for each:
- Timestamp (UTC)
- IP address
- Geolocation
- Device (managed or unmanaged)
- Application accessed
- Authentication method (MFA satisfied or not)
- CA policy outcome

### Step 2 — Calculate the impossibility

Geographic distance between the two locations ÷ time between sign-ins = required speed

If required speed > 600 mph (commercial flight speed): physically impossible.
If required speed < 600 mph: may be legitimate travel.

### Step 3 — Check for VPN / proxy indicators

- Is the IP a known VPN exit node? (check: ipinfo.io, AbuseIPDB)
- Is it a datacenter IP vs residential/corporate IP?
- Does the organization use a corporate proxy?

### Step 4 — Out-of-band user verification

Call the user. Ask specifically:
- "Were you signed into [application] from [location 1] around [time]?"
- "Were you also signed in from [location 2] around [time]?"
- "Do you use a VPN?"

### Step 5 — Document and act

If false positive: dismiss with documentation.  
If confirmed or unconfirmed: treat as compromise and follow `compromised-account-response.md`.

---

## Named Location Guidance

If a user frequently triggers impossible travel due to VPN usage, configure a Named Location for the VPN exit IP range:

```
Entra Admin Center → Protection → Conditional Access → Named Locations → + IP ranges location
```

Add the VPN IP range as a trusted/named location. Identity Protection will de-prioritize risk from known locations.

---

## SC-300 Concepts Reinforced

- Identity Protection risk detection types (atypical travel)
- Risk triage methodology
- Named Locations configuration
- False positive management
- Out-of-band investigation techniques

---

## Resume Bullet

> Built an impossible travel alert triage runbook with a structured decision tree distinguishing VPN false positives from genuine compromise indicators; includes out-of-band verification steps, Named Location configuration guidance, and escalation criteria tied to the compromised account response playbook.
