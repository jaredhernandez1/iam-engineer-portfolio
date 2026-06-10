# Interview Stories — STAR Format

**Purpose:** Ready-to-tell stories for IAM Analyst / IAM Engineer interviews. Each story follows Situation → Task → Action → Result. Practice saying these out loud until they're natural.

---

## Story 1 — ProxyAddress Email Delivery Failure (GCC High)

**Good for:** "Tell me about a time you diagnosed a complex issue." / "Describe your troubleshooting process." / "Tell me about a hybrid identity issue you've solved."

**Situation:**  
A user at one of our GCC High client organizations suddenly stopped receiving external email. Internal email worked fine, external senders were getting NDRs or silent failures. The user was in a business-critical role and the communication disruption was urgent.

**Task:**  
As the support technician, I needed to identify the root cause, determine whether it was an Exchange configuration issue, a Conditional Access problem, an identity sync issue, or something else — and fix it without disrupting other users.

**Action:**  
I started with a message trace in Exchange Admin Center to confirm the scope — internal delivery worked, external delivery was failing. That pointed me toward mail routing rather than a mailbox or authentication problem. I inspected the user's proxy addresses in both Entra ID and their on-premises Active Directory object. The cloud profile looked mostly fine, but when I checked the AD Attribute Editor I found the `.onmicrosoft.us` routing address was missing — which in GCC High is how Exchange Online routes inbound mail. Because the user was hybrid-synced, fixing it in the cloud would be overwritten at the next sync. I added the missing address directly to the AD `proxyAddresses` attribute, then forced a delta sync with `Start-ADSyncSyncCycle -PolicyType Delta` instead of waiting 30 minutes. Verified the address appeared in Entra ID within two minutes, confirmed in EAC, and sent a test message.

**Result:**  
External email was restored within 15 minutes of identifying root cause. I also built a PowerShell audit script that checks all mail-enabled users across our GCC High clients for this same missing address, so we can proactively catch it before it generates another ticket.

---

## Story 2 — CA Device Compliance Block on AVD

**Good for:** "Tell me about a time you identified the real root cause vs the perceived problem." / "Describe a Conditional Access issue you've handled." / "How do you handle a user who thinks they know what's wrong?"

**Situation:**  
A remote user couldn't access Azure Virtual Desktop from their Mac and was convinced their recent forced password reset had broken their account. They were escalating and frustrated.

**Task:**  
I needed to either confirm the password reset was the issue (and fix it) or identify the real root cause — and do it in a way that didn't unnecessarily weaken the organization's security posture to resolve it.

**Action:**  
Rather than immediately resetting the password again, I pulled the sign-in logs from Entra Admin Center. Under the Conditional Access tab on the failed sign-in entry, I could see the policy name and why it blocked: device compliance required, device not compliant, macOS, unmanaged. The password reset had nothing to do with it — the CA policy was blocking any access from an unmanaged personal Mac, which is exactly what it was designed to do. I used the CA What-If tool to confirm the expected policy behavior, then explained to the user and the client that the account was fine, the password reset was successful, and the block was a security control operating correctly. The resolution was to use a managed corporate device, not to touch the CA policy.

**Result:**  
The user got access via a managed device. We preserved a security control that was working as designed. The client admin initially wanted to "just turn off that policy" — explaining the root cause prevented an unnecessary and risky policy change. I documented the scenario as a pattern for future tickets.

---

## Story 3 — JAMF MDM Enrollment Failure

**Good for:** "Tell me about a time you had to work through a vendor-specific issue." / "How do you approach a problem you haven't seen before?" / "Tell me about your device identity experience."

**Situation:**  
A new employee at a client organization couldn't complete JAMF MDM enrollment on their Mac. The device was showing up in JAMF but never completing the management profile installation. IT had already tried re-sending the enrollment invitation twice with no success.

**Task:**  
I needed to determine why the enrollment was stalling at the MDM profile step — whether it was a JAMF configuration issue, an Entra ID issue, a device issue, or a user error.

**Action:**  
I walked through the enrollment flow with the user and discovered the MDM management profile had been delivered to the device but was sitting in System Preferences in an "unapproved" state — the user had never seen the prompt to approve it, or had dismissed it. In macOS, MDM profiles from a non-Apple MDM require explicit user approval in System Preferences. Beyond the unapproved profile, there was also a stale device record in JAMF from an earlier failed attempt that was competing with the new enrollment. I had the JAMF admin delete the stale record, we re-issued a fresh enrollment invitation, and I walked the user through exactly where in System Preferences to find and approve the profile.

**Result:**  
Device enrolled successfully on the first attempt after clearing the stale record and confirming the user completed the approval step. I documented the resolution — including the JAMF-specific profile approval requirement — to help other techs who might hit the same pattern.

---

## Story 4 — Stale User and License Discovery (Automation)

**Good for:** "Tell me about something you built that created ongoing value." / "How do you approach automation?" / "Tell me about a time you identified a business risk proactively."

**Situation:**  
While working tickets at the MSP, I noticed we were consistently handling access issues involving departed employees or employees who had transferred roles but still retained their old access and licenses. These were causing both security and cost issues, but there was no systematic way to identify them.

**Task:**  
I wanted to build something that could surface stale accounts proactively — before they became tickets or audit findings — across our client tenants.

**Action:**  
I built a PowerShell script that combines Active Directory last logon timestamps with Entra ID sign-in activity data via Microsoft Graph, then cross-references assigned license counts. The script categorizes every enabled account into staleness tiers: Active, Moderate, Stale, and Critical — and outputs a CSV report with recommended actions. I designed it with parameterized inputs so it works across any tenant without hardcoded values, and outputs the estimated number of licenses sitting on stale or critical accounts so there's a cost number to attach to the finding.

**Result:**  
The script surfaces accounts that were never flagged manually, gives client admins a monthly snapshot of access hygiene, and provides a quantified license cost to attach to any cleanup recommendation — making it easier to get client buy-in on offboarding work. The script is part of my automation library and can be adapted for any M365 client environment.

---

## Story Bank — To Be Developed

*These will be developed as the work is completed:*

- [ ] INC-2847 — hybrid sync investigation (root cause pending)
- [ ] First PIM role activation in lab
- [ ] First CA policy built from scratch in Report-Only
- [ ] JML pipeline — first automated provisioning run
- [ ] First entitlement management access review cycle

---

## Interview Preparation Tips

**On GCC High:**  
If the role touches federal, cleared, or DoD-adjacent work: lead with GCC High. Most candidates have never touched it. It's a meaningful differentiator and signals you can work in constrained, compliance-heavy environments.

**On the portfolio:**  
"I don't just have certs — I have a GitHub portfolio of documented incidents, runbooks, PowerShell scripts, and design reviews from both production tickets and lab work." Then give a specific example.

**On the career transition:**  
"Every ticket I close at the MSP touches identity in some form. I've been systematically deepening that work and documenting it. I'm not pivoting — I'm specializing in the direction I'm already heading."

**On gaps:**  
Own them clearly and show what you're doing about them. "My identity governance hands-on is still developing — I have the design work done in my portfolio and I'm building it in the lab this month" is a stronger answer than deflecting.
