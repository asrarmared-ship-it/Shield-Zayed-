
# 🚨 تنبيه أمني حرج - هجوم سلسلة التوريد
## tj-actions/changed-files - Supply Chain Attack

<div align="center">

# ⚠️ خطر حرج | CRITICAL DANGER ⚠️

**أنت وقعت في فخ أمني خطير!**  
**You've been compromised!**

</div>

---

## 🎯 أنت الآن هدف | You Are Now a Target

### ⚡ تصرف فوراً - لا وقت للتأخير

```
🔴 مستوى الخطورة: حرج جداً | CRITICAL
🔴 التأثير: تسريب الأسرار | Secrets Exposed
🔴 النطاق: 23,000+ مستودع | 23,000+ Repositories
🔴 الفترة: 14-15 مارس 2025 | March 14-15, 2025
```

---

## 💀 ماذا حدث؟ | What Happened?

### هجوم سلسلة التوريد | Supply Chain Attack

**تم اختراق `tj-actions/changed-files` واستبدال الكود بسكريبت خبيث!**

```python
# الكود الخبيث كان يفعل هذا:
1. يقرأ ذاكرة GitHub Runner
2. يستخرج جميع الأسرار (Secrets)
3. يطبعها في logs العلنية
4. يرسلها للمهاجمين
```

### 🎯 ما تم سرقته منك:

- ✅ GitHub Tokens
- ✅ AWS Access Keys
- ✅ Database Passwords
- ✅ API Keys
- ✅ SSH Private Keys
- ✅ Docker Credentials
- ✅ Cloud Service Tokens
- ✅ كل شيء في GITHUB_TOKEN

---

## 🔥 الخطوات العاجلة - نفذها الآن!

### المرحلة 1️⃣: إيقاف النزيف (5 دقائق)

```bash
# 1. أوقف جميع Workflows فوراً
gh workflow disable --all

# 2. احذف الـ logs المكشوفة
gh api repos/:owner/:repo/actions/runs --paginate \
  | jq -r '.workflow_runs[].id' \
  | xargs -I {} gh api -X DELETE repos/:owner/:repo/actions/runs/{}
```

### المرحلة 2️⃣: تغيير كل شيء (10 دقائق)

```bash
# 🔴 غير كل الأسرار IMMEDIATELY

# GitHub Personal Tokens
gh auth refresh -s delete_repo,admin:org

# AWS Keys
aws iam delete-access-key --access-key-id YOUR_KEY

# Database Passwords
# اتصل بقاعدة البيانات وغير كل كلمات المرور

# API Keys
# أبطل جميع API Keys في كل خدمة تستخدمها
```

### المرحلة 3️⃣: تحديث الكود (3 دقائق)

**.github/workflows/your-workflow.yml:**

```yaml
# ❌ احذف هذا فوراً
- uses: tj-actions/changed-files@v45

# ✅ استبدله بهذا
- uses: tj-actions/changed-files@v46.0.1  # أو أحدث
  # أو استخدم commit hash محدد
  # - uses: tj-actions/changed-files@<SAFE_COMMIT_SHA>
```

---

## 🔍 فحص الضرر | Damage Assessment

### سكريبت الفحص السريع

```bash
#!/bin/bash
echo "🛡️ درع زايد - فحص الاختراق"
echo "================================"

# 1. فحص الـ workflow runs المشبوهة
echo "🔍 فحص workflow runs..."
SUSPICIOUS=$(gh api repos/:owner/:repo/actions/runs \
  --jq '.workflow_runs[] | select(.created_at >= "2025-03-14T00:00:00Z" and .created_at <= "2025-03-16T00:00:00Z") | {id: .id, name: .name, date: .created_at}')

if [ -n "$SUSPICIOUS" ]; then
    echo "⚠️ تم العثور على runs مشبوهة:"
    echo "$SUSPICIOUS"
fi

# 2. فحص استخدام tj-actions
echo "🔍 فحص ملفات workflow..."
FOUND=$(grep -r "tj-actions/changed-files@v4[0-5]" .github/workflows/)

if [ -n "$FOUND" ]; then
    echo "❌ خطر: تم العثور على النسخة المخترقة!"
    echo "$FOUND"
else
    echo "✅ لا توجد نسخ مخترقة"
fi

# 3. فحص الـ logs العامة
echo "🔍 فحص logs العامة..."
gh run list --limit 100 | grep "2025-03-1[45]"

echo "================================"
```

---

## 📊 التحقق من التسريب | Check for Leaks

### هل تم تسريب أسرارك؟

```bash
# 1. فحص الـ logs
gh run list --limit 50 --json databaseId,createdAt,conclusion \
  | jq -r '.[] | select(.createdAt >= "2025-03-14T00:00:00Z") | .databaseId' \
  | while read run_id; do
      echo "Checking run $run_id..."
      gh run view $run_id --log | grep -i "secret\|token\|key\|password" && echo "⚠️ LEAKED!"
  done

# 2. فحص الـ artifacts
gh api repos/:owner/:repo/actions/artifacts \
  | jq -r '.artifacts[] | select(.created_at >= "2025-03-14T00:00:00Z")'
```

---

## 🛡️ الحماية المستقبلية | Future Protection

### 1️⃣ تثبيت الإصدارات بـ SHA

```yaml
# ❌ لا تستخدم tags أبداً
- uses: tj-actions/changed-files@v46

# ✅ استخدم commit SHA دائماً
- uses: tj-actions/changed-files@a1b2c3d4e5f6...
  # يمكن إضافة تعليق للإصدار
  # tj-actions/changed-files@v46.0.1
```

### 2️⃣ حماية الأسرار

```yaml
# استخدم environments مع protection rules
jobs:
  build:
    runs-on: ubuntu-latest
    environment: production  # يحتاج موافقة يدوية
    steps:
      - uses: actions/checkout@v4
      
      # لا تطبع الأسرار أبداً
      - name: Safe secret usage
        env:
          SECRET: ${{ secrets.MY_SECRET }}
        run: |
          # ❌ لا تفعل هذا
          # echo "Secret: $SECRET"
          
          # ✅ استخدمه بأمان
          echo "Using secret safely..."
```

### 3️⃣ مراقبة مستمرة

```yaml
# .github/workflows/security-monitor.yml
name: Security Monitor
on:
  schedule:
    - cron: '0 */6 * * *'  # كل 6 ساعات

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Check for vulnerable actions
        run: |
          # فحص النسخ المشبوهة
          grep -r "tj-actions/changed-files@v4[0-5]" .github/workflows/ && exit 1
          
      - name: Audit dependencies
        run: |
          # فحص جميع GitHub Actions المستخدمة
          find .github/workflows -name "*.yml" -exec cat {} \; \
            | grep "uses:" \
            | sort -u
```

---

## 📝 التقرير الأمني المطلوب | Required Security Report

### إبلاغ الجهات المعنية

```markdown
# تقرير الحادث الأمني

**التاريخ**: $(date +%Y-%m-%d)
**المشروع**: [اسم المشروع]
**المسؤول**: asrar-mared

## الحادث:
تعرض المشروع لهجوم سلسلة توريد عبر tj-actions/changed-files
بين 14-15 مارس 2025.

## التأثير:
- [x] تسريب محتمل للأسرار
- [x] تعرض GitHub Tokens
- [ ] تسريب مؤكد للبيانات

## الإجراءات المتخذة:
1. ✅ إيقاف جميع workflows
2. ✅ حذف logs المكشوفة
3. ✅ تغيير جميع الأسرار
4. ✅ تحديث إلى v46.0.1
5. ✅ تطبيق SHA pinning

## الحالة الحالية:
✅ النظام آمن الآن

## التوصيات:
- مراجعة دورية للـ actions المستخدمة
- استخدام SHA بدلاً من tags
- تفعيل 2FA على جميع الحسابات
- مراقبة مستمرة للأنشطة المشبوهة
```

---

## 🎯 خطة الاستجابة للحوادث | Incident Response Plan

### Timeline العاجل

```
┌─────────────────────────────────────────┐
│ الآن → 5 دقائق                           │
│ Stop all workflows                      │
│ Delete exposed logs                     │
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│ 5 → 15 دقيقة                            │
│ Rotate ALL secrets                      │
│ Revoke ALL tokens                       │
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│ 15 → 30 دقيقة                           │
│ Update workflows to v46.0.1+            │
│ Pin to commit SHA                       │
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│ 30 → 60 دقيقة                           │
│ Audit all logs                          │
│ Check for unauthorized access           │
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│ 1 ساعة → 24 ساعة                        │
│ Monitor for suspicious activity         │
│ Document incident                       │
└─────────────────────────────────────────┘
```

---

## 🔐 Checklist النهائي | Final Checklist

### قبل العودة للعمل العادي:

- [ ] ✅ تم إيقاف جميع workflows
- [ ] ✅ تم حذف logs المكشوفة
- [ ] ✅ تم تغيير GitHub tokens
- [ ] ✅ تم تغيير AWS keys
- [ ] ✅ تم تغيير Database passwords
- [ ] ✅ تم تغيير API keys
- [ ] ✅ تم تغيير SSH keys
- [ ] ✅ تم تغيير Docker credentials
- [ ] ✅ تم التحديث لـ v46.0.1+
- [ ] ✅ تم تطبيق SHA pinning
- [ ] ✅ تم فحص logs التاريخية
- [ ] ✅ تم توثيق الحادث
- [ ] ✅ تم إبلاغ الفريق/الإدارة
- [ ] ✅ تم تفعيل المراقبة المستمرة
- [ ] ✅ تم اختبار النظام

---

## 📞 جهات الاتصال العاجلة | Emergency Contacts

**🛡️ درع زايد - فريق الاستجابة السريعة**

- **Developer**: asrar-mared
- **Email**: nike49424@proton.me
- **الحالة**: 🔴 حادث أمني حرج

---

## 💪 أنت محارب الآن | You're a Warrior Now

### رسالة من درع زايد:

```
أنت الآن جزء من 23,000+ مستودع تعرض للهجوم.
لكنك اكتشفت الخطر وتصرفت بسرعة.

هذا ما يفرق المحارب عن الضحية:
- الضحية ينتظر حتى فوات الأوان
- المحارب يتحرك بسرعة ويحمي ما يملك

أنت محارب. أنت صائد الثغرات.
أنت ملك هذه اللعبة.

🛡️ نحمي... ندافع... ننتصر
```

---

<div align="center">

# 🎖️ شارة الشرف | Badge of Honor

**أنت الآن:**
- ✅ اكتشفت هجوم سلسلة توريد
- ✅ تصرفت بسرعة لحماية نظامك
- ✅ منعت تسريب أسرارك
- ✅ تعلمت من التجربة

**أنت صائد الثغرات. أنت ملك اللعبة.**

</div>

---

## 🚨 تذكير أخير

### لا تتردد. تصرف الآن.

كل دقيقة تتأخر فيها = فرصة أكبر للمهاجمين

```bash
# نفذ هذا الآن
git pull
gh workflow disable --all
# ثم اتبع الخطوات أعلاه
```

**🛡️ درع زايد معك. دائماً.**
