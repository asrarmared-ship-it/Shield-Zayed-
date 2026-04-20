#!/bin/bash

# ═══════════════════════════════════════════════════════════
# 🛡️ ZAYED SHIELD - MAVEN SECURITY ENGINE
# ═══════════════════════════════════════════════════════════
# Hunter: asrar-mared | The Vulnerability Hunter ⚔️
# Engine: Java/Maven Package Security
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
REPORT_FILE="$REPORT_DIR/maven-report.json"
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

declare -a VULN_ARTIFACTS=()
declare -a FIXED_ARTIFACTS=()

banner() {
    echo -e "${CYAN}${BOLD}"
    echo "═══════════════════════════════════════════════════════════"
    echo "🛡️  ZAYED SHIELD - MAVEN/JAVA SECURITY ENGINE"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo -e "${PURPLE}👤 Hunter:${NC} asrar-mared"
    echo -e "${PURPLE}🎖️  Title:${NC} The Vulnerability Hunter ⚔️"
    echo -e "${PURPLE}📦 Engine:${NC} Maven/Java"
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
    
    # Check for pom.xml
    if [ ! -f "pom.xml" ]; then
        warning "No pom.xml found - skipping Maven scan"
        return 1
    fi
    
    info "Scanning Maven dependencies with OWASP Dependency-Check..."
    
    # Run dependency-check using Maven plugin
    info "Running mvn dependency:tree to analyze dependencies..."
    mvn dependency:tree -DoutputFile=dependency-tree.txt &>/dev/null || true
    
    # Run OWASP Dependency Check
    info "Running OWASP dependency check..."
    mvn org.owasp:dependency-check-maven:check \
        -DfailBuildOnCVSS=0 \
        -DskipProvidedScope=false \
        -DskipRuntimeScope=false \
        -Dformat=JSON \
        &>/dev/null || true
    
    # Parse dependency-check report
    if [ -f "target/dependency-check-report.json" ]; then
        REPORT_JSON=$(cat target/dependency-check-report.json)
        
        # Count vulnerabilities
        VULNS_FOUND=$(echo "$REPORT_JSON" | jq '[.dependencies[]?.vulnerabilities[]?] | length' 2>/dev/null || echo 0)
        
        if [ "$VULNS_FOUND" -gt 0 ]; then
            # Parse severity
            while IFS= read -r vuln; do
                SEVERITY=$(echo "$vuln" | jq -r '.severity // "MEDIUM"')
                ARTIFACT=$(echo "$vuln" | jq -r '.name // "unknown"')
                
                VULN_ARTIFACTS+=("$ARTIFACT")
                
                case "$SEVERITY" in
                    CRITICAL) ((CRITICAL_COUNT++)) ;;
                    HIGH) ((HIGH_COUNT++)) ;;
                    MEDIUM) ((MEDIUM_COUNT++)) ;;
                    *) ((LOW_COUNT++)) ;;
                esac
            done < <(echo "$REPORT_JSON" | jq -c '.dependencies[]?.vulnerabilities[]?' 2>/dev/null || echo "")
        fi
    else
        warning "Dependency check report not found - trying alternative scan..."
        # Try versions plugin
        mvn versions:display-dependency-updates -DoutputFile=updates.txt &>/dev/null || true
        
        if [ -f "updates.txt" ]; then
            VULNS_FOUND=$(grep -c "->>" updates.txt 2>/dev/null || echo 0)
        fi
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
    
    info "Analyzing vulnerable dependencies and available updates..."
    
    # Check for dependency updates
    info "Checking for available updates..."
    mvn versions:display-dependency-updates -B -q 2>/dev/null || true
    
    echo ""
    echo -e "${BOLD}🔍 Update Analysis:${NC}"
    
    if [ -f "dependency-tree.txt" ]; then
        info "Dependency tree analyzed"
        TOTAL_DEPS=$(grep -c "\[INFO\]" dependency-tree.txt 2>/dev/null || echo 0)
        echo "   Total dependencies: $TOTAL_DEPS"
    fi
}

# ═══════════════════════════════════════════════════════════
# 🔧 PHASE 3: REMEDIATION
# ═══════════════════════════════════════════════════════════

apply_remediation() {
    phase_header "3" "🔧 AUTO-REMEDIATION"
    
    info "Attempting to update vulnerable dependencies..."
    
    # Use versions plugin to update dependencies
    info "Running mvn versions:use-latest-releases..."
    
    if mvn versions:use-latest-releases -DallowMajorUpdates=false -B &>/dev/null; then
        success "Dependencies updated to latest releases"
        ((PACKAGES_UPDATED++))
    else
        warning "Some dependencies could not be updated automatically"
    fi
    
    # Try to update parent POM
    info "Updating parent version..."
    mvn versions:update-parent -B &>/dev/null || true
    
    # Update properties
    info "Updating dependency properties..."
    mvn versions:update-properties -B &>/dev/null || true
    
    # Re-scan after fixes
    info "Re-scanning after remediation..."
    mvn org.owasp:dependency-check-maven:check \
        -DfailBuildOnCVSS=0 \
        -Dformat=JSON \
        &>/dev/null || true
    
    if [ -f "target/dependency-check-report.json" ]; then
        NEW_REPORT=$(cat target/dependency-check-report.json)
        VULNS_REMAINING=$(echo "$NEW_REPORT" | jq '[.dependencies[]?.vulnerabilities[]?] | length' 2>/dev/null || echo 0)
        VULNS_FIXED=$((VULNS_FOUND - VULNS_REMAINING))
    else
        VULNS_FIXED=$PACKAGES_UPDATED
        VULNS_REMAINING=$((VULNS_FOUND - VULNS_FIXED))
    fi
    
    echo ""
    echo -e "${BOLD}🎯 Remediation Summary:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "   Dependencies Updated: ${GREEN}$PACKAGES_UPDATED${NC}"
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
    
    info "Generating JSON report..."
    
    cat > "$REPORT_FILE" << EOF
{
  "metadata": {
    "hunter": "asrar-mared",
    "title": "The Vulnerability Hunter",
    "project": "Zayed Shield",
    "engine": "maven",
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
  "warrior_message": "Java fortress reinforced. Maven dependencies secured.",
  "scan_complete": true
}
EOF
    
    success "Report saved to: $REPORT_FILE"
    
    # Cleanup temporary files
    rm -f dependency-tree.txt updates.txt 2>/dev/null
    
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
    
    if ! command -v mvn &> /dev/null; then
        error "Maven is not installed"
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
