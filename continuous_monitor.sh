#!/data/data/com.termux/files/usr/bin/bash

# 🔍 مراقبة أمنية مستمرة
# يعمل في الخلفية ويراقب النشاطات المشبوهة

MONITOR_LOG="$HOME/security_monitor.log"
ALERT_LOG="$HOME/security_alerts.log"
CHECK_INTERVAL=60  # كل 60 ثانية

# ألوان
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$MONITOR_LOG"
}

send_alert() {
    echo -e "${RED}[ALERT]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$ALERT_LOG"
    # يمكن إضافة إشعار صوتي هنا
    echo -e "\a"
}

# 1. مراقبة العمليات المشبوهة
check_processes() {
    local suspicious_procs=$(ps aux | grep -E "nc|netcat|/dev/tcp|ffmpeg|crypto" | grep -v grep)
    if [ ! -z "$suspicious_procs" ]; then
        send_alert "عمليات مشبوهة مكتشفة:\n$suspicious_procs"
        return 1
    fi
    return 0
}

# 2. مراقبة الاتصالات الشبكية
check_connections() {
    local suspicious_conn=$(netstat -tunap 2>/dev/null | grep ESTABLISHED | grep -v ":443\|:80\|:22")
    if [ ! -z "$suspicious_conn" ]; then
        send_alert "اتصالات مشبوهة:\n$suspicious_conn"
        return 1
    fi
    return 0
}

# 3. مراقبة التغييرات في الملفات الحساسة
check_critical_files() {
    local files=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.bash_profile"
        "$HOME/.zprofile"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            local current_hash=$(md5sum "$file" | awk '{print $1}')
            local stored_hash_file="$HOME/.security/${file##*/}.hash"
            
            if [ -f "$stored_hash_file" ]; then
                local stored_hash=$(cat "$stored_hash_file")
                if [ "$current_hash" != "$stored_hash" ]; then
                    send_alert "تم تعديل ملف حساس: $file"
                    echo "$current_hash" > "$stored_hash_file"
                fi
            else
                mkdir -p "$HOME/.security"
                echo "$current_hash" > "$stored_hash_file"
            fi
        fi
    done
}

# 4. مراقبة استخدام CPU/Memory المشبوه
check_resources() {
    local high_cpu=$(ps aux | awk '$3 > 50.0 {print $0}')
    if [ ! -z "$high_cpu" ]; then
        send_alert "استخدام CPU مرتفع مشبوه:\n$high_cpu"
    fi
}

# 5. مراقبة npm operations
check_npm_activity() {
    local npm_procs=$(ps aux | grep -E "npm|npx|node" | grep -v "grep\|monitor")
    if [ ! -z "$npm_procs" ]; then
        log_event "نشاط npm مكتشف:\n$npm_procs"
        
        # التحقق من وجود عمليات npx مشبوهة
        if echo "$npm_procs" | grep -q "npx"; then
            send_alert "⚠️  عملية npx نشطة - تحقق يدوياً!"
        fi
    fi
}

# 6. فحص الملفات الجديدة
check_new_files() {
    local new_files=$(find ~ -type f -mmin -5 -name ".*" 2>/dev/null)
    if [ ! -z "$new_files" ]; then
        log_event "ملفات مخفية جديدة:\n$new_files"
    fi
}

# دالة الإحصائيات
show_stats() {
    echo -e "\n${GREEN}=== إحصائيات المراقبة ===${NC}"
    echo "إجمالي التنبيهات: $(wc -l < "$ALERT_LOG" 2>/dev/null || echo 0)"
    echo "آخر تنبيه: $(tail -n 1 "$ALERT_LOG" 2>/dev/null || echo 'لا يوجد')"
    echo "وقت التشغيل: $(ps -o etime= -p $$)"
}

# التعامل مع الإشارات
trap "echo 'إيقاف المراقبة...'; show_stats; exit 0" SIGINT SIGTERM

# حلقة المراقبة الرئيسية
main_loop() {
    echo -e "${GREEN}🔍 بدء المراقبة الأمنية المستمرة...${NC}"
    echo "Log file: $MONITOR_LOG"
    echo "Alert file: $ALERT_LOG"
    echo "اضغط Ctrl+C للإيقاف"
    echo ""
    
    local check_count=0
    
    while true; do
        check_count=$((check_count + 1))
        
        # تشغيل الفحوصات
        check_processes
        check_connections
        check_critical_files
        check_resources
        check_npm_activity
        check_new_files
        
        # عرض حالة كل 10 دقائق
        if [ $((check_count % 10)) -eq 0 ]; then
            echo -e "${GREEN}✅${NC} [$(date '+%H:%M:%S')] نظام نظيف - فحص #$check_count"
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# بدء المراقبة
main_loop
