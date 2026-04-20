# Warrior Dashboard
### Personal Security Operations & Contribution Intelligence Platform

**Author** : nike4565 — Independent Security Researcher
**Contact** : nike49424@gmail.com · 
**GPG Key** : 8429D4C1ECAC3080BCB84AA0982159B70BA77EFD
**Dedicated to** : United Arab Emirates 🇦🇪

---

## What Is This

Warrior Dashboard is a personal operations center that runs across all environments — Linux, Android (Termux), ChromeOS (Crostini) — giving a single unified view of security research activity, GitHub contributions, vulnerability scan results, and daily statistics.

It is not a public product. It is a private intelligence layer built specifically for one researcher's workflow.

---

## What It Does

The dashboard operates across four functional domains:

---

### 1. Contribution & PR Tracking

Monitors all activity across every GitHub account associated with this researcher.

**Tracked accounts:**
- nike4565 — active primary account
- asrar-mared— archived, contributions still visible

**What it tracks:**

| Signal | Detail |
|--------|--------|
| Pull Requests | Open, merged, closed — per repo and globally |
| Advisory contributions | PRs submitted to `github/advisory-database |
| Commit history | Per branch, per repo, with GPG signature status |
| Credit attribution | Tracks asrar-mared appearances in advisory JSON files |
| GHSA coverage | Lists all GHSA IDs where the researcher is credited |

**Sample daily output:**
```
[2026-03-16]  Contributions Summary
──────────────────────────────────────
PRs merged today    :  3
Open PRs            :  7
Advisory credits    : 49  (cumulative)
CVEs mapped         :  5
Repos active        :  4
Last commit         : 14 minutes ago
```

---

### 2. Automated Vulnerability Scanning

Runs scheduled scans against the local environment and tracked repositories to detect and log security issues before they become incidents.

**Scan targets:**

| Target | Tool | Schedule |
|--------|------|----------|
| Local filesystem | Trivy | Every 6 hours |
| Bash scripts | ShellCheck | On every file change |
| NPM dependencies | npm audit | Daily |
| Secrets in code | Gitleaks + TruffleHog | Every push |
| OWASP dependencies | dependency-check | Weekly |
| IP reputation | MXToolbox API | Daily |
| Credential leaks | HaveIBeenPwned API | Daily |

**Severity levels tracked:**

```
CRITICAL  ████████████████████  immediate action required
HIGH      ████████████░░░░░░░░  action within 24 hours
MEDIUM    ████████░░░░░░░░░░░░  scheduled remediation
LOW       ████░░░░░░░░░░░░░░░░  logged, monitored
```

**Output format:**
```
[SCAN]  2026-03-16 06:00 UTC
────────────────────────────────────
CRITICAL  :  0
HIGH      :  2  → npm package: lodash@4.17.20, path-to-regexp@0.1.7
MEDIUM    :  5
LOW       : 11
────────────────────────────────────
Action    :  2 packages queued for auto-fix
```

---

### 3. Repository & Branch Management

Provides a live map of all repositories, their branch status, pipeline health, and sync state with upstream remotes.

**Tracked repositories:**

```
nike4565/Zayed-Shield
  ├── main          [clean]  [GPG signed]  [CI: passing]
  ├── develop       [2 ahead of main]
  └── release/v1.1.1  [tagged]  [SLSA3 provenance: verified]

nike4565/GLOBAL-ADVISORY-ARCHIVE
  └── main          [clean]  [49 PR records]

nike4565/warrior-security-advisories
  └── main          [clean]  [disclosure timeline: active]

github/advisory-database  (upstream fork)
  └── main          [sync status: up to date]
      last sync: 2026-03-16 05:45 UTC
```

**Branch health signals:**

| Signal | Meaning |
|--------|---------|
| `[clean]` | No uncommitted changes, no divergence |
| `[N ahead]` | Local branch has unpushed commits |
| `[diverged]` | Local and remote have split history |
| `[CI: passing]` | GitHub Actions pipeline green |
| `[CI: failing]` | Pipeline failure — details in log |
| `[GPG signed]` | All commits carry valid GPG signature |

**Branch operations available:**
- Force-sync fork to upstream
- Create dated release branch
- Archive stale branches
- Validate all YAML workflow files before push

---

### 4. Daily Reports & Statistics

Generates a structured daily intelligence report covering all activity from the past 24 hours. Report is written to `~/warrior-dashboard/reports/YYYY-MM-DD.md` and optionally pushed to a private reporting repo.

**Report structure:**

```markdown
# Warrior Dashboard — Daily Report
Date     : 2026-03-16
Operator : nike4565

## Activity
- Commits pushed      : 7
- PRs opened          : 2
- PRs merged          : 3
- Advisories enriched : 4
- Scans completed     : 6

## Vulnerability Summary
- New findings        : 2 HIGH
- Remediated today    : 5
- Cumulative open     : 3

## Repository Status
- All repos clean     : YES
- CI pipelines green  : 3/4  (1 warning — Node version)
- GPG coverage        : 100%

## CVE Tracker
CVE-2025-13952  → PR #6806  [merged]
CVE-2025-67847  → PR #6799  [merged]
CVE-2021-23318  → PR #6726  [merged]

## Notes
(free-form daily log — added manually or by script)
```

**Cumulative statistics (lifetime):**

| Metric | Value |
|--------|-------|
| Critical vulnerabilities documented | 119+ |
| Pull requests merged | 49+ |
| CVEs directly mapped | 5 |
| GHSA advisories credited | 25+ |
| Days of continuous contribution | tracked from Feb 2026 |
| GPG-signed commits | 100% |

---

## Environment Compatibility

| Environment | Status | Notes |
|-------------|--------|-------|
| Ubuntu / Kali Linux | Full support | Primary environment |
| ChromeOS — Crostini (Debian) | Full support | Secondary environment |
| Android — Termux | Full support | Mobile operations |
| GitHub Actions (CI) | Full support | Automated pipeline mode |

---

## File Structure

```
warrior-dashboard/
├── dashboard.sh              # Main entry point
├── modules/
│   ├── contributions.sh      # PR and commit tracking
│   ├── scan.sh               # Vulnerability scanning
│   ├── repos.sh              # Repository and branch management
│   └── report.sh             # Daily report generator
├── config/
│   ├── accounts.conf         # GitHub accounts to monitor
│   ├── repos.conf            # Repositories to track
│   └── schedule.conf         # Scan intervals and thresholds
├── reports/                  # Daily report archive
│   └── YYYY-MM-DD.md
├── logs/                     # Raw operation logs
│   └── dashboard-YYYYMMDD.log
└── README.md                 # This file
```

---

## Usage

```bash
# Full dashboard run
./dashboard.sh

# Individual modules
./modules/contributions.sh    # PR and advisory tracking only
./modules/scan.sh             # Run all scans
./modules/repos.sh            # Check repo and branch status
./modules/report.sh           # Generate today's report

# Automated mode (cron / silent)
./dashboard.sh --auto

# View latest report
cat reports/$(date +%Y-%m-%d).md
```

**Cron registration (6-hour cycle):**
```bash
0 */6 * * * cd ~/warrior-dashboard && ./dashboard.sh --auto >> logs/cron.log 2>&1
```

---

## Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| `git` | Repository operations | `apt install git` |
| `gh` | GitHub CLI — PR submission | `apt install gh` |
| `jq` | JSON parsing for advisories | `apt install jq` |
| `curl` | API calls | `apt install curl` |
| `gpg` | Commit signing | `apt install gnupg` |
| `shellcheck` | Bash static analysis | `apt install shellcheck` |
| `trivy` | Filesystem vulnerability scan | [aquasecurity/trivy](https://github.com/aquasecurity/trivy) |
| `gitleaks` | Secret scanning | [gitleaks/gitleaks](https://github.com/gitleaks/gitleaks) |
| `npm` | Dependency audit | `apt install nodejs npm` |

---

## Identity

```
Operator  : nike4565
Alias     : Warrior
Previous  : asrar-mared
GPG Key   : 8429D4C1ECAC3080BCB84AA0982159B70BA77EFD
Key Type  : RSA 4096-bit
Created   : February 2026
Email     : nike49424@gmail.com
ProtonMail: nike49424@proton.me
Web       : nike49424.live
ENS       : nike49424.eth
```

---

## Related Projects

| Project | Description |
|---------|-------------|
| [Zayed Shield](https://github.com/nike4565/Zayed-Shield) | Core 9-stage vulnerability remediation engine |
| [GLOBAL-ADVISORY-ARCHIVE](https://github.com/nike4565/GLOBAL-ADVISORY-ARCHIVE) | Full archive of all CVE research and advisory work |
| [warrior-security-advisories](https://github.com/nike4565/warrior-security-advisories) | Independent disclosure timeline |

---

*Warrior Dashboard — built for one operator, running everywhere.*
*Dedicated to the United Arab Emirates 🇦🇪*
*In tribute to Sheikh Zayed bin Sultan Al Nahyan.*
