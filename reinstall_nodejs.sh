#!/data/data/com.termux/files/usr/bin/bash

# 🔄 إعادة تثبيت Node.js و npm بأمان
# تاريخ: 2025-12-09

echo "🔄 بدء عملية إعادة التثبيت النظيف..."

# 1. حذف Node.js تماماً
echo "🗑️  حذف Node.js و npm القديم..."
pkg uninstall nodejs -y 2>/dev/null
rm -rf ~/.npm
rm -rf ~/.node-gyp
rm -rf ~/.nvm
rm -rf ~/node_modules
rm -rf ~/.config/configstore

# 2. تنظيف PATH
echo "🧹 تنظيف المتغيرات البيئية..."
# إزالة مسارات Node من .zshrc
sed -i '/NVM_DIR/d' ~/.zshrc
sed -i '/nvm.sh/d' ~/.zshrc
sed -i '/npm-global/d' ~/.zshrc

# 3. إعادة تثبيت Node.js
echo "📦 إعادة تثبيت Node.js..."
pkg update -y
pkg install nodejs -y

# 4. التحقق من التثبيت
echo "✅ التحقق من التثبيت..."
node --version
npm --version

# 5. إعداد npm بأمان
echo "🔒 إعداد npm بأمان..."

# إنشاء مجلد npm عالمي آمن
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# إضافة المسار إلى PATH بأمان
echo '' >> ~/.zshrc
echo '# npm global packages' >> ~/.zshrc
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc

# تحديث npm
npm install -g npm@latest

# 6. تثبيت الحزم الأساسية فقط
echo "📦 تثبيت الحزم الأساسية..."
npm install -g yarn

# 7. إعداد إعدادات أمان npm
echo "🔐 إعداد إعدادات الأمان..."

# تفعيل 2FA (اختياري - يتطلب حساب npm)
# npm profile enable-2fa auth-and-writes

# منع تشغيل سكريبتات pre/post تلقائياً
npm config set ignore-scripts true

# إجبار استخدام https
npm config set strict-ssl true

# تعطيل optional dependencies المشبوهة
npm config set optional false

# 8. تنظيف cache
echo "🧹 تنظيف cache..."
npm cache clean --force

# 9. إنشاء تقرير
cat > ~/nodejs_reinstall_report.txt << EOF
================================
✅ تقرير إعادة تثبيت Node.js
تاريخ: $(date)
================================

Node.js Version: $(node --version)
npm Version: $(npm --version)

📍 المسارات:
- npm prefix: $(npm config get prefix)
- npm cache: $(npm config get cache)

🔒 إعدادات الأمان:
- ignore-scripts: $(npm config get ignore-scripts)
- strict-ssl: $(npm config get strict-ssl)
- optional: $(npm config get optional)

✅ التثبيت اكتمل بنجاح!

⚠️  ملاحظات مهمة:
1. تم تعطيل تشغيل السكريبتات تلقائياً (ignore-scripts: true)
2. لتشغيل سكريبت معين، استخدم: npm install --ignore-scripts=false
3. راجع دائماً محتوى package.json قبل التثبيت
4. استخدم npm audit قبل تثبيت أي حزمة جديدة

================================
EOF

echo ""
echo "✅ تم الانتهاء من إعادة التثبيت!"
echo "📄 التقرير: ~/nodejs_reinstall_report.txt"
echo ""
echo "⚠️  للتطبيق، شغّل:"
echo "source ~/.zshrc"
