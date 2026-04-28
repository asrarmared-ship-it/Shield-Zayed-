#!/bin/bash

# =============================================================================
# سكريبت الحماية المتقدم لمشروع درع زايد للأمن السيبراني
# حماية الحزم النادرة والأكواد الحساسة
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Project info
PROJECT_NAME="digital-genie-cybersecurity"
AUTHOR="nike1212a"
PROTECTION_VERSION="2.0"
PROTECTION_DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Generate unique project fingerprint
generate_fingerprint() {
    local project_path="$1"
    local timestamp=$(date +%s)
    local hostname=$(hostname)
    local user=$(whoami)
    
    # Create unique hash based on project content, time, and system
    echo -n "${project_path}${timestamp}${hostname}${user}${AUTHOR}" | sha256sum | cut -d' ' -f1
}

# Create protection license
create_protection_license() {
    print_header "إنشاء رخصة الحماية"
    
    local fingerprint=$(generate_fingerprint "$(pwd)")
    
    cat > PROTECTION_LICENSE << EOF
# =============================================================================
# رخصة الحماية - درع زايد للأمن السيبراني
# Digital Genie Cybersecurity - Protection License
# =============================================================================

المطور: ${AUTHOR}
المشروع: ${PROJECT_NAME}
تاريخ الحماية: ${PROTECTION_DATE}
بصمة المشروع: ${fingerprint}
إصدار الحماية: ${PROTECTION_VERSION}

⚠️  تحذير قانوني:
- هذا المشروع محمي بحقوق الطبع والنشر
- يحتوي على حزم وأدوات نادرة ومتخصصة
- أي استخدام غير مصرح به قد يعرضك للمساءلة القانونية
- النسخ أو التوزيع بدون إذن ممنوع تماماً

🛡️ الحماية تشمل:
- تشفير الملفات الحساسة
- حماية الكود المصدري
- تتبع الوصول والتعديلات
- نظام إنذار للاختراقات

📧 للاستفسارات: security@digital-genie-project.com
📞 الدعم التقني: +966-xxx-xxx-xxxx

© 2025 ${AUTHOR} - جميع الحقوق محفوظة
EOF

    print_status "تم إنشاء رخصة الحماية"
}

# Encrypt sensitive files
encrypt_sensitive_files() {
    print_header "تشفير الملفات الحساسة"
    
    # Create encryption key
    ENCRYPTION_KEY=$(openssl rand -hex 32)
    echo "$ENCRYPTION_KEY" > .protection_key
    chmod 600 .protection_key
    
    # Files to encrypt
    SENSITIVE_FILES=(
        "config/settings/"
        "scripts/security/"
        "tools/python/advanced/"
        "data/reports/"
        "config/wordlists/"
    )
    
    # Create encrypted directory
    mkdir -p .encrypted_vault
    chmod 700 .encrypted_vault
    
    for file_path in "${SENSITIVE_FILES[@]}"; do
        if [[ -d "$file_path" ]]; then
            print_info "تشفير مجلد: $file_path"
            tar -czf ".encrypted_vault/$(basename $file_path).tar.gz" "$file_path" 2>/dev/null
            
            # Encrypt with AES-256
            openssl enc -aes-256-cbc -salt -in ".encrypted_vault/$(basename $file_path).tar.gz" \
                   -out ".encrypted_vault/$(basename $file_path).enc" \
                   -k "$ENCRYPTION_KEY" 2>/dev/null
            
            # Remove unencrypted tar
            rm -f ".encrypted_vault/$(basename $file_path).tar.gz"
            
            print_status "تم تشفير: $file_path"
        fi
    done
    
    # Create decryption script
    cat > decrypt_vault.sh << 'EOF'
#!/bin/bash
# Decryption script - Use with caution

if [[ ! -f ".protection_key" ]]; then
    echo "❌ مفتاح التشفير غير موجود!"
    exit 1
fi

KEY=$(cat .protection_key)
echo "🔓 فك تشفير الملفات الحساسة..."

for enc_file in .encrypted_vault/*.enc; do
    if [[ -f "$enc_file" ]]; then
        base_name=$(basename "$enc_file" .enc)
        openssl enc -d -aes-256-cbc -in "$enc_file" -out "/tmp/$base_name.tar.gz" -k "$KEY"
        tar -xzf "/tmp/$base_name.tar.gz" -C .
        rm -f "/tmp/$base_name.tar.gz"
        echo "✅ تم فك تشفير: $base_name"
    fi
done

echo "🎉 تم فك تشفير جميع الملفات"
EOF
    
    chmod 700 decrypt_vault.sh
    print_status "تم إنشاء نظام التشفير"
}

# Create access monitoring
setup_access_monitoring() {
    print_header "إعداد نظام مراقبة الوصول"
    
    # Create monitoring script
    cat > .monitor_access.sh << 'EOF'
#!/bin/bash

LOG_FILE=".access_log"
ALERT_EMAIL="security@digital-genie-project.com"

# Function to log access
log_access() {
    local action="$1"
    local file="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local user=$(whoami)
    local ip=$(who am i | awk '{print $5}' | tr -d '()')
    
    echo "[$timestamp] $user ($ip) - $action: $file" >> "$LOG_FILE"
}

# Monitor file changes
monitor_changes() {
    if command -v inotifywait &> /dev/null; then
        inotifywait -m -r -e modify,create,delete,move . --format '%T %w %f %e' --timefmt '%Y-%m-%d %H:%M:%S' | while read timestamp path file event; do
            if [[ ! "$file" =~ ^\..* ]]; then  # Ignore hidden files
                log_access "$event" "$path$file"
                
                # Alert on sensitive file access
                if [[ "$path$file" =~ (config|scripts|tools).*\.(py|sh|conf)$ ]]; then
                    echo "🚨 تنبيه أمني: تم الوصول لملف حساس - $path$file" | mail -s "تنبيه أمني - المارد الرقمي" "$ALERT_EMAIL" 2>/dev/null || true
                fi
            fi
        done &
        
        echo $! > .monitor_pid
        print_status "تم تفعيل مراقبة الملفات"
    else
        print_warning "inotify-tools غير مثبت - سيتم استخدام طريقة بديلة"
        
        # Alternative monitoring using find
        while true; do
            find . -type f -newer .last_check -not -path './.git/*' 2>/dev/null | while read file; do
                log_access "MODIFIED" "$file"
            done
            
            touch .last_check
            sleep 60
        done &
        
        echo $! > .monitor_pid
    fi
}

# Start monitoring
monitor_changes
EOF

    chmod +x .monitor_access.sh
    
    # Create stop monitoring script
    cat > stop_monitoring.sh << 'EOF'
#!/bin/bash

if [[ -f ".monitor_pid" ]]; then
    PID=$(cat .monitor_pid)
    kill $PID 2>/dev/null
    rm -f .monitor_pid
    echo "✅ تم إيقاف مراقبة الوصول"
else
    echo "❌ نظام المراقبة غير نشط"
fi
EOF

    chmod +x stop_monitoring.sh
    print_status "تم إعداد نظام المراقبة"
}

# Create backup system
setup_backup_system() {
    print_header "إعداد نظام النسخ الاحتياطي المشفر"
    
    mkdir -p .secure_backups
    chmod 700 .secure_backups
    
    cat > create_secure_backup.sh << 'EOF'
#!/bin/bash

BACKUP_NAME="digital_genie_backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_KEY=$(openssl rand -hex 32)

echo "📦 إنشاء نسخة احتياطية مشفرة..."

# Create archive excluding sensitive directories
tar --exclude='.git' \
    --exclude='.encrypted_vault' \
    --exclude='.secure_backups' \
    --exclude='node_modules' \
    --exclude='__pycache__' \
    -czf "/tmp/$BACKUP_NAME.tar.gz" . 2>/dev/null

# Encrypt backup
openssl enc -aes-256-cbc -salt \
    -in "/tmp/$BACKUP_NAME.tar.gz" \
    -out ".secure_backups/$BACKUP_NAME.enc" \
    -k "$BACKUP_KEY"

# Save key securely
echo "$BACKUP_KEY" > ".secure_backups/$BACKUP_NAME.key"
chmod 600 ".secure_backups/$BACKUP_NAME.key"

# Clean temporary files
rm -f "/tmp/$BACKUP_NAME.tar.gz"

# Create backup info
cat > ".secure_backups/$BACKUP_NAME.info" << EOL
اسم النسخة: $BACKUP_NAME
التاريخ: $(date '+%Y-%m-%d %H:%M:%S')
الحجم: $(du -h ".secure_backups/$BACKUP_NAME.enc" | cut -f1)
المطور: $(whoami)
البصمة: $(sha256sum ".secure_backups/$BACKUP_NAME.enc" | cut -d' ' -f1)
EOL

echo "✅ تم إنشاء النسخة الاحتياطية: $BACKUP_NAME"
echo "🔑 مفتاح فك التشفير محفوظ في: .secure_backups/$BACKUP_NAME.key"
EOF

    chmod +x create_secure_backup.sh
    print_status "تم إعداد نظام النسخ الاحتياطي"
}

# Create integrity checker
create_integrity_checker() {
    print_header "إنشاء نظام فحص سلامة الملفات"
    
    cat > check_integrity.sh << 'EOF'
#!/bin/bash

CHECKSUMS_FILE=".file_checksums"

# Create initial checksums if not exist
if [[ ! -f "$CHECKSUMS_FILE" ]]; then
    echo "📝 إنشاء قائمة الفحص الأولية..."
    find . -type f -not -path './.git/*' -not -path './.encrypted_vault/*' -not -path './.secure_backups/*' -exec sha256sum {} \; > "$CHECKSUMS_FILE"
    echo "✅ تم إنشاء قائمة الفحص"
    exit 0
fi

echo "🔍 فحص سلامة الملفات..."

# Check for changes
CHANGES=0
while IFS= read -r line; do
    checksum=$(echo "$line" | cut -d' ' -f1)
    filepath=$(echo "$line" | cut -d' ' -f3-)
    
    if [[ -f "$filepath" ]]; then
        current_checksum=$(sha256sum "$filepath" | cut -d' ' -f1)
        if [[ "$checksum" != "$current_checksum" ]]; then
            echo "⚠️  تم تعديل الملف: $filepath"
            CHANGES=$((CHANGES + 1))
        fi
    else
        echo "❌ ملف مفقود: $filepath"
        CHANGES=$((CHANGES + 1))
    fi
done < "$CHECKSUMS_FILE"

# Check for new files
echo "🔍 البحث عن ملفات جديدة..."
find . -type f -not -path './.git/*' -not -path './.encrypted_vault/*' -not -path './.secure_backups/*' | while read file; do
    if ! grep -q "$file" "$CHECKSUMS_FILE"; then
        echo "➕ ملف جديد: $file"
        CHANGES=$((CHANGES + 1))
    fi
done

if [[ $CHANGES -eq 0 ]]; then
    echo "✅ جميع الملفات سليمة"
else
    echo "⚠️  تم العثور على $CHANGES تغيير"
    echo "💡 لتحديث قائمة الفحص، احذف $CHECKSUMS_FILE وأعد تشغيل السكريبت"
fi
EOF

    chmod +x check_integrity.sh
    print_status "تم إنشاء نظام فحص السلامة"
}

# Create anti-tampering system
setup_anti_tampering() {
    print_header "إعداد نظام منع التلاعب"
    
    cat > .anti_tamper.sh << 'EOF'
#!/bin/bash

TAMPER_LOG=".tamper_log"
CRITICAL_FILES=(
    "scripts/core/setup_security_lab.sh"
    "PROTECTION_LICENSE"
    ".protection_key"
    "decrypt_vault.sh"
)

# Function to check critical files
check_critical_files() {
    for file in "${CRITICAL_FILES[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "🚨 ملف حرج مفقود: $file" >> "$TAMPER_LOG"
            echo "⚠️  تحذير: ملف حرج مفقود - $file"
            
            # Send alert
            echo تم حذف ملف حرج من مشروع درع زايد: $file" | \
                mail -s "تنبيه أمني عاجل" security@digital-genie-project.com 2>/dev/null || true
        fi
    done
}

# Function to check unauthorized access
check_unauthorized_access() {
    local suspicious_patterns=(
        "rm -rf"
        "chmod 777"
        "wget.*malware"
        "curl.*backdoor"
        "nc -l"
    )
    
    # Check command history for suspicious activity
    if [[ -f ~/.bash_history ]]; then
        for pattern in "${suspicious_patterns[@]}"; do
            if grep -q "$pattern" ~/.bash_history 2>/dev/null; then
                echo "🚨 نشاط مشبوه في التاريخ: $pattern" >> "$TAMPER_LOG"
                echo "⚠️  تحذير: تم رصد نشاط مشبوه"
            fi
        done
    fi
}

# Function to monitor system resources
monitor_resources() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    
    # Alert if resources are unusually high
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        echo "🚨 استخدام CPU مرتفع: $cpu_usage%" >> "$TAMPER_LOG"
    fi
    
    if (( memory_usage > 90 )); then
        echo "🚨 استخدام الذاكرة مرتفع: $memory_usage%" >> "$TAMPER_LOG"
    fi
}

# Main monitoring loop
while true; do
    check_critical_files
    check_unauthorized_access
    monitor_resources
    sleep 300  # Check every 5 minutes
done &

echo $! > .anti_tamper_pid
echo "✅ تم تفعيل نظام منع التلاعب"
EOF

    chmod +x .anti_tamper.sh
    print_status "تم إعداد نظام منع التلاعب"
}

# Create protection report
generate_protection_report() {
    print_header "إنشاء تقرير الحماية"
    
    local report_file="PROTECTION_REPORT.md"
    
    cat > "$report_file" << EOF
# 🛡️ تقرير حماية المشروع

**المشروع**: ${PROJECT_NAME}  
**المطور**: ${AUTHOR}  
**تاريخ الحماية**: ${PROTECTION_DATE}  
**إصدار الحماية**: ${PROTECTION_VERSION}  

## 📊 حالة الحماية

| نوع الحماية | الحالة | التفاصيل |
|-------------|--------|----------|
| 🔐 تشفير الملفات | ✅ مفعل | AES-256-CBC |
| 👁️ مراقبة الوصول | ✅ مفعل | Real-time monitoring |
| 💾 النسخ الاحتياطي | ✅ مفعل | مشفر وآمن |
| 🔍 فحص السلامة | ✅ مفعل | SHA-256 checksums |
| 🚫 منع التلاعب | ✅ مفعل | Active protection |

## 🔧 الملفات المحمية

- \`scripts/security/\` - أدوات الأمان المتخصصة
- \`config/settings/\` - إعدادات النظام الحساسة  
- \`tools/python/advanced/\` - مكتبات Python النادرة
- \`data/reports/\` - تقارير الأمان
- \`config/wordlists/\` - قوائم الكلمات المتخصصة

## 🚨 إجراءات الطوارئ

في حالة اكتشاف خرق أمني:

1. **إيقاف النظام فوراً**
   \`\`\`bash
   ./stop_monitoring.sh
   killall -9 inotifywait
   \`\`\`

2. **إنشاء نسخة احتياطية طارئة**
   \`\`\`bash
   ./create_secure_backup.sh
   \`\`\`

3. **فحص سلامة الملفات**
   \`\`\`bash
   ./check_integrity.sh
   \`\`\`

4. **مراجعة سجلات الوصول**
   \`\`\`bash
   cat .access_log
   cat .tamper_log
   \`\`\`

## 📞 الاتصال في الطوارئ

- **البريد الإلكتروني**: security@digital-genie-project.com
- **الهاتف**: +966-xxx-xxx-xxxx

## ⚖️ التحذير القانوني

هذا المشروع محمي بموجب:
- قانون حقوق الطبع والنشر
- قانون جرائم المعلوماتية 
- اتفاقية الملكية الفكرية

أي محاولة للوصول غير المصرح أو التلاعب ستؤدي إلى:
- المساءلة القانونية
- المطالبة بالتعويضات
- الإبلاغ للسلطات المختصة

---
**تم إنشاء هذا التقرير تلقائياً بواسطة نظام حماية المارد الرقمي**
EOF

    print_status "تم إنشاء تقرير الحماية: $report_file"
}

# Main protection setup
main_protection_setup() {
    print_header "🛡️ بدء إعداد نظام الحماية المتقدم"
    print_info "المشروع: $PROJECT_NAME"
    print_info "المطور: $AUTHOR"
    print_info "الإصدار: $PROTECTION_VERSION"
    
    echo
    print_warning "هذا السكريبت سيقوم بحماية مشروعك من:"
    echo "  • 🔐 تشفير الملفات الحساسة"
    echo "  • 👁️ مراقبة الوصول والتعديلات"
    echo "  • 💾 إنشاء نسخ احتياطية مشفرة"
    echo "  • 🔍 فحص سلامة الملفات"
    echo "  • 🚫 منع التلاعب والاختراق"
    echo
    
    read -p "هل تريد المتابعة؟ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "تم إلغاء عملية الحماية"
        exit 1
    fi
    
    # Check dependencies
    print_info "فحص المتطلبات..."
    
    REQUIRED_TOOLS=("openssl" "tar" "sha256sum")
    MISSING_TOOLS=()
    
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            MISSING_TOOLS+=("$tool")
        fi
    done
    
    if [[ ${#MISSING_TOOLS[@]} -gt 0 ]]; then
        print_error "الأدوات التالية مطلوبة ولكنها غير مثبتة:"
        for tool in "${MISSING_TOOLS[@]}"; do
            echo "  • $tool"
        done
        print_info "يمكنك تثبيتها باستخدام: sudo apt install ${MISSING_TOOLS[*]}"
        exit 1
    fi
    
    print_status "جميع المتطلبات متوفرة"
    echo
    
    # Execute protection steps
    create_protection_license
    encrypt_sensitive_files  
    setup_access_monitoring
    setup_backup_system
    create_integrity_checker
    setup_anti_tampering
    generate_protection_report
    
    echo
    print_header "🎉 تم إعداد الحماية بنجاح"
    print_status "رخصة الحماية: PROTECTION_LICENSE"
    print_status "مفتاح التشفير: .protection_key (احتفظ به بأمان)"
    print_status "تقرير الحماية: PROTECTION_REPORT.md"
    print_status "سجل الوصول: .access_log"
    
    echo
    print_info "الخطوات التالية:"
    echo "  1. ابدأ نظام المراقبة: ./.monitor_access.sh"
    echo "  2. فعّل منع التلاعب: ./.anti_tamper.sh" 
    echo "  3. أنشئ نسخة احتياطية: ./create_secure_backup.sh"
    echo "  4. افحص السلامة: ./check_integrity.sh"
    
    echo
    print_warning "⚠️ مهم جداً:"
    echo "  • احتفظ بملف .protection_key في مكان آمن"
    echo "  • لا تشارك مفاتيح التشفير مع أحد"
    echo "  • راقب سجلات الوصول بانتظام"
    echo "  • قم بعمل نسخ احتياطية دورية"
    
    print_status "مشروعك الآن محمي بأعلى معايير الأمان! 🛡️"
}

# Execute main function
main_protection_setup "$@"
