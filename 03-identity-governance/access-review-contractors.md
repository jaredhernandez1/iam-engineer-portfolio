# Access Review — Contractor and Guest Account Governance

**Portfolio Folder:** `03-identity-governance/`  
**Artifact Type:** Process Design + Governance Framework  
**Environment:** Lab (Meridian Consulting Group) — applicable to production  
**Status:** 📝 Design — to be lab-tested  

---

## Purpose

Design and document a recurring access review process specifically for contractor and guest (B2B) accounts, which represent the highest-risk identity category for access sprawl and lingering access in most organizations.

---

## Why Contractors and Guests Require Special Governance

1. **No HR system anchor** — Contractor end dates often aren't tracked in the same systems as employees. Access continues after contracts end.
2. **Broader access than intended** — Contractors often receive more access than their role requires because it's easier to copy an employee's permissions than to scope correctly.
3. **B2B guest accounts proliferate** — Every external collaboration creates a guest account. Most organizations have hundreds of guests with unknown access levels.
4. **No automatic offboarding trigger** — Without a formal offboarding trigger tied to contract end, contractor access is never revoked.

---

## Access Review Design for Meridian Consulting Group (Lab)

### Review Scope

| Account Type | Review Frequency | Reviewer | Auto-Deny on No Response |
|---|---|---|---|
| External contractors (B2B guest) | Monthly | Project sponsor / manager | Yes — 14 days |
| Internal contractors (synced accounts) | Quarterly | Department head | Yes — 14 days |
| Shared/service accounts | Quarterly | System owner | No — escalate |
| Privileged role holders | Monthly | Privileged Role Administrator | No — escalate |

---

### Access Review Configuration in Entra ID Governance

**To create a recurring access review:**

```
Entra Admin Center → Identity Governance → Access Reviews → + New access review
```

Configuration:
- **Review type:** Teams + Groups (for group membership) or Applications (for app role assignments)
- **Scope:** Guest users only (for contractor/guest review)
- **Reviewers:** Group owners or specific manager
- **Duration:** 14 days
- **Recurrence:** Monthly
- **Auto-apply results:** Yes — deny access if no response (for guest accounts)
- **Upon completion:** Remove access (or disable account, depending on policy)

---

### Reviewer Decision Criteria

Reviewers should be guided by these questions (include in review notification):

1. Is this person still actively working on a project that requires this access?
2. Do they need all the access they currently have, or can it be scoped down?
3. Is their contract still active?
4. When did they last use this access? (sign-in data available in review)

---

### Notification Design

Reviewer notification email should include:
- User's display name and account type
- Last sign-in date
- Current group memberships or app access being reviewed
- Decision deadline
- Link to the access review portal

---

## Contractor Account Lifecycle Policy

### At Engagement Start
- [ ] Create account with contractor OU placement
- [ ] Set account expiration date = contract end date + 7 days (buffer for transition)
- [ ] Assign access package scoped to project only
- [ ] Add to `[MCG-Contractors-Active]` group

### During Engagement
- [ ] Monthly access review for group memberships
- [ ] 30-day pre-expiration notification to sponsor

### At Engagement End
- [ ] Disable account on contract end date (automated via scheduled task)
- [ ] Remove from all groups (automated)
- [ ] Revoke sessions (Graph API)
- [ ] Archive or delete account per retention policy (90 days → delete)

---

## Reporting Outputs

After each access review cycle, generate a summary:

| Metric | Target |
|---|---|
| Review completion rate | >90% |
| Auto-denied (reviewer no-response) | <10% |
| Access removed (denied by reviewer) | Track and trend |
| Contractor accounts past end date | 0 |
| Guest accounts with no sign-in >90 days | 0 (auto-remediated) |

---

## SC-300 Concepts Reinforced

- Entra ID Governance access reviews
- B2B guest user lifecycle management
- Auto-apply access review results
- Identity governance reporting
- Risk-based access review scoping

---

## Resume Bullet

> Designed a recurring access review framework for contractor and guest B2B accounts using Entra ID Governance, with monthly review cycles, auto-deny on non-response, and a lifecycle policy covering account creation, active monitoring, and automated offboarding tied to contract end dates.
