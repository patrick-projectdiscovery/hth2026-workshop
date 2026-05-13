# Neo AI Pentesting — Segment Reference
### HTH 2026 Workshop · Section 3 · 1:30–1:55

Neo is ProjectDiscovery's AI pentesting agent. This section is a live demo,
but use these prompts to follow along or replay it on your own afterward.

---

## Target

```
https://portal.spaceballscorp.com
```

Log in to the Spaceballs portal at `https://portal.spaceballscorp.com` as `lone_starr / 12345` before starting your Neo session.

---

## Suggested Prompts

**Start broad:**
> "Test the Spaceballs employee portal at https://portal.spaceballscorp.com for security vulnerabilities. I'm logged in as lone_starr."

**Privilege escalation:**
> "Check if I can escalate my privileges beyond a standard employee role on the API."

**IDOR:**
> "Test whether the employee profile endpoint leaks data for users other than the one I'm authenticated as."

**Business logic:**
> "Look for any approval workflow endpoints that could be exploited — for example, submitting and approving your own requests."

**Chain findings:**
> "I found a leaked JWT secret in the environment. Use it to access endpoints I shouldn't be able to reach as lone_starr."

---

## What Neo Finds That Nuclei Doesn't

Template scanners fire on signatures — a known path, a known response pattern.
These bugs have no signature:

| Vulnerability | Why scanners miss it |
|---|---|
| IDOR on `/api/employees/:id` | Requires auth + knowing what "your own" record should be |
| Mass assignment via `role` field | Frontend never sends it — only visible if you read the API spec |
| Self-approval on document requests | Multi-step flow with business context required |
| Deactivated account JWT bypass | Two separate code paths — login vs. middleware |

Neo reasons about the application's intent, not just its responses.

---

## Resources

- [Neo](https://neo.projectdiscovery.io)
- [Neo Docs](https://docs.projectdiscovery.io/neo/introduction)
