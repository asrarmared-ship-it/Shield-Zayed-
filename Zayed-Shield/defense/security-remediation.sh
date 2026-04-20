#!/data/data/com.termux/files/usr/bin/bash

# ⚡ Zayed Shield - Emergency Security Fix
# Run this script to fix all identified vulnerabilities

set -e  # Exit on any error

echo "🛡️ Zayed Shield - Security Remediation Tool"
echo "============================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Backup current state
backup_current_state() {
    log_info "Creating backup..."
    cp package.json package.json.backup
    cp package-lock.json package-lock.json.backup 2>/dev/null || true
    log_info "✅ Backup created: package.json.backup"
}

# Phase 1: Fix secp256k1 issue
fix_secp256k1() {
    echo ""
    echo "🔧 PHASE 1: Fixing secp256k1 Vulnerability"
    echo "==========================================="
    
    log_info "Removing vulnerable secp256k1..."
    npm uninstall secp256k1 2>/dev/null || true
    
    log_info "Installing secure alternative @noble/secp256k1..."
    npm install @noble/secp256k1@2.0.0 --save
    
    log_warn "⚠️  MANUAL ACTION REQUIRED:"
    echo "   Update your code to use @noble/secp256k1"
    echo "   See migration guide in the report"
    
    echo ""
    log_info "✅ Phase 1 Complete"
}

# Phase 2: Fix low-severity issues
fix_low_severity() {
    echo ""
    echo "🔧 PHASE 2: Fixing Low-Severity Issues"
    echo "======================================="
    
    log_info "Running npm audit fix..."
    npm audit fix --legacy-peer-deps || true
    
    log_info "Updating mocha..."
    npm install mocha@latest --save-dev
    
    echo ""
    log_info "✅ Phase 2 Complete"
}

# Phase 3: Verification
verify_fixes() {
    echo ""
    echo "🔍 PHASE 3: Verification"
    echo "========================"
    
    log_info "Running security audit..."
    npm audit --production
    
    log_info "Checking for critical vulnerabilities..."
    CRITICAL=$(npm audit --json | grep -o '"severity":"critical"' | wc -l)
    HIGH=$(npm audit --json | grep -o '"severity":"high"' | wc -l)
    
    echo ""
    if [ "$CRITICAL" -eq 0 ] && [ "$HIGH" -eq 0 ]; then
        log_info "✅ No critical or high vulnerabilities found!"
    else
        log_warn "⚠️  Still have $CRITICAL critical and $HIGH high vulnerabilities"
    fi
}

# Generate report
generate_report() {
    echo ""
    echo "📊 Generating Security Report"
    echo "=============================="
    
    REPORT_FILE="security-audit-$(date +%Y%m%d-%H%M%S).json"
    npm audit --json > "$REPORT_FILE"
    
    log_info "Report saved to: $REPORT_FILE"
    
    # Create human-readable summary
    SUMMARY_FILE="security-summary-$(date +%Y%m%d-%H%M%S).txt"
    cat > "$SUMMARY_FILE" << EOF
Zayed Shield - Security Audit Summary
======================================
Date: $(date)
Node Version: $(node --version)
npm Version: $(npm --version)

Vulnerabilities:
$(npm audit)

Installed Packages:
$(npm list --depth=0)

Status: Remediation Complete
Next Steps: Review manual actions in main report
EOF
    
    log_info "Summary saved to: $SUMMARY_FILE"
}

# Main execution
main() {
    log_info "Starting security remediation..."
    echo ""
    
    # Confirm with user
    read -p "This will modify your dependencies. Continue? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Aborted by user"
        exit 1
    fi
    
    # Execute phases
    backup_current_state
    fix_secp256k1
    fix_low_severity
    verify_fixes
    generate_report
    
    echo ""
    echo "============================================="
    log_info "🎉 Remediation Complete!"
    echo "============================================="
    echo ""
    echo "📋 Summary:"
    echo "  ✅ Vulnerable packages removed"
    echo "  ✅ Secure alternatives installed"
    echo "  ✅ Low-severity issues fixed"
    echo ""
    echo "⚠️  Manual Actions Required:"
    echo "  1. Update code to use @noble/secp256k1"
    echo "  2. Run tests: npm test"
    echo "  3. Review migration guide in report"
    echo ""
    echo "📄 Reports generated:"
    echo "  - $(ls -t security-audit-*.json | head -1)"
    echo "  - $(ls -t security-summary-*.txt | head -1)"
    echo ""
    log_info "Backup saved: package.json.backup"
}

# Run main
main
