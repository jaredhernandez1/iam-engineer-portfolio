# Entitlement Package Design — Role-Based Access for Meridian Consulting Group

**Portfolio Folder:** `03-identity-governance/`  
**Artifact Type:** Design Document  
**Environment:** Lab (Meridian Consulting Group)  
**Status:** 📝 Design — to be built in lab  

---

## Purpose

Design a structured set of Entitlement Management access packages that replace ad-hoc group membership requests with a governed, approval-gated, time-limited access model.

---

## Why Entitlement Management Over Direct Group Assignment

| Ad-Hoc Group Assignment | Entitlement Packages |
|---|---|
| Admin manually adds user to group | User requests access through My Access portal |
| No approval gate | Approval workflow required |
| Access never expires | Time-limited with renewal option |
| No audit trail of who approved | Full audit log of request, approval, grant |
| No self-service for users | Users self-serve via catalog |
| Access review required to clean up | Auto-removed on expiry or denied renewal |

---

## Access Package Catalog Design — Meridian Consulting Group

### Catalog: Corporate Access

| Package Name | Included Resources | Approver | Duration | Eligible Requesters |
|---|---|---|---|---|
| Standard Employee Access | M365 license, All-Employees group, SharePoint Intranet | Auto-approve | 1 year (auto-renew) | All internal users |
| Finance Team Access | Finance SharePoint, Finance DL, QuickBooks app | Finance Manager | 6 months | Finance department |
| IT Admin — Read Only | Entra read access, Intune read access | IT Manager | 3 months | IT staff |
| Project Alpha Access | Project SharePoint site, Teams channel, Project group | Project Sponsor | 90 days | Internal + contractors |
| Contractor Baseline | Email (read-only), Project SharePoint, VPN | Sponsor + HR | Contract duration | B2B guests / contractors |

---

## Sample Package: Finance Team Access

**Package Name:** Finance Team Access  
**Catalog:** Corporate Access  
**Description:** Provides access to finance systems and collaboration resources for Finance department members.

**Resources included:**
- Security group: `MCG-Finance-Team`
- SharePoint site: Finance Operations (reader → contribute based on approval tier)
- Distribution list: `finance-all@[domain]`

**Policies:**

*Policy 1 — Employee Direct Request:*
- Eligible requesters: Members of `MCG-All-Employees`
- Approval: Single-stage — Finance Manager
- Approval deadline: 48 hours
- Duration: 6 months
- Renewal: Allowed — requester-initiated

*Policy 2 — Contractor Request:*
- Eligible requesters: Members of `MCG-Contractors-Active`
- Approval: Two-stage — Project Sponsor → Finance Manager
- Duration: 90 days, no auto-renew
- Access review: Monthly

**Separation of Duties:** Users with access to the Payroll processing group cannot hold Finance Team Access simultaneously (conflicting access rule).

---

## My Access Portal Configuration

Users access packages at: `myaccess.microsoft.com`

For GCC High environments: `myaccess.microsoft.us`

Configure the catalog as **enabled for external users** only if B2B contractors need access via the self-service portal.

---

## SC-300 Concepts Reinforced

- Entitlement Management catalogs and packages
- Access package policies and approval workflows
- Time-limited access with renewal
- Separation of duties (incompatible access)
- My Access portal for self-service

---

## Resume Bullet

> Designed a role-based entitlement package catalog in Entra ID Governance for a simulated enterprise, replacing ad-hoc group assignments with governed, approval-gated, time-limited access packages — including contractor-specific policies with mandatory two-stage approval and monthly access reviews.
