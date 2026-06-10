# Entra Connect Sync — Hybrid Identity Troubleshooting Template

**Portfolio Folder:** `01-hybrid-identity/`  
**Artifact Type:** Troubleshooting Runbook  
**Environment:** Lab (Meridian Consulting Group) + Production Patterns  
**Status:** 🔄 Active — INC-2847 investigation in progress  

---

## Purpose

A systematic runbook for diagnosing Entra Connect Sync failures, object filtering issues, and attribute flow problems in hybrid identity environments. Built from hands-on lab work and production ticket experience.

---

## Business Context

In organizations running hybrid identity, Entra Connect Sync is the pipeline that makes on-premises AD users appear in the cloud. When it breaks — or when objects are filtered, misconfigured, or missing attributes — users lose access. This runbook captures the decision tree for diagnosing those failures quickly.

---

## Environment

- **Lab Tenant:** Meridian Consulting Group simulation (`[lab-tenant].onmicrosoft.com`)
- **On-Premises AD:** Windows Server — `mcglab.local`
- **Sync Method:** Password Hash Synchronization (PHS)
- **OU Structure:** Enterprise hierarchy with 15+ bulk-created users

---

## Tools Used

- Entra Connect Sync service (Synchronization Service Manager)
- Active Directory Users and Computers (ADUC)
- Active Directory Module for PowerShell
- Microsoft Entra Admin Center
- Entra Connect Health (if licensed)
- Event Viewer (on the Entra Connect server)

---

## Hybrid Identity Troubleshooting Decision Tree

### Layer 1 — Is the sync service running?

```powershell
# On the Entra Connect server
Get-Service -Name "ADSync" | Select-Object Status, StartType
```

Expected: `Running`  
If stopped: `Start-Service ADSync` then investigate why it stopped.

---

### Layer 2 — When did the last sync run?

```powershell
# Check last sync time from Entra Admin Center or via PowerShell
Get-ADSyncScheduler
```

Look for `LastSyncCycleStarted` and `LastSyncCycleResult`.  
If sync hasn't run in >30 min and is enabled, check Windows Event Viewer on the Entra Connect server.

---

### Layer 3 — Is the user object in scope for sync?

**Check 1 — Is the user in a synced OU?**

In Entra Connect, open the Synchronization Service Manager → Connectors → [Domain] → Properties → Configure Directory Partitions → Containers.  
Confirm the user's OU is checked for synchronization.

**Check 2 — Is the user filtered by an attribute rule?**

Review inbound sync rules in the Synchronization Rules Editor. Look for attribute-based filtering that might exclude the user (e.g., `cloudFiltered = TRUE`, department exclusions).

**Check 3 — Is `cloudFiltered` set to True on the object?**

```powershell
Get-ADUser -Identity "username" -Properties extensionAttribute* | Select-Object extensionAttribute*
```

If `cloudFiltered` is being set to `TRUE` by a sync rule, the object will be excluded from sync intentionally.

---

### Layer 4 — Does the object exist in the Entra ID Connector Space?

Open Synchronization Service Manager → Connectors → [Entra ID Connector] → Search Connector Space.

Search for the user by DN or anchor. If the object is NOT in the Entra connector space, it was either never synced or was filtered/deleted.

---

### Layer 5 — Are there sync errors on the object?

In Synchronization Service Manager → Operations tab, look for recent sync run errors.

Common errors:
| Error | Cause |
|---|---|
| `duplicate-attribute` | UPN or proxyAddress already exists in Entra ID on a different object |
| `object-not-found` | Object was deleted in one directory but not the other |
| `invalid-soft-match` | Soft-match failed due to mismatched UPN or mail attribute |
| `export-attribute-flow` | Attribute value violates Entra ID validation rules |

---

### Layer 6 — Force a delta sync and re-check

```powershell
Start-ADSyncSyncCycle -PolicyType Delta
```

Wait 2–5 minutes, then re-check the user's status in Entra Admin Center.  
If issues persist after delta, run a full sync:

```powershell
Start-ADSyncSyncCycle -PolicyType Initial
```

> Use full sync sparingly — it processes all objects and can surface unintended side effects.

---

### Layer 7 — Verify the synced object in Entra ID

In Entra Admin Center → Users → [Affected User]:
- Confirm `On-premises sync enabled` = Yes
- Confirm `On-premises immutable ID` is populated
- Confirm `Source of authority` = Windows Server AD
- Confirm proxy addresses are correct

---

## Key Attribute Reference

| Attribute | On-Premises Name | Entra ID Name | Common Issues |
|---|---|---|---|
| Sign-in name | `userPrincipalName` | `userPrincipalName` | Suffix not verified in Entra ID |
| Email | `mail` | `mail` | Mismatch causes Exchange delivery failure |
| Routing addresses | `proxyAddresses` | `proxyAddresses` | Missing `.onmicrosoft.us` (GCC High) |
| Object identifier | `objectGUID` | `immutableId` | Mismatch breaks sync anchor |
| Display name | `displayName` | `displayName` | Usually safe to update in either place |

---

## INC-2847 — Active Investigation

**Status:** Broken state created in lab — investigation in progress  
**Scenario:** Synced user cannot sign in; object exists in both AD and Entra ID but authentication fails  
**Next Steps:** Work through layers 3–6 of this runbook to isolate root cause  

*Root cause analysis artifact will be created upon resolution and added to this folder.*

---

## SC-300 Concepts Reinforced

- Entra Connect Sync architecture and attribute flow
- Sync rule evaluation order and filtering logic
- OU-based vs attribute-based filtering
- Delta vs full synchronization
- Object anchor (immutableId / objectGUID) management
- Common sync error types and remediation

---

## Resume Bullet

> Built and documented a layered hybrid identity troubleshooting runbook for Entra Connect Sync environments, covering OU filtering, attribute flow errors, connector space validation, and delta/full sync operations across lab and production GCC High scenarios.
