**IAM-D01-T01 — Marcus Webb Not Visible in Entra ID After Hybrid Sync**

Folder: 01-hybrid-identity/
Type: Root Cause Analysis
Environment: Lab — Meridian Consulting Group
Status: ✅ Resolved

**What Was Reported**

Marcus Webb (mwebb), a new Sr. Financial Analyst, could not access Microsoft 365 on his start date. His AD account existed but he had no presence in Entra ID — no license, no mailbox, no SharePoint access. The AD admin ran a manual delta sync after account creation. Sync reported Success. mwebb still didn't appear.

**What I Found**

mwebb was created in OU=Staging,OU=MCG,DC=mcglab,DC=local.
<img width="1477" height="405" alt="image" src="https://github.com/user-attachments/assets/a5880142-4c6d-48c0-9275-0fdc178a84d4" />

Entra Connect OU filtering was configured to exclude the Staging OU from sync scope. This is a silent exclusion — no error is generated because the object is filtered before it ever reaches the sync engine. The delta sync succeeded because every in-scope object processed cleanly. mwebb was simply never evaluated.
Confirmed via:

Entra Admin Center search — no results for mwebb
<img width="2013" height="830" alt="image" src="https://github.com/user-attachments/assets/2a60e907-4768-4d26-875d-6b7fe2201c9a" />

Screenshots
Before — Staging OU excluded from sync scope:
<img width="1384" height="969" alt="image" src="https://github.com/user-attachments/assets/b014d32b-6073-4c21-8124-acaf73126009" />

After — Staging OU included mwebb visible in Entra post-fix:
<img width="2049" height="702" alt="image" src="https://github.com/user-attachments/assets/dff306d8-b2c7-4d01-b3f5-4ee1b87f1554" />


What I Changed
Re-checked the Staging OU in Entra Connect → Domain and OU Filtering, then ran a full sync:
<img width="1392" height="963" alt="image" src="https://github.com/user-attachments/assets/11a1a97c-2c02-41d2-bc64-99b1bf644318" />

powershellStart-ADSyncSyncCycle -PolicyType Initial
Used -PolicyType Initial (not Delta) because mwebb was never previously synced — a delta cycle would not evaluate him.

Validation
powershellGet-MgUser -UserId "mwebb@unbork.onmicrosoft.com" `
    -Property displayName,userPrincipalName,onPremisesImmutableId,onPremisesSyncEnabled |
    Select-Object *
✅ onPremisesSyncEnabled = True
✅ onPremisesImmutableId populated
✅ Source: Windows Server AD

**Lessons Learned**

A successful sync does not mean **ALL** objects were synced only in-scope objects are evaluated
Always check OU filtering first when a specific user is missing but their peers sync normally
After re-including an excluded OU, use a full sync delta won't pick up never-synced objects
