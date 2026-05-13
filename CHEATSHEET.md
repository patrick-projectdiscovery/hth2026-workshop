# ProjectDiscovery Pipeline Cheatsheet
### HTH 2026 — From Recon to Remediation

---

## The Pipeline

```
Discover        Resolve        Scan          Probe         Crawl          Detect
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ Subfinder │──▶│   dnsx   │──▶│  Naabu   │──▶│  httpx   │──▶│  Katana  │──▶│  Nuclei  │
│           │   │          │   │          │   │          │   │          │   │          │
│subdomains │   │   DNS    │   │  ports   │   │  HTTP    │   │  crawl   │   │  vulns   │
└──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
```

---

## Core Commands

### Subdomain Discovery

**Step 1 — Passive recon (try this first):**
```bash
subfinder -d spaceballscorp.com -silent
```
> New domains can lag in CT logs. If you get no output, that's expected — move to Step 2.

**Step 2 — Active brute force with a wordlist:**
```bash
dnsx -d spaceballscorp.com -w subs-wordlist.txt -silent -resp
```
`-resp` shows the resolved IP so you can see which names are live vs. NXDOMAIN at a glance.

**Step 3 — Pipe live hosts straight into httpx:**
```bash
dnsx -d spaceballscorp.com -w subs-wordlist.txt -silent | httpx -silent -title -status-code -tech-detect
```

### Port Scanning
```bash
# Fast SYN scan (requires sudo)
sudo naabu -host portal.spaceballscorp.com -silent

# Top 100 ports
sudo naabu -host portal.spaceballscorp.com -top-ports 100

# Specific ports
naabu -host portal.spaceballscorp.com -p 80,443,8080,8443
```

### HTTP Probing
```bash
# Probe live hosts with metadata (passive discovery)
subfinder -d spaceballscorp.com -silent | httpx -silent -title -status-code -tech-detect

# Probe live hosts with metadata (active brute force)
dnsx -d spaceballscorp.com -w subs-wordlist.txt -silent | httpx -silent -title -status-code -tech-detect

# Just the live URLs
dnsx -d spaceballscorp.com -w subs-wordlist.txt -silent | httpx -silent
```

### Crawling
```bash
# Crawl a target, depth 3
echo https://portal.spaceballscorp.com | katana -silent -d 3

# Crawl and extract JS files
echo https://portal.spaceballscorp.com | katana -silent -jc
```

### Vulnerability Scanning
```bash
# Full pipeline: discover → probe → scan
subfinder -d spaceballscorp.com -silent | httpx -silent | nuclei -silent

# Scan a single URL
nuclei -u https://portal.spaceballscorp.com -silent

# Scan with specific template tags
nuclei -u https://staging.spaceballscorp.com -tags exposure,config -silent

# Scan with your custom template
nuclei -u https://staging.spaceballscorp.com -t ./my-template.yaml
```

> **Template exercise:** `staging.spaceballscorp.com` is your target for the hands-on exercise. Found something interesting there during recon? That's what you're detecting. Open `templates/starter.yaml` and build a template for it.

### Cloud Asset Discovery
```bash
# Pull assets from cloud providers
# Requires cloud provider credentials to be configured — see PDCP for cloud asset import
cloudlist -provider aws,gcp,azure

# Chain into the pipeline
cloudlist | httpx | nuclei
```

---

## Composing Pipelines

The power is in recombination. Mix and match:

```bash
# Classic full chain (passive)
subfinder -d target.com | dnsx | httpx | nuclei

# Active brute force chain (use when CT logs are cold)
dnsx -d target.com -w subs-wordlist.txt | httpx | nuclei

# Cloud assets instead of subdomains
cloudlist | httpx | nuclei

# Crawl then scan (find hidden endpoints)
echo https://target.com | katana -d 3 | nuclei

# Port scan then probe
echo target.com | naabu -silent | httpx -silent | nuclei

# Save results at each step
subfinder -d target.com -o subs.txt
cat subs.txt | httpx -o live.txt
cat live.txt | nuclei -o findings.txt
```

---

## Nuclei Template Syntax

```yaml
id: template-id-here              # Unique identifier

info:
  name: Human-Readable Name       # What this detects
  author: your-handle              # You
  severity: high                   # info, low, medium, high, critical
  description: What this finds     # Brief explanation
  tags: config,exposure            # For filtering

http:
  - method: GET                    # HTTP method
    path:
      - "{{BaseURL}}/target/path"  # URL to hit (BaseURL = target)

    matchers-condition: and        # and = ALL must match, or = ANY
    matchers:
      - type: status               # Match HTTP status code
        status:
          - 200

      - type: word                 # Match text in response
        words:
          - "secret_key"
          - "password"
        condition: or              # Either word triggers

      - type: regex                # Match pattern
        regex:
          - "AKIA[A-Z0-9]{16}"    # AWS access key pattern

    extractors:                    # Pull data out of response
      - type: regex
        regex:
          - '"secret_key":\s*"([^"]+)"'
```

### Matcher Types
| Type | Use For | Example |
|---|---|---|
| `status` | HTTP status codes | `status: [200, 301]` |
| `word` | Exact text match | `words: ["admin", "root"]` |
| `regex` | Pattern match | `regex: ["token=[a-f0-9]{32}"]` |
| `size` | Response size | `size: [0]` (empty response) |
| `binary` | Binary content | Hex patterns |
| `dsl` | Complex logic | `dsl: ["status_code == 200 && contains(body, 'admin')"]` |

### Variables
| Variable | Value |
|---|---|
| `{{BaseURL}}` | Full target URL (https://target.com) |
| `{{RootURL}}` | Target root URL |
| `{{Hostname}}` | Just the hostname |
| `{{Host}}` | Hostname:port |
| `{{Path}}` | URL path |
| `{{Port}}` | Port number |
| `{{Scheme}}` | http or https |

---

## Useful Flags

### Subfinder
| Flag | Purpose |
|---|---|
| `-d` | Target domain |
| `-silent` | Clean output (just results) |
| `-o` | Output file |
| `-all` | Use all sources |
| `-recursive` | Recursive subdomain enum |

### httpx
| Flag | Purpose |
|---|---|
| `-silent` | Clean output |
| `-status-code` | Show HTTP status |
| `-title` | Show page title |
| `-tech-detect` | Fingerprint tech stack |
| `-content-length` | Show response size |
| `-follow-redirects` | Follow HTTP redirects |
| `-mc 200` | Match only status 200 |

### Nuclei
| Flag | Purpose |
|---|---|
| `-u` | Single target URL |
| `-l` | List of targets file |
| `-t` | Custom template path |
| `-tags` | Filter by template tags |
| `-severity` | Filter by severity |
| `-silent` | Minimal output |
| `-o` | Output file |
| `-update-templates` | Pull latest templates |

---

## Target: Spaceballs Galactic Defense Corp

| Subdomain | What's There |
|---|---|
| `spaceballscorp.com` | Corporate site |
| `portal.spaceballscorp.com` | Employee portal (login) |
| `admin.spaceballscorp.com` | Admin panel |
| `api.spaceballscorp.com` | REST API |
| `docs.spaceballscorp.com` | API docs (Swagger) |
| `staging.spaceballscorp.com` | "Forgotten" staging |

### Accounts
| User | Pass | Role |
|---|---|---|
| `lone_starr` | `12345` | Employee |

---

## Links

| | |
|---|---|
| **This Repo** | github.com/patrick-projectdiscovery/hth2026-workshop |
| **PD Docs** | docs.projectdiscovery.io |
| **Nuclei Templates** | github.com/projectdiscovery/nuclei-templates |
| **PDCP** | cloud.projectdiscovery.io |
| **Neo** | neo.projectdiscovery.io |
| **PD Discord** | discord.gg/projectdiscovery |
