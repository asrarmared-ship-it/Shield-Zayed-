#!/data/data/com.termux/files/usr/bin/bash

# 🧹 تنظيف شامل للتهديدات المكتشفة
# تاريخ: 2025-12-09

echo "🔍 بدء عملية التنظيف الشامل..."

# 1. إيقاف العمليات المشبوهة
echo "⚠️  إيقاف العمليات المشبوهة..."
pkill -f "ffmpeg"
pkill -f "sh -i"
pkill -f "nc"
pkill -f "node"
pkill -f "npx"

# 2. حذف npm cache المخترق
echo "🗑️  حذف npm cache المشبوه..."
rm -rf ~/.npm/_npx
rm -rf ~/.npm/_cacache
rm -rf ~/.npm/node_modules

# 3. حذف الملفات المخفية المشبوهة
echo "🔍 فحص وحذف الملفات المخفية المشبوهة..."

# البحث عن ملفات تم تعديلها مؤخراً
find ~ -type f -name ".*" -mtime -7 -ls | tee ~/suspicious_files.log

# حذف ملفات npm المشبوهة
find ~/.npm -type f -name ".*.js" -delete
find ~/.npm -type f -name ".*rc" -delete

# 4. تنظيف node_modules
echo "🧹 تنظيف node_modules..."
find ~ -name "node_modules" -type d -prune -exec rm -rf {} + 2>/dev/null

# 5. إعادة تعيين npm
echo "🔄 إعادة تعيين npm..."
npm cache clean --force
npm config delete prefix
npm config delete cache

# 6. فحص crontab
echo "⏰ فحص المهام المجدولة..."
crontab -l > ~/crontab_backup.txt 2>/dev/null
echo "تم حفظ نسخة احتياطية من crontab"

# 7. فحص .bashrc و .zshrc
echo "📝 فحص ملفات التكوين..."
for file in ~/.bashrc ~/.zshrc ~/.bash_profile ~/.zprofile; do
    if [ -f "$file" ]; then
        grep -n "curl\|wget\|base64\|eval" "$file" | tee -a ~/config_check.log
    fi
done

# 8. فحص الاتصالات النشطة
echo "🌐 فحص الاتصالات النشطة..."
netstat -tunap 2>/dev/null | grep ESTABLISHED | tee ~/active_connections.log

# 9. البحث عن backdoors
echo "🚪 البحث عن backdoors..."
find ~ -type f \( -name "*.sh" -o -name "*.py" \) -exec grep -l "nc\|netcat\|/dev/tcp" {} \; | tee ~/potential_backdoors.log

# 10. تنظيف history
echo "📜 تنظيف history..."
# نسخة احتياطية
cp ~/.zsh_history ~/.zsh_history.backup
cp ~/.bash_history ~/.bash_history.backup 2>/dev/null

# حذف الأوامر المشبوهة
sed -i '/curl.*sh/d' ~/.zsh_history
sed -i '/wget.*sh/d' ~/.zsh_history  
sed -i '/base64/d' ~/.zsh_history
sed -i '/eval/d' ~/.zsh_history

# 11. إنشاء تقرير
cat > ~/security_report_$(date +%Y%m%d_%H%M%S).txt << EOF
================================
🔒 تقرير الأمان - $(date)
================================

📊 الملفات المشبوهة المكتشفة:
$(cat ~/suspicious_files.log 2>/dev/null | wc -l) ملف

🌐 الاتصالات النشطة:
$(cat ~/active_connections.log 2>/dev/null)

🚪 Backdoors المحتملة:
$(cat ~/potential_backdoors.log 2>/dev/null)

📝 مشاكل في ملفات التكوين:
$(cat ~/config_check.log 2>/dev/null)

================================
الإجراءات المتخذة:
✅ تم حذف npm cache
✅ تم إيقاف العمليات المشبوهة
✅ تم تنظيف node_modules
✅ تم تنظيف history
✅ تم إنشاء نسخ احتياطية

⚠️  التوصيات:
1. غير كلمات المرور
2. راجع الملفات في ~/potential_backdoors.log
3. افحص crontab_backup.txt
4. أعد تثبيت npm من جديد
================================
EOF

echo ""
echo "✅ تم الانتهاء من التنظيف!"
echo "📄 تقرير مفصل: ~/security_report_*.txt"
echo ""
echo "⚠️  خطوات إضافية موصى بها:"
echo "1. راجع الملفات المشبوهة في ~/suspicious_files.log"
echo "2. راجع potential_backdoors.log"
echo "3. غير كلمات المرور الخاصة بك"
echo "4. أعد تثبيت Node.js و npm"
