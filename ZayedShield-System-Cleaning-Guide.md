# 🚨 الحل الشامل لتنظيف جهازك
## إزالة الإعلانات والبرمجيات الخبيثة

<div align="center">

![Status](https://img.shields.io/badge/المشكلة-Adware_Malware-red?style=for-the-badge)
![Solution](https://img.shields.io/badge/الحل-جاهز_فوراً-success?style=for-the-badge)

**جهازك مليان إعلانات؟ نظفه في 15 دقيقة!**

</div>

---

## 🎯 المشكلة اللي عندك

```
✗ إعلانات كل ثانية
✗ صفحات تفتح لوحدها
✗ الكيبورد بتفتح لوحدها
✗ الجهاز بطيء جداً
✗ برامج غريبة مثبتة
✗ متصفح Chrome/Edge مخطوف
```

### السبب: **Adware & Malware**
- تثبيت برامج مجانية مشبوهة
- تحميل من مواقع غير موثوقة
- الضغط على إعلانات خبيثة
- روابط احتيالية

---

## ⚡ الحل السريع (15 دقيقة)

### المرحلة 1: التنظيف الفوري (5 دقائق)

#### الخطوة 1: إلغاء تثبيت البرامج المشبوهة

**في Windows:**

```
1. اضغط Windows + R
2. اكتب: appwiz.cpl
3. اضغط Enter
4. احذف أي برنامج غريب أو حديث مش عارفه
```

**البرامج المشبوهة الشائعة:**
- إعلانات باسم عربي
- برامج بدون ناشر معروف
- تطبيقات مثبتة حديثاً
- Toolbars
- Search Engines غريبة
- VPN مجانية مشبوهة

#### الخطوة 2: إعادة تشغيل في Safe Mode

```
1. اضغط Windows + I (الإعدادات)
2. Update & Security
3. Recovery
4. Advanced startup → Restart now
5. Troubleshoot → Advanced options → Startup Settings
6. Restart
7. اضغط F4 للدخول في Safe Mode
```

---

### المرحلة 2: أدوات التنظيف الاحترافية (10 دقائق)

#### الأداة 1: Malwarebytes (الأفضل)

```
🔗 التحميل:
https://www.malwarebytes.com/mwb-download

الخطوات:
1. حمّل Malwarebytes
2. ثبّته
3. اضغط "Scan"
4. انتظر الفحص (5-10 دقائق)
5. اضغط "Quarantine All"
6. Restart
```

#### الأداة 2: AdwCleaner (خاص بالإعلانات)

```
🔗 التحميل:
https://www.malwarebytes.com/adwcleaner

الخطوات:
1. حمّل AdwCleaner
2. شغله (مش محتاج تثبيت)
3. اضغط "Scan Now"
4. انتظر (2-3 دقائق)
5. اضغط "Clean & Repair"
6. Restart
```

#### الأداة 3: HitmanPro (للحالات الصعبة)

```
🔗 التحميل:
https://www.hitmanpro.com/en-us/downloads

الخطوات:
1. حمّل HitmanPro
2. شغله
3. Next → Next → Scan
4. انتظر الفحص
5. Activate free license (30 يوم)
6. Clean
```

---

### المرحلة 3: تنظيف المتصفحات (5 دقائق)

#### تنظيف Chrome

```
1. افتح Chrome
2. الإعدادات (⋮ في اليمين)
3. Extensions (الإضافات)
4. احذف أي إضافة مش عارفها
5. Settings → Reset settings
6. Restore settings to defaults → Reset
```

**أو استخدام الأمر المباشر:**
```
chrome://settings/resetProfileSettings
```

#### تنظيف Edge

```
1. افتح Edge
2. ⋯ (الثلاث نقط)
3. Extensions
4. احذف الإضافات الغريبة
5. Settings → Reset settings
6. Restore settings → Reset
```

#### تنظيف Firefox

```
1. افتح Firefox
2. ☰ (القائمة)
3. Add-ons and themes
4. احذف الغريب
5. Help → More troubleshooting information
6. Refresh Firefox
```

---

## 🛡️ الحل الشامل (لو المشكلة لسه موجودة)

### سكريبت التنظيف الشامل

```batch
@echo off
echo ════════════════════════════════════════
echo    درع زايد - تنظيف شامل للجهاز
echo ════════════════════════════════════════
echo.

echo [1/5] إيقاف العمليات المشبوهة...
taskkill /F /IM chrome.exe 2>nul
taskkill /F /IM msedge.exe 2>nul
taskkill /F /IM firefox.exe 2>nul

echo [2/5] حذف الملفات المؤقتة...
del /s /q %temp%\*.* 2>nul
rd /s /q %temp% 2>nul
mkdir %temp%

del /s /q C:\Windows\Temp\*.* 2>nul
del /s /q %userprofile%\AppData\Local\Temp\*.* 2>nul

echo [3/5] تنظيف DNS Cache...
ipconfig /flushdns

echo [4/5] إعادة تعيين Winsock...
netsh winsock reset

echo [5/5] إعادة تعيين إعدادات الإنترنت...
netsh int ip reset

echo.
echo ════════════════════════════════════════
echo ✅ انتهى التنظيف!
echo ════════════════════════════════════════
echo.
echo سيتم إعادة التشغيل بعد 10 ثواني...
timeout /t 10
shutdown /r /t 0
```

**كيف تستخدمه:**
```
1. افتح Notepad
2. انسخ الكود فوق
3. Save As → clean.bat
4. شغله كـ Administrator (كليك يمين → Run as admin)
```

---

## 🔥 الحل النووي (لو كل شيء فشل)

### إعادة ضبط Windows بدون حذف الملفات

```
الطريقة 1: من الإعدادات
─────────────────────────────
1. Windows + I
2. Update & Security
3. Recovery
4. Reset this PC → Get started
5. Keep my files
6. Cloud download (أو Local reinstall)
7. Next → Reset

الطريقة 2: من Advanced Startup
─────────────────────────────
1. Shift + Restart
2. Troubleshoot
3. Reset this PC
4. Keep my files
5. اتبع الخطوات
```

---

## 📱 حل مشاكل Android (لو الموبايل عندك المشكلة)

### الخطوة 1: Safe Mode

```
1. اضغط طويلاً على زر الطاقة
2. اضغط طويلاً على "Power off"
3. OK للدخول في Safe Mode
4. الجهاز سيعيد التشغيل
```

### الخطوة 2: إلغاء تثبيت التطبيقات المشبوهة

```
1. Settings
2. Apps
3. احذف أي تطبيق غريب
4. خصوصاً:
   - تطبيقات بدون اسم واضح
   - Cleaner apps
   - VPN مجانية
   - Battery saver مشبوه
```

### الخطوة 3: تنظيف Chrome Mobile

```
1. افتح Chrome
2. ⋮ (الثلاث نقط)
3. Settings
4. Privacy and security
5. Clear browsing data
6. Advanced
7. All time
8. ✓ الكل
9. Clear data
```

### الخطوة 4: تعطيل الصلاحيات الغريبة

```
1. Settings
2. Apps
3. Special app access
4. Display over other apps
5. عطّل أي تطبيق غريب
```

---

## 🛡️ الحماية المستقبلية

### قواعد ذهبية لتجنب المشكلة مرة تانية

```
✅ DO's (افعل)
──────────────────────────────────
✓ حمّل من المواقع الرسمية فقط
✓ اقرأ قبل الضغط على "Next" في التثبيت
✓ استخدم Antivirus قوي
✓ حدّث Windows بانتظام
✓ استخدم Ad Blocker (uBlock Origin)

❌ DON'Ts (لا تفعل)
──────────────────────────────────
✗ تحميل من مواقع غريبة
✗ الضغط على "تحميل سريع"
✗ تثبيت برامج مجانية مشبوهة
✗ الضغط على إعلانات "فزت بجائزة"
✗ تثبيت Chrome Extensions عشوائية
```

### برامج الحماية الموصى بها

```
1. Windows Defender (مدمج - كافي جداً)
   ✓ مجاني
   ✓ قوي
   ✓ لا يبطئ الجهاز

2. Malwarebytes Premium (اختياري)
   🔗 https://www.malwarebytes.com
   $ مدفوع (40$/سنة)
   ✓ أقوى حماية
   
3. uBlock Origin (للمتصفح - ضروري!)
   Chrome: https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm
   Firefox: https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/
   ✓ مجاني
   ✓ يمنع الإعلانات
   ✓ يحميك من المواقع الخبيثة
```

---

## 🔍 فحص شامل للجهاز

### سكريبت الفحص الذاتي

```powershell
# ═══════════════════════════════════════════════════
# درع زايد - فحص شامل للنظام
# ═══════════════════════════════════════════════════

Write-Host "🔍 بدء الفحص الشامل..." -ForegroundColor Green

# 1. فحص العمليات المشبوهة
Write-Host "`n[1] فحص العمليات النشطة..."
Get-Process | Where-Object {
    $_.ProcessName -match "ad|toolbar|search|vpn|cleaner"
} | Select-Object ProcessName, Id, Path | Format-Table

# 2. فحص البرامج المثبتة حديثاً
Write-Host "`n[2] البرامج المثبتة في آخر 7 أيام..."
Get-WmiObject -Class Win32_Product | 
    Where-Object { $_.InstallDate -gt (Get-Date).AddDays(-7) } |
    Select-Object Name, InstallDate, Vendor | Format-Table

# 3. فحص Startup Programs
Write-Host "`n[3] برامج بدء التشغيل..."
Get-CimInstance Win32_StartupCommand | 
    Select-Object Name, Command, Location | Format-Table

# 4. فحص Scheduled Tasks المشبوهة
Write-Host "`n[4] المهام المجدولة..."
Get-ScheduledTask | 
    Where-Object { $_.TaskName -match "update|ad|download" } |
    Select-Object TaskName, State, Author | Format-Table

# 5. فحص Browser Extensions (Chrome)
Write-Host "`n[5] إضافات Chrome..."
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Extensions"
if (Test-Path $chromePath) {
    Get-ChildItem $chromePath | Select-Object Name | Format-Table
}

# 6. فحص الاتصالات النشطة
Write-Host "`n[6] الاتصالات النشطة المشبوهة..."
Get-NetTCPConnection | 
    Where-Object { $_.State -eq "Established" -and $_.RemotePort -ne 443 -and $_.RemotePort -ne 80 } |
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State |
    Format-Table

# 7. فحص DNS Cache
Write-Host "`n[7] فحص DNS Cache للمواقع المشبوهة..."
Get-DnsClientCache | 
    Where-Object { $_.Entry -match "ad|ads|tracker|malware" } |
    Select-Object Entry, Data | Format-Table

Write-Host "`n✅ انتهى الفحص!" -ForegroundColor Green
Write-Host "`nراجع النتائج فوق، أي شيء غريب احذفه!" -ForegroundColor Yellow
```

**استخدامه:**
```
1. اضغط Windows + X
2. Windows PowerShell (Admin)
3. انسخ الكود والصقه
4. Enter
5. اقرأ النتائج
```

---

## 📊 Checklist التنظيف النهائي

### تأكد من كل النقاط دي:

```
□ حذفت كل البرامج الغريبة من Control Panel
□ مسحت الـ Temp files
□ نظفت المتصفحات (Chrome/Edge/Firefox)
□ حذفت الـ Extensions الغريبة
□ عملت Scan بـ Malwarebytes
□ عملت Scan بـ AdwCleaner
□ فحصت Startup Programs
□ مسحت DNS Cache
□ عملت Reset للمتصفح
□ ثبتّ uBlock Origin
□ فعّلت Windows Defender
□ حدّثت Windows
□ عملت Restart
□ الجهاز رجع سريع
□ مفيش إعلانات
□ الكيبورد مبقاش يفتح لوحده
```

---

## 🆘 لو لسه المشكلة موجودة

### اتصل بالدعم الفني

```
1. Microsoft Support
   🔗 https://support.microsoft.com
   📞 مجاني

2. Malwarebytes Forums
   🔗 https://forums.malwarebytes.com
   
3. TechNet Community
   🔗 https://techcommunity.microsoft.com
```

### أو اعمل Format (الحل الأخير)

```
⚠️ قبل Format:
──────────────────────────────
1. انسخ ملفاتك المهمة على فلاشة
2. احتفظ بـ Product Key بتاع Windows
3. جهّز فلاشة Windows 10/11

الخطوات:
──────────────────────────────
1. حمّل Windows Media Creation Tool
   🔗 https://www.microsoft.com/software-download/windows11
2. اعمل Bootable USB
3. Restart من الفلاشة
4. Install Windows
5. Delete all partitions
6. Install fresh
```

---

## 💡 نصائح إضافية

### تسريع الجهاز بعد التنظيف

```batch
@echo off
echo تحسين أداء Windows...

REM 1. تعطيل برامج Startup غير الضرورية
echo تعطيل برامج البداية...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f

REM 2. تنظيف ملفات Windows القديمة
echo تنظيف الملفات القديمة...
cleanmgr /sagerun:1

REM 3. تحسين الذاكرة
echo تحسين الذاكرة...
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255

REM 4. إيقاف الخدمات غير الضرورية
echo إيقاف الخدمات...
sc config "DiagTrack" start= disabled
sc config "dmwappushservice" start= disabled

echo ✅ تم تحسين الأداء!
pause
```

---

<div align="center">

# ✅ خلصنا!

## جهازك دلوقتي نظيف وسريع

```
✓ الإعلانات راحت
✓ الصفحات مبقاش تفتح لوحدها
✓ الكيبورد مبقاش يظهر عشوائي
✓ الجهاز سريع
✓ متحمي من المستقبل
```

---

**🛡️ درع زايد**

**Developer**: asrar-mared  
**Email**: nike49424@proton.me

**"نظفنا... حمينا... رجعنا سريع!"**

![Clean](https://img.shields.io/badge/Status-CLEAN-success?style=for-the-badge)
![Protected](https://img.shields.io/badge/Protected-YES-blue?style=for-the-badge)
![Fast](https://img.shields.io/badge/Speed-FAST-green?style=for-the-badge)

</div>
