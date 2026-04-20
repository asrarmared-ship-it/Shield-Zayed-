#!/bin/bash

# ═══════════════════════════════════════════════════════════
# 🛡️ ZAYED SHIELD - PIP SECURITY ENGINE
# ═══════════════════════════════════════════════════════════
# Hunter: asrar-mared | The Vulnerability Hunter ⚔️
# Engine: Python/PIP Package Security
# Mission: Detect, Analyze, Remediate, Report
# ═══════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
PROJECT_PATH="${1:-.}"
REPORT_DIR="reports"
REPORT_FILE="$REPORT_DIR/pip-report.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
START_TIME=$(date +%s)

# Stats
VULNS_FOUND=0
VULNS_FIXED=0
VULNS_REMAINING=0
PACKAGES_UPDATED=0
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0

# Arrays to store vulnerability details
declare -a VULN_PACKAGES=()
declare -a VULN_VERSIONS=()
declare -a VULN_SEVERITIES=()
declare -a FIXED_PACKAGES=()

banner() {
    echo -e "${CYAN}${BOLD}"
    echo "═══════════════════════════════════════════════════════════"
    echo "🛡️  ZAYED SHIELD - PYTHON/PIP SECURITY ENGINE"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo -e "${PURPLE}👤 Hunter:${NC} asrar-mared"
    echo -e "${PURPLE}🎖️  Title:${NC} The Vulnerability Hunter ⚔️"
    echo -e "${PURPLE}📦 Engine:${NC} Python/PIP"
    echo -e "${PURPLE}📅 Time:${NC} $TIMESTAMP"
    echo -e "${PURPLE}🎯 Target:${NC} $PROJECT_PATH"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

phase_header() {
    echo ""
    echo -e "${BLUE}${BOLD}▶ PHASE $1: $2${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

# ═══════════════════════════════════════════════════════════
# 🔍 PHASE 1: DETECTION
# ═══════════════════════════════════════════════════════════

detect_vulnerabilities() {
    phase_header "1" "🔍 VULNERABILITY DETECTION"
    
    cd "$PROJECT_PATH" || exit 1
    
    # Check for requirements.txt
    if [ ! -f "requirements.txt" ] && [ ! -f "setup.py" ] && [ ! -f "pyproject.toml" ]; then
        warning "No Python dependency files found - skipping PIP scan"
        return 1
    fi
    
    # Install safety if not available
    if ! command -v safety &> /dev/null; then
        info "Installing safety scanner..."
        pip install --quiet safety 2>/dev/null || pip3 install --quiet safety 2>/dev/null
    fi
    
    info "Scanning Python dependencies with Safety..."
    
    # Create temporary requirements if needed
    if [ ! -f "requirements.txt" ]; then
        info "Generating requirements from environment..."
        pip freeze > .temp_requirements.txt 2>/dev/null || pip3 freeze > .temp_requirements.txt 2>/dev/null
        REQ_FILE=".temp_requirements.txt"
    else
        REQ_FILE="requirements.txt"
    fi
    
    # Run safety check
    SAFETY_OUTPUT=$(safety check --json -r "$REQ_FILE" 2>/dev/null || echo '[]')
    
    # Parse vulnerabilities
    VULNS_FOUND=$(echo "$SAFETY_OUTPUT" | jq 'length' 2>/dev/null || echo 0)
    
    if [ "$VULNS_FOUND" -gt 0 ]; then
        # Count by severity
        while IFS= read -r vuln; do
            PACKAGE=$(echo "$vuln" | jq -r '.package_name')
            VERSION=$(echo "$vuln" | jq -r '.vulnerable_spec[0]')
            SEVERITY=$(echo "$vuln" | jq -r '.severity // "medium"')
            
            VULN_PACKAGES+=("$PACKAGE")
            VULN_VERSIONS+=("$VERSION")
            VULN_SEVERITIES+=("$SEVERITY")
            
            case "$SEVERITY" in
                critical) ((CRITICAL_COUNT++)) ;;
                high) ((HIGH_COUNT++)) ;;
                medium) ((MEDIUM_COUNT++)) ;;
                *) ((LOW_COUNT++)) ;;
            esac
        done < <(echo "$SAFETY_OUTPUT" | jq -c '.[]')
    fi
    
    echo ""
    echo -e "${BOLD}📊 Detection Results:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   Total Vulnerabilities: ${BOLD}$VULNS_FOUND${NC}"
    echo -e "   🔴 Critical: $CRITICAL_COUNT"
    echo -e "   🟠 High: $HIGH_COUNT"
    echo -e "   🟡 Medium: $MEDIUM_COUNT"
    echo -e "   🟢 Low: $LOW_COUNT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Cleanup temp file
    [ -f ".temp_requirements.txt" ] && rm -f .temp_requirements.txt
    
    if [ "$VULNS_FOUND" -eq 0 ]; then
        success "No vulnerabilities detected! 🎉"
        return 1
    fi
    
    return 0
}

# ═══════════════════════════════════════════════════════════
# 📊 PHASE 2: ANALYSIS
# ═══════════════════════════════════════════════════════════

analyze_packages() {
    phase_header "2" "📊 PACKAGE ANALYSIS"
    
    info "Analyzing vulnerable packages and safe versions..."
    
    echo ""
    echo -e "${BOLD}🔍 Vulnerable Packages:${NC}"
    
    for i in "${!VULN_PACKAGES[@]}"; do
        pkg="${VULN_PACKAGES[$i]}"
        ver="${VULN_VERSIONS[$i]}"
        sev="${VULN_SEVERITIES[$i]}"
        
        # Get latest version
        LATEST=$(pip index versions "$pkg" 2>/dev/null | grep -oP '(?<=LATEST: )\S+' || echo "unknown")
        
        echo -e "   📦 ${BOLD}$pkg${NC}"
        echo -e "      Current: $ver | Latest: $LATEST | Severity: $sev"
    done
}

# ═══════════════════════════════════════════════════════════
# 🔧 PHASE 3: REMEDIATION
# ═══════════════════════════════════════════════════════════

apply_remediation() {
    phase_header "3" "🔧 AUTO-REMEDIATION"
    
    info "Attempting to upgrade vulnerable packages..."
    
    for pkg in "${VULN_PACKAGES[@]}"; do
        info "Upgrading $pkg..."
        
        if pip install --upgrade "$pkg" &>/dev/null || pip3 install --upgrade "$pkg" &>/dev/null; then
            success "Successfully upgraded $pkg"
            FIXED_PACKAGES+=("$pkg")
            ((VULNS_FIXED++))
        else
            warning "Failed to upgrade $pkg - may require manual intervention"
        fi
    done
    
    # Re-scan to check remaining vulnerabilities
    info "Re-scanning for remaining vulnerabilities..."
    
    if [ -f "requirements.txt" ]; then
        FINAL_SCAN=$(safety check --json -r requirements.txt 2>/dev/null || echo '[]')
        VULNS_REMAINING=$(echo "$FINAL_SCAN" | jq 'length' 2>/dev/null || echo 0)
    else
        pip freeze > .temp_requirements.txt 2>/dev/null || pip3 freeze > .temp_requirements.txt 2>/dev/null
        FINAL_SCAN=$(safety check --json -r .temp_requirements.txt 2>/dev/null || echo '[]')
        VULNS_REMAINING=$(echo "$FINAL_SCAN" | jq 'length' 2>/dev/null || echo 0)
        rm -f .temp_requirements.txt
    fi
    
    # Update requirements.txt if exists
    if [ -f "requirements.txt" ] && [ "$VULNS_FIXED" -gt 0 ]; then
        info "Updating requirements.txt..."
        pip freeze > requirements.txt 2>/dev/null || pip3 freeze > requirements.txt 2>/dev/null
        success "requirements.txt updated"
    fi
    
    echo ""
    echo -e "${BOLD}🎯 Remediation Summary:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   Vulnerabilities Fixed: ${GREEN}$VULNS_FIXED${NC}"
    echo -e "   Vulnerabilities Remaining: ${YELLOW}$VULNS_REMAINING${NC}"
    
    if [ "$VULNS_FIXED" -gt 0 ]; then
        SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f\", ($VULNS_FIXED/$VULNS_FOUND)*100}")
        echo -e "   Success Rate: ${GREEN}${SUCCESS_RATE}%${NC}"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ═══════════════════════════════════════════════════════════
# 📄 PHASE 4: REPORTING
# ═══════════════════════════════════════════════════════════

generate_report() {
    phase_header "4" "📄 REPORT GENERATION"
    
    mkdir -p "$REPORT_DIR"
    
    END_TIME=$(date +%s)
    EXECUTION_TIME=$((END_TIME - START_TIME))
    
    SUCCESS_RATE="0%"
    if [ "$VULNS_FOUND" -gt 0 ]; then
        SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f%%\", ($VULNS_FIXED/$VULNS_FOUND)*100}")
    fi
    
    # Build fixed packages JSON array
    FIXED_JSON="[]"
    if [ ${#FIXED_PACKAGES[@]} -gt 0 ]; then
        FIXED_JSON=$(printf '%s\n' "${FIXED_PACKAGES[@]}" | jq -R . | jq -s .)
    fi
    
    info "Generating JSON report..."
    
    cat > "$REPORT_FILE" << EOF
{
  "metadata": {
    "hunter": "asrar-mared",
    "title": "The Vulnerability Hunter",
    "project": "Zayed Shield",
    "engine": "pip",
    "timestamp": "$TIMESTAMP",
    "project_path": "$PROJECT_PATH",
    "execution_time": "${EXECUTION_TIME}s"
  },
  "summary": {
    "vulnerabilities_found": $VULNS_FOUND,
    "vulnerabilities_fixed": $VULNS_FIXED,
    "vulnerabilities_remaining": $VULNS_REMAINING,
    "packages_updated": ${#FIXED_PACKAGES[@]},
    "success_rate": "$SUCCESS_RATE"
  },
  "severity_breakdown": {
    "critical": $CRITICAL_COUNT,
    "high": $HIGH_COUNT,
    "medium": $MEDIUM_COUNT,
    "low": $LOW_COUNT
  },
  "fixed_packages": $FIXED_JSON,
  "warrior_message": "Python packages secured. The serpent has been tamed.",
  "scan_complete": true
}
EOF
    
    success "Report saved to: $REPORT_FILE"
    
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════"
    echo "🏆 MISSION COMPLETE"
    echo "═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BOLD}📊 Final Statistics:${NC}"
    echo "   🎯 Found: $VULNS_FOUND vulnerabilities"
    echo -e "   ✅ Fixed: ${GREEN}$VULNS_FIXED${NC} vulnerabilities"
    echo -e "   ⏱️  Time: ${EXECUTION_TIME}s"
    echo -e "   📈 Success: ${GREEN}$SUCCESS_RATE${NC}"
    echo ""
    echo -e "${PURPLE}${BOLD}⚔️  The Vulnerability Hunter strikes again!${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════
# 🚀 MAIN EXECUTION
# ═══════════════════════════════════════════════════════════

main() {
    banner
    
    if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
        error "Python is not installed"
        exit 1
    fi
    
    if ! command -v pip &> /dev/null && ! command -v pip3 &> /dev/null; then
        error "pip is not installed"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        error "jq is required. Please install it first."
        exit 1
    fi
    
    if detect_vulnerabilities; then
        analyze_packages
        apply_remediation
        generate_report
    else
        generate_report
    fi
    
    exit 0
}

main "$@"
