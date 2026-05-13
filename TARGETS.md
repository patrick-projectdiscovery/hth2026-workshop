# Alternative Targets
### Practice beyond the workshop

Finished early? Want to keep going after the con? Here are legal, permissioned targets you can run the PD pipeline against.

---

## Deliberately Vulnerable Apps (Run Locally)

These are intentionally broken applications designed for security practice. Run them in Docker on your own machine.

### OWASP Juice Shop
The most popular deliberately vulnerable web app. 100+ challenges, full-stack, great UI.
```bash
docker run -p 3000:3000 bkimminich/juice-shop
# Open http://localhost:3000
```
**Good for:** Full pipeline practice, Nuclei template writing, web app testing
**Link:** https://github.com/juice-shop/juice-shop

### DVWA (Damn Vulnerable Web Application)
Classic web vulnerability trainer. SQLi, XSS, CSRF, file inclusion, command injection.
```bash
docker run -d -p 80:80 vulnerables/web-dvwa
# Open http://localhost — login: admin/password
```
**Good for:** Individual vuln categories, Nuclei template practice
**Link:** https://github.com/digininja/DVWA

### WebGoat
Guided lessons for each vulnerability type. Great if you want structured learning.
```bash
docker run -p 8080:8080 -p 9090:9090 webgoat/webgoat
# Open http://localhost:8080/WebGoat
```
**Good for:** Learning specific vuln classes step by step
**Link:** https://github.com/WebGoat/WebGoat

### VulnHub
Hundreds of boot-to-root virtual machines. Download, run in VirtualBox/VMware, hack.
**Good for:** Full attack chain practice (recon → exploit → priv esc)
**Link:** https://www.vulnhub.com

---

## Cloud-Specific Targets

### CloudGoat
"Vulnerable by design" AWS deployment. Spins up real AWS resources with misconfigurations.
```bash
git clone https://github.com/RhinoSecurityLabs/cloudgoat.git
cd cloudgoat && pip install -r requirements.txt
python3 cloudgoat.py config profile
python3 cloudgoat.py create iam_privesc_by_rollback
```
> ⚠️ Requires an AWS account. Resources are created in YOUR account — tear them down after.

**Good for:** Cloudlist → httpx → nuclei pipeline on real cloud infra
**Link:** https://github.com/RhinoSecurityLabs/cloudgoat

### Damn Vulnerable Cloud Application
Multi-cloud vuln scenarios (AWS, GCP, Azure).
**Good for:** Cloud misconfig detection practice
**Link:** https://github.com/m6a-UdS/dvca

### AWSGoat / AZGoat / GCPGoat
Cloud-specific vulnerable-by-design infrastructure from INE.
**Links:**
- https://github.com/ine-labs/AWSGoat
- https://github.com/ine-labs/AZGoat
- https://github.com/ine-labs/GCPGoat

---

## Public Bug Bounty Programs (Live Targets)

These are real companies that explicitly invite security testing within their defined scope. **Always read the program policy and scope before scanning.**

| Platform | Where to Start |
|---|---|
| **HackerOne** | https://hackerone.com/directory — filter by "Managed" for vetted programs |
| **Bugcrowd** | https://bugcrowd.com/programs — filter by "Open" |
| **Intigriti** | https://www.intigriti.com/programs — European-focused programs |

### Tips for Bug Bounty with PD Tools
```bash
# Enumerate subdomains for a bounty target
subfinder -d target.com -all -recursive -o subs.txt

# Probe for live hosts
cat subs.txt | httpx -silent -title -tech-detect -status-code -o live.txt

# Scan (start gentle — check scope!)
cat live.txt | nuclei -severity medium,high,critical -o findings.txt
```

> 🚨 **Rules of engagement:**
> - Only scan assets explicitly listed in scope
> - Respect rate limits — don't DoS the target
> - Report findings responsibly through the program's platform
> - Never access, modify, or exfiltrate real user data
> - When in doubt, don't scan it

---

## Nuclei Template Resources

| Resource | What It Is |
|---|---|
| [nuclei-templates](https://github.com/projectdiscovery/nuclei-templates) | Community template repo — 9000+ templates |
| [Template Guide](https://docs.projectdiscovery.io/templates/introduction) | Official template writing documentation |
| [Template Editor](https://cloud.projectdiscovery.io) | AI-assisted template editor in PDCP |
| [Template Examples](https://github.com/projectdiscovery/nuclei-templates/tree/main/http) | Browse real templates by category |

### Template Categories Worth Exploring
- `http/exposures/` — config files, debug endpoints, .env leaks
- `http/misconfiguration/` — CORS, headers, open redirects
- `http/vulnerabilities/` — CVEs, known product vulns
- `http/default-logins/` — default credentials
- `http/technologies/` — tech fingerprinting

---

## Want to Contribute?

The Nuclei templates repo is open source and always accepting contributions. If you wrote a template during the workshop, clean it up and submit a PR:

1. Fork `projectdiscovery/nuclei-templates`
2. Add your template to the appropriate category
3. Test it: `nuclei -t your-template.yaml -u target -validate`
4. Submit a PR with a description of what it detects

Templates that get merged are used by 100k+ security practitioners worldwide.
