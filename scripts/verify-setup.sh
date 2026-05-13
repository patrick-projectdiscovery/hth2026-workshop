#!/bin/bash
# verify-setup.sh — Check that all required tools are installed for the workshop
# Run: chmod +x verify-setup.sh && ./verify-setup.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  HTH 2026 Workshop — Setup Verification     ║"
echo "  ║  From Recon to Remediation with PD           ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

PASS=0
FAIL=0
WARN=0

check_tool() {
  local name=$1
  local cmd=$2
  local required=$3

  if command -v "$cmd" &> /dev/null; then
    VERSION=$($cmd -version 2>/dev/null | head -1)
    echo -e "  ${GREEN}[✓]${NC} ${BOLD}$name${NC} — $VERSION"
    PASS=$((PASS + 1))
  elif [ "$required" = "required" ]; then
    echo -e "  ${RED}[✗]${NC} ${BOLD}$name${NC} — NOT FOUND"
    FAIL=$((FAIL + 1))
  else
    echo -e "  ${YELLOW}[~]${NC} ${BOLD}$name${NC} — not found (optional)"
    WARN=$((WARN + 1))
  fi
}

echo -e "${YELLOW}Checking required tools...${NC}"
echo ""
check_tool "subfinder" "subfinder" "required"
check_tool "httpx" "httpx" "required"
check_tool "nuclei" "nuclei" "required"

echo ""
echo -e "${YELLOW}Checking recommended tools...${NC}"
echo ""
check_tool "naabu" "naabu" "optional"
check_tool "katana" "katana" "optional"
check_tool "dnsx" "dnsx" "optional"
check_tool "cloudlist" "cloudlist" "optional"

echo ""
echo -e "${YELLOW}Checking general dependencies...${NC}"
echo ""
check_tool "Go" "go" "optional"
check_tool "curl" "curl" "required"
check_tool "Docker" "docker" "optional"
check_tool "git" "git" "optional"

# Check if nuclei templates are present
echo ""
echo -e "${YELLOW}Checking Nuclei templates...${NC}"
echo ""
TEMPLATE_COUNT=$(nuclei -tl 2>/dev/null | wc -l)
if [ "$TEMPLATE_COUNT" -gt 100 ]; then
  echo -e "  ${GREEN}[✓]${NC} ${BOLD}Nuclei templates${NC} — $TEMPLATE_COUNT templates loaded"
  PASS=$((PASS + 1))
elif [ "$TEMPLATE_COUNT" -gt 0 ]; then
  echo -e "  ${YELLOW}[~]${NC} ${BOLD}Nuclei templates${NC} — only $TEMPLATE_COUNT loaded (run: nuclei -update-templates)"
  WARN=$((WARN + 1))
else
  echo -e "  ${RED}[✗]${NC} ${BOLD}Nuclei templates${NC} — none found (run: nuclei -update-templates)"
  FAIL=$((FAIL + 1))
fi

# Check target reachability
echo ""
echo -e "${YELLOW}Checking target reachability...${NC}"
echo ""
for sub in "" "portal." "admin." "docs." "api." "staging."; do
  HOST="${sub}spaceballscorp.com"
  CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "https://${HOST}" 2>/dev/null)
  if [ "$CODE" -gt 0 ] && [ "$CODE" -lt 500 ]; then
    echo -e "  ${GREEN}[✓]${NC} ${BOLD}${HOST}${NC} — HTTP $CODE"
  else
    echo -e "  ${RED}[✗]${NC} ${BOLD}${HOST}${NC} — unreachable (HTTP $CODE)"
  fi
done

# Summary
echo ""
echo "  ──────────────────────────────────────────────"
echo -e "  ${GREEN}Passed: $PASS${NC}  ${RED}Failed: $FAIL${NC}  ${YELLOW}Warnings: $WARN${NC}"
echo "  ──────────────────────────────────────────────"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo -e "  ${GREEN}${BOLD}You're ready for the workshop!${NC} 🚀"
else
  echo -e "  ${RED}${BOLD}Some required tools are missing.${NC}"
  echo ""
  echo "  Quick fix — install everything with PDTM:"
  echo "    go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest"
  echo "    pdtm -install-all"
  echo ""
  echo "  Or install individually — see README.md for details."
fi
echo ""
