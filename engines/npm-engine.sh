#!/bin/bash

# ═══════════════════════════════════════════════════════════
# 🛡️ ZAYED SHIELD - NPM SECURITY ENGINE
# ═══════════════════════════════════════════════════════════
# Hunter: asrar-mared | The Vulnerability Hunter ⚔️
# Engine: NPM/Node.js Package Security
# Mission: Detect, Analyze, Remediate, Report
# ═══════════════════════════════════════════════════════════

set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
PROJECT_PATH="${1:-.}"
REPORT_DIR="reports"
REPORT_FILE="$REPORT_DIR/npm-report.json"
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

# ═══════════════════════════════════════════════════════════
# 🎨 DISPLAY FUNCTIONS
# ═══════════════════════════════════════════════════════════

banner() {
    echo -e "${CYAN}${BOLD}"
    echo "═══════════════════════════════════════════════════════════"
    echo "🛡️  ZAYED SHIELD - NPM SECURITY ENGINE"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo -e "${PURPLE}👤 Hunter:${NC} asrar-mared"
    echo -e "${PURPLE}🎖️  Title:${NC} The Vulnerability Hunter ⚔️"
    echo -e "${PURPLE}📦 Engine:${NC} NPM/Node.js"
    echo -e "${PURPLE}📅 Time:${NC} $TIMESTAMP"
    echo -e "${PURPLE}🎯 Target:${NC} $PROJECT_PATH"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

phase_header() {
    local phase=$1
    local desc=$2
    echo ""
    echo -e "${BLUE}${BOLD}▶ PHASE $phase: $desc${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# ═══════════════════════════════════════════════════════════
# 🔍 PHASE 1: DETECTION
# ═══════════════════════════════════════════════════════════

detect_vulnerabilities() {
    phase_header "1" "🔍 VULNERABILITY DETECTION"
    
    cd "$PROJECT_PATH" || exit 1
    
    # Check if package.json exists
    if [ ! -f "package.json" ]; then
        warning "No package.json found - skipping NPM scan"
        return 1
    fi
    
    info "Scanning NPM dependencies..."
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        info "Installing dependencies first..."
        npm install --silent 2>/dev/null || true
    fi
    
    # Run npm audit and capture output
    info "Running npm audit..."
    AUDIT_OUTPUT=$(npm audit --json 2>/dev/null || echo '{"vulnerabilities":{}}')
    
    # Parse results
    VULNS_FOUND=$(echo "$AUDIT_OUTPUT" | jq -r '.metadata.vulnerabilities.total // 0')
    CRITICAL_COUNT=$(echo "$AUDIT_OUTPUT" | jq -r '.metadata.vulnerabilities.critical // 0')
    HIGH_COUNT=$(echo "$AUDIT_OUTPUT" | jq -r '.metadata.vulnerabilities.high // 0')
    MEDIUM_COUNT=$(echo "$AUDIT_OUTPUT" | jq -r '.metadata.vulnerabilities.moderate // 0')
    LOW_COUNT=$(echo "$AUDIT_OUTPUT" | jq -r '.metadata.vulnerabilities.low // 0')
    
    echo ""
    echo -e "${BOLD}📊 Detection Results:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   Total Vulnerabilities: ${BOLD}$VULNS_FOUND${NC}"
    echo -e "   🔴 Critical: $CRITICAL_COUNT"
    echo -e "   🟠 High: $HIGH_COUNT"
    echo -e "   🟡 Medium: $MEDIUM_COUNT"
    echo -e "   🟢 Low: $LOW_COUNT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
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
    
    info "Analyzing vulnerable packages and available fixes..."
    
    # Get list of packages that can be updated
    OUTDATED=$(npm outdated --json 2>/dev/null || echo '{}')
    
    # Count packages that need updates
    PACKAGES_TO_UPDATE=$(echo "$OUTDATED" | jq 'length')
    
    info "Found $PACKAGES_TO_UPDATE packages with available updates"
    
    if [ "$PACKAGES_TO_UPDATE" -gt 0 ]; then
        echo ""
        echo -e "${BOLD}🔍 Packages requiring updates:${NC}"
        echo "$OUTDATED" | jq -r 'to_entries[] | "   📦 \(.key): \(.value.current) → \(.value.latest)"'
    fi
}

# ═══════════════════════════════════════════════════════════
# 🔧 PHASE 3: REMEDIATION
# ═══════════════════════════════════════════════════════════

apply_remediation() {
    phase_header "3" "🔧 AUTO-REMEDIATION"
    
    info "Attempting automatic fixes..."
    
    # Try npm audit fix first
    info "Running npm audit fix..."
    FIX_OUTPUT=$(npm audit fix --json 2>/dev/null || echo '{}')
    
    # Check if fixes were applied
    FIXED_COUNT=$(echo "$FIX_OUTPUT" | jq -r '.metadata.fixed // 0')
    
    if [ "$FIXED_COUNT" -gt 0 ]; then
        success "Fixed $FIXED_COUNT vulnerabilities automatically"
        VULNS_FIXED=$FIXED_COUNT
    fi
    
    # Check if force fix is needed
    REMAINING=$(npm audit --json 2>/dev/null | jq -r '.metadata.vulnerabilities.total // 0')
    
    if [ "$REMAINING" -gt 0 ]; then
        warning "$REMAINING vulnerabilities remain"
        info "Attempting npm audit fix --force..."
        
        FORCE_FIX=$(npm audit fix --force --json 2>/dev/null || echo '{}')
        FORCE_FIXED=$(echo "$FORCE_FIX" | jq -r '.metadata.fixed // 0')
        
        if [ "$FORCE_FIXED" -gt 0 ]; then
            success "Force-fixed $FORCE_FIXED additional vulnerabilities"
            VULNS_FIXED=$((VULNS_FIXED + FORCE_FIXED))
        fi
    fi
    
    # Update remaining count
    FINAL_AUDIT=$(npm audit --json 2>/dev/null || echo '{"metadata":{"vulnerabilities":{"total":0}}}')
    VULNS_REMAINING=$(echo "$FINAL_AUDIT" | jq -r '.metadata.vulnerabilities.total // 0')
    
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
    
    # Create reports directory
    mkdir -p "$REPORT_DIR"
    
    END_TIME=$(date +%s)
    EXECUTION_TIME=$((END_TIME - START_TIME))
    
    SUCCESS_RATE="0%"
    if [ "$VULNS_FOUND" -gt 0 ]; then
        SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f%%\", ($VULNS_FIXED/$VULNS_FOUND)*100}")
    fi
    
    info "Generating JSON report..."
    
    # Generate comprehensive JSON report
    cat > "$REPORT_FILE" << EOF
{
  "metadata": {
    "hunter": "asrar-mared",
    "title": "The Vulnerability Hunter",
    "project": "Zayed Shield",
    "engine": "npm",
    "timestamp": "$TIMESTAMP",
    "project_path": "$PROJECT_PATH",
    "execution_time": "${EXECUTION_TIME}s"
  },
  "summary": {
    "vulnerabilities_found": $VULNS_FOUND,
    "vulnerabilities_fixed": $VULNS_FIXED,
    "vulnerabilities_remaining": $VULNS_REMAINING,
    "packages_updated": $PACKAGES_UPDATED,
    "success_rate": "$SUCCESS_RATE"
  },
  "severity_breakdown": {
    "critical": $CRITICAL_COUNT,
    "high": $HIGH_COUNT,
    "medium": $MEDIUM_COUNT,
    "low": $LOW_COUNT
  },
  "warrior_message": "Another victory claimed in the Camp Nou of cybersecurity. The crowd stands, history is made.",
  "scan_complete": true
}
EOF
    
    success "Report saved to: $REPORT_FILE"
    
    # Display summary
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
    
    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        error "npm is not installed. Please install Node.js and npm first."
        exit 1
    fi
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        error "jq is not installed. Installing jq..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y jq
        elif command -v yum &> /dev/null; then
            sudo yum install -y jq
        elif command -v brew &> /dev/null; then
            brew install jq
        else
            error "Please install jq manually"
            exit 1
        fi
    fi
    
    # Execute the 4 phases
    if detect_vulnerabilities; then
        analyze_packages
        apply_remediation
        generate_report
    else
        # No vulnerabilities or no package.json
        generate_report
    fi
    
    exit 0
}

# Run the engine
main "$@"
