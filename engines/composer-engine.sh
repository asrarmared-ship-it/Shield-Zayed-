#!/bin/bash
# ═══════════════════════════════════════════════════════════
# 🛡️ ZAYED SHIELD - COMPOSER SECURITY ENGINE (PHP)
# ═══════════════════════════════════════════════════════════
# Save as: engines/composer-engine.sh

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
NC='\033[0m'; BOLD='\033[1m'

PROJECT_PATH="${1:-.}"
REPORT_DIR="reports"
REPORT_FILE="$REPORT_DIR/composer-report.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
START_TIME=$(date +%s)

VULNS_FOUND=0; VULNS_FIXED=0; VULNS_REMAINING=0; PACKAGES_UPDATED=0
CRITICAL_COUNT=0; HIGH_COUNT=0; MEDIUM_COUNT=0; LOW_COUNT=0

banner() {
    echo -e "${CYAN}${BOLD}"
    echo "═══════════════════════════════════════════════════════════"
    echo "🛡️  ZAYED SHIELD - COMPOSER/PHP SECURITY ENGINE"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo -e "${PURPLE}👤 Hunter:${NC} asrar-mared - The Vulnerability Hunter ⚔️"
    echo -e "${PURPLE}📦 Engine:${NC} Composer/PHP | ${PURPLE}📅 Time:${NC} $TIMESTAMP"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

phase() { echo ""; echo -e "${BLUE}${BOLD}▶ PHASE $1: $2${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

detect_vulnerabilities() {
    phase "1" "🔍 VULNERABILITY DETECTION"
    cd "$PROJECT_PATH" || exit 1
    
    if [ ! -f "composer.json" ]; then
        warning "No composer.json found - skipping"
        return 1
    fi
    
    info "Running composer audit..."
    AUDIT=$(composer audit --format=json 2>/dev/null || echo '{"advisories":{}}')
    
    VULNS_FOUND=$(echo "$AUDIT" | jq '.advisories | length' 2>/dev/null || echo 0)
    
    if [ "$VULNS_FOUND" -gt 0 ]; then
        while IFS= read -r adv; do
            SEV=$(echo "$adv" | jq -r '.severity // "medium"')
            case "$SEV" in
                critical) ((CRITICAL_COUNT++)) ;;
                high) ((HIGH_COUNT++)) ;;
                medium) ((MEDIUM_COUNT++)) ;;
                *) ((LOW_COUNT++)) ;;
            esac
        done < <(echo "$AUDIT" | jq -c '.advisories[]')
    fi
    
    echo ""; echo -e "${BOLD}📊 Detection Results:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   Total Vulnerabilities: ${BOLD}$VULNS_FOUND${NC}"
    echo -e "   🔴 Critical: $CRITICAL_COUNT | 🟠 High: $HIGH_COUNT"
    echo -e "   🟡 Medium: $MEDIUM_COUNT | 🟢 Low: $LOW_COUNT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    [ "$VULNS_FOUND" -eq 0 ] && { success "No vulnerabilities! 🎉"; return 1; }
    return 0
}

analyze_packages() {
    phase "2" "📊 PACKAGE ANALYSIS"
    info "Checking for outdated packages..."
    composer outdated --direct 2>/dev/null || true
}

apply_remediation() {
    phase "3" "🔧 AUTO-REMEDIATION"
    info "Updating vulnerable packages..."
    
    if composer update --with-all-dependencies &>/dev/null; then
        success "Packages updated successfully"
        ((PACKAGES_UPDATED++))
    else
        warning "Some packages require manual update"
    fi
    
    AUDIT_NEW=$(composer audit --format=json 2>/dev/null || echo '{"advisories":{}}')
    VULNS_REMAINING=$(echo "$AUDIT_NEW" | jq '.advisories | length' 2>/dev/null || echo 0)
    VULNS_FIXED=$((VULNS_FOUND - VULNS_REMAINING))
    
    echo ""; echo -e "${BOLD}🎯 Remediation Summary:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   Fixed: ${GREEN}$VULNS_FIXED${NC} | Remaining: ${YELLOW}$VULNS_REMAINING${NC}"
    [ "$VULNS_FIXED" -gt 0 ] && SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f%%\", ($VULNS_FIXED/$VULNS_FOUND)*100}") && echo -e "   Success: ${GREEN}$SUCCESS_RATE${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

generate_report() {
    phase "4" "📄 REPORT GENERATION"
    mkdir -p "$REPORT_DIR"
    
    END_TIME=$(date +%s); EXEC_TIME=$((END_TIME - START_TIME))
    SUCCESS_RATE="0%"
    [ "$VULNS_FOUND" -gt 0 ] && SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f%%\", ($VULNS_FIXED/$VULNS_FOUND)*100}")
    
    cat > "$REPORT_FILE" << EOF
{
  "metadata": {
    "hunter": "asrar-mared",
    "title": "The Vulnerability Hunter",
    "project": "Zayed Shield",
    "engine": "composer",
    "timestamp": "$TIMESTAMP",
    "execution_time": "${EXEC_TIME}s"
  },
  "summary": {
    "vulnerabilities_found": $VULNS_FOUND,
    "vulnerabilities_fixed": $VULNS_FIXED,
    "vulnerabilities_remaining": $VULNS_REMAINING,
    "success_rate": "$SUCCESS_RATE"
  },
  "severity_breakdown": {
    "critical": $CRITICAL_COUNT,
    "high": $HIGH_COUNT,
    "medium": $MEDIUM_COUNT,
    "low": $LOW_COUNT
  },
  "warrior_message": "PHP packages secured. The composer conducts a symphony of security.",
  "scan_complete": true
}
EOF
    
    success "Report: $REPORT_FILE"
    echo ""; echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════"
    echo "🏆 MISSION COMPLETE - COMPOSER ENGINE"; echo "═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}📊 Stats:${NC} Found: $VULNS_FOUND | Fixed: ${GREEN}$VULNS_FIXED${NC} | Time: ${EXEC_TIME}s"
    echo -e "${PURPLE}${BOLD}⚔️  The Vulnerability Hunter strikes again!${NC}"; echo ""
}

main() {
    banner
    [ ! command -v composer &>/dev/null ] && { error "Composer not installed"; exit 1; }
    [ ! command -v jq &>/dev/null ] && { error "jq required"; exit 1; }
    detect_vulnerabilities && { analyze_packages; apply_remediation; }
    generate_report; exit 0
}

main "$@"


# ═══════════════════════════════════════════════════════════
# 🛡️ ZAYED SHIELD - CARGO SECURITY ENGINE (RUST)
# ═══════════════════════════════════════════════════════════
# Save as: engines/cargo-engine.sh
# Uncomment below and save to separate file

: << 'CARGO_ENGINE'
#!/bin/bash
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
NC='\033[0m'; BOLD='\033[1m'

PROJECT_PATH="${1:-.}"
REPORT_DIR="reports"
REPORT_FILE="$REPORT_DIR/cargo-report.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
START_TIME=$(date +%s)

VULNS_FOUND=0; VULNS_FIXED=0; VULNS_REMAINING=0; PACKAGES_UPDATED=0
CRITICAL_COUNT=0; HIGH_COUNT=0; MEDIUM_COUNT=0; LOW_COUNT=0

banner() {
    echo -e "${CYAN}${BOLD}"
    echo "═══════════════════════════════════════════════════════════"
    echo "🛡️  ZAYED SHIELD - CARGO/RUST SECURITY ENGINE"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo -e "${PURPLE}👤 Hunter:${NC} asrar-mared - The Vulnerability Hunter ⚔️"
    echo -e "${PURPLE}📦 Engine:${NC} Cargo/Rust | ${PURPLE}📅 Time:${NC} $TIMESTAMP"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

phase() { echo ""; echo -e "${BLUE}${BOLD}▶ PHASE $1: $2${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

detect_vulnerabilities() {
    phase "1" "🔍 VULNERABILITY DETECTION"
    cd "$PROJECT_PATH" || exit 1
    
    if [ ! -f "Cargo.toml" ]; then
        warning "No Cargo.toml found - skipping"
        return 1
    fi
    
    # Install cargo-audit if needed
    command -v cargo-audit &>/dev/null || { info "Installing cargo-audit..."; cargo install cargo-audit --quiet; }
    
    info "Running cargo audit..."
    AUDIT=$(cargo audit --json 2>/dev/null || echo '{"vulnerabilities":{"list":[]}}')
    
    VULNS_FOUND=$(echo "$AUDIT" | jq '.vulnerabilities.list | length' 2>/dev/null || echo 0)
    
    if [ "$VULNS_FOUND" -gt 0 ]; then
        while IFS= read -r vuln; do
            SEV=$(echo "$vuln" | jq -r '.advisory.severity // "medium"')
            case "$SEV" in
                critical) ((CRITICAL_COUNT++)) ;;
                high) ((HIGH_COUNT++)) ;;
                medium) ((MEDIUM_COUNT++)) ;;
                *) ((LOW_COUNT++)) ;;
            esac
        done < <(echo "$AUDIT" | jq -c '.vulnerabilities.list[]')
    fi
    
    echo ""; echo -e "${BOLD}📊 Detection Results:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   Total Vulnerabilities: ${BOLD}$VULNS_FOUND${NC}"
    echo -e "   🔴 Critical: $CRITICAL_COUNT | 🟠 High: $HIGH_COUNT"
    echo -e "   🟡 Medium: $MEDIUM_COUNT | 🟢 Low: $LOW_COUNT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    [ "$VULNS_FOUND" -eq 0 ] && { success "No vulnerabilities! 🎉"; return 1; }
    return 0
}

analyze_packages() {
    phase "2" "📊 PACKAGE ANALYSIS"
    info "Checking for outdated crates..."
    cargo outdated 2>/dev/null || info "Install cargo-outdated for detailed analysis"
}

apply_remediation() {
    phase "3" "🔧 AUTO-REMEDIATION"
    info "Updating vulnerable crates..."
    
    if cargo update &>/dev/null; then
        success "Cargo.lock updated"
        ((PACKAGES_UPDATED++))
    fi
    
    # Try cargo-fix for additional fixes
    info "Running cargo fix..."
    cargo fix --allow-dirty &>/dev/null || true
    
    AUDIT_NEW=$(cargo audit --json 2>/dev/null || echo '{"vulnerabilities":{"list":[]}}')
    VULNS_REMAINING=$(echo "$AUDIT_NEW" | jq '.vulnerabilities.list | length' 2>/dev/null || echo 0)
    VULNS_FIXED=$((VULNS_FOUND - VULNS_REMAINING))
    
    echo ""; echo -e "${BOLD}🎯 Remediation Summary:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   Fixed: ${GREEN}$VULNS_FIXED${NC} | Remaining: ${YELLOW}$VULNS_REMAINING${NC}"
    [ "$VULNS_FIXED" -gt 0 ] && SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f%%\", ($VULNS_FIXED/$VULNS_FOUND)*100}") && echo -e "   Success: ${GREEN}$SUCCESS_RATE${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

generate_report() {
    phase "4" "📄 REPORT GENERATION"
    mkdir -p "$REPORT_DIR"
    
    END_TIME=$(date +%s); EXEC_TIME=$((END_TIME - START_TIME))
    SUCCESS_RATE="0%"
    [ "$VULNS_FOUND" -gt 0 ] && SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f%%\", ($VULNS_FIXED/$VULNS_FOUND)*100}")
    
    cat > "$REPORT_FILE" << EOF
{
  "metadata": {
    "hunter": "asrar-mared",
    "title": "The Vulnerability Hunter",
    "project": "Zayed Shield",
    "engine": "cargo",
    "timestamp": "$TIMESTAMP",
    "execution_time": "${EXEC_TIME}s"
  },
  "summary": {
    "vulnerabilities_found": $VULNS_FOUND,
    "vulnerabilities_fixed": $VULNS_FIXED,
    "vulnerabilities_remaining": $VULNS_REMAINING,
    "success_rate": "$SUCCESS_RATE"
  },
  "severity_breakdown": {
    "critical": $CRITICAL_COUNT,
    "high": $HIGH_COUNT,
    "medium": $MEDIUM_COUNT,
    "low": $LOW_COUNT
  },
  "warrior_message": "Rust crates fortified. Memory safety and security united.",
  "scan_complete": true
}
EOF
    
    success "Report: $REPORT_FILE"
    echo ""; echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════"
    echo "🏆 MISSION COMPLETE - CARGO ENGINE"; echo "═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}📊 Stats:${NC} Found: $VULNS_FOUND | Fixed: ${GREEN}$VULNS_FIXED${NC} | Time: ${EXEC_TIME}s"
    echo -e "${PURPLE}${BOLD}⚔️  The Vulnerability Hunter strikes again!${NC}"; echo ""
}

main() {
    banner
    [ ! command -v cargo &>/dev/null ] && { error "Cargo not installed"; exit 1; }
    [ ! command -v jq &>/dev/null ] && { error "jq required"; exit 1; }
    detect_vulnerabilities && { analyze_packages; apply_remediation; }
    generate_report; exit 0
}

main "$@"
CARGO_ENGINE
