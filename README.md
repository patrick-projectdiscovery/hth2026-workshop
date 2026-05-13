# From Recon to Remediation with ProjectDiscovery
### HTH 2026: Spaceballs — The Hacker Conference

> *"Combing the galaxy for security vulnerabilities"*

A 2-hour hands-on workshop where you'll run the full ProjectDiscovery recon-to-vulnerability pipeline, write your own Nuclei detection template, see it all scale through the cloud platform, and watch an AI pentesting agent find bugs no scanner can catch.

**All skill levels welcome.** If you can open a terminal, you can do this.

---

## ⚡ Quick Start

**Before the workshop**, clone this repo and get your tools installed.

```bash
git clone https://github.com/patrick-projectdiscovery/hth2026-workshop
cd hth2026-workshop
```

> Run all workshop commands from inside this directory — the wordlist and templates are referenced by relative path.

### Verify your setup
```bash
chmod +x scripts/verify-setup.sh && ./scripts/verify-setup.sh
```

### Install tools (pick one):

### Option A: PDTM (Recommended)
ProjectDiscovery Tool Manager — installs everything in one shot.

```bash
go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
pdtm -install-all
```

> Requires Go 1.21+. [Install Go](https://go.dev/doc/install) if you don't have it.

### Option B: Docker
If you don't want to install Go or the tools natively:

```bash
docker pull projectdiscovery/nuclei
docker pull projectdiscovery/subfinder
docker pull projectdiscovery/httpx
docker pull projectdiscovery/naabu
docker pull projectdiscovery/katana
```

### Option C: Individual Install
```bash
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```

### Verify your install
```bash
./scripts/verify-setup.sh
```

If all required tools show `[✓]`, you're good to go.

---

## 🎯 Workshop Target

**Spaceballs Galactic Defense Corp** — a deliberately vulnerable web application built for this workshop.

| Service | URL |
|---|---|
| Corporate Site | https://spaceballscorp.com |
| Employee Portal | https://portal.spaceballscorp.com |
| Admin Panel | https://admin.spaceballscorp.com |
| API Documentation | https://docs.spaceballscorp.com |

> ⚠️ **This is a deliberately vulnerable application.** Only interact with it during the workshop or with explicit permission. Do not attack infrastructure outside of the target scope.

### Test Accounts
| Username | Password | Role |
|---|---|---|
| `lone_starr` | `12345` | Employee |
| `vespa` | `druish_princess` | Manager |
| `dark_helmet` | `spaceballs` | Admin |

More accounts exist. Finding them is part of the fun.

---

## 📋 Workshop Outline

| Time | Section | What You'll Do |
|---|---|---|
| 0:00–1:00 | **PD Open Source Toolkit** | Run the full recon pipeline, write a Nuclei template |
| 1:00–1:30 | **PD Cloud Platform** | See the same target scanned at enterprise scale |
| 1:30–1:55 | **Neo AI Pentesting** | Watch an AI agent find business logic bugs live |
| 1:55–2:00 | **Wrap-Up** | Resources, Q&A, go hack the CTF |

---

## 📂 What's in This Repo

```
├── README.md              ← You are here
├── CHEATSHEET.md          ← Pipeline commands & Nuclei template syntax (print this)
├── TARGETS.md             ← Alternative targets to practice on after the workshop
├── subs-wordlist.txt      ← Subdomain wordlist for active brute forcing
├── templates/
│   ├── starter.yaml       ← Skeleton template for the hands-on exercise
│   └── examples/          ← Completed example templates
└── scripts/
    └── verify-setup.sh    ← Checks your tool installation
```

---

## 🔗 Resources

| Resource | Link |
|---|---|
| ProjectDiscovery Docs | https://docs.projectdiscovery.io |
| Nuclei Templates Repo | https://github.com/projectdiscovery/nuclei-templates |
| PDCP (Cloud Platform) | https://cloud.projectdiscovery.io |
| Neo (AI Pentesting) | https://neo.projectdiscovery.io |
| PD Community Discord | https://discord.gg/projectdiscovery |
| Template Writing Guide | https://docs.projectdiscovery.io/templates/introduction |

---

## 🛠️ Troubleshooting

**"command not found" after installing:**
Make sure `$GOPATH/bin` is in your PATH:
```bash
export PATH=$PATH:$(go env GOPATH)/bin
```
Add this to your `.bashrc` or `.zshrc` to make it permanent.

**Nuclei templates not found:**
Update templates:
```bash
nuclei -update-templates
```

**naabu requires root/sudo for SYN scans:**
Run with sudo, or use connect scan mode:
```bash
sudo naabu -host target.com
# or
naabu -host target.com -scan-type c
```

**Can't reach the target:**
Check that DNS resolves:
```bash
dig portal.spaceballscorp.com
```
If you're on conference WiFi and it's not resolving, try switching to `8.8.8.8` or `1.1.1.1` for DNS.

---

**Workshop by Patrick Gleason & Avery Neims — HTH 2026**
*Patrick Gleason — Solutions Engineer, ProjectDiscovery*
*Avery Neims — Account Executive, ProjectDiscovery*

*"We are all hackers. Always learning, but with something to share."*
