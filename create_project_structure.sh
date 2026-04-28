#!/bin/bash

# =============================================================================
# سكريپت إنشاء الهيكل المحترف لمشروع درع زايد للأمن السيبراني
# =============================================================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧞‍♂️ إنشاء مشروع درع زايد للأمن السيبراني${NC}"
echo "=================================================="

# إنشاء المجلد الرئيسي
PROJECT_NAME="digital-genie-cybersecurity"
echo -e "${GREEN}📁 إنشاء المجلد الرئيسي...${NC}"
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# إنشاء هيكل المجلدات
echo -e "${GREEN}🏗️ إنشاء هيكل المجلدات...${NC}"

# Scripts directory
mkdir -p scripts/{core,network,security,forensics,automation}

# Config directory  
mkdir -p config/{settings,templates,wordlists}

# Tools directory
mkdir -p tools/{python,nodejs,go,rust}

# Docs directory
mkdir -p docs/{user-guide,developer,tutorials}

# Tests directory
mkdir -p tests/{unit,integration,performance}

# Data directory
mkdir -p data/{reports/{vulnerability_reports,network_scans,system_logs},analytics/{performance_metrics,usage_statistics},backups/{config_backups,system_snapshots}}

# Resources directory
mkdir -p resources/{images/{screenshots,diagrams},videos/tutorials,references}

# Docker directory
mkdir -p docker/{images/{kali-tools,web-scanner,forensics-lab},scripts}

# Web directory
mkdir -p web/{dashboard/{css,js,api},reports/templates,auth}

# Mobile directory
mkdir -p mobile/{android/SecurityApp,ios/CyberTools}

# GitHub directory
mkdir -p .github/{workflows,ISSUE_TEMPLATE}

echo -e "${YELLOW}📝 إنشاء الملفات الأساسية...${NC}"

# README.md الرئيسي
cat > README.md << 'EOF'
# 🧞‍♂️ درع زايد للأمن السيبراني

<div align="center">
  <img src="resources/images/logo.png" alt="Digital Genie Logo" width="200"/>
  
  [![GitHub Stars](https://img.shields.io/github/stars/nike1212a/digital-genie-cybersecurity)](https://github.com/nike1212a/digital-genie-cybersecurity/stargazers)
  [![GitHub Forks](https://img.shields.io/github/forks/nike1212a/digital-genie-cybersecurity)](https://github.com/nike1212a/digital-genie-cybersecurity/network)
  [![License](https://img.shields.io/github/license/nike1212a/digital-genie-cybersecurity)](LICENSE)
  [![Arabic](https://img.shields.io/badge/Language-Arabic-green)](README.md)
</div>

## 🎯 نبذة عن المشروع

**المارد الرقمي للأمن السيبراني** هو مشروع شامل ومتقدم يهدف إلى توفير مجموعة متكاملة من الأدوات والسكريپتات للأمن السيبراني باللغة العربية. يضم المشروع أكثر من 50 أداة متخصصة في مجالات مختلفة من الأمن الرقمي.

## ✨ المميزات الرئيسية

- 🔧 **إعداد تلقائي شامل** - سكريپت واحد لتثبيت جميع الأدوات
- 🌐 **أدوات شبكة متقدمة** - مسح المنافذ والتحليل الشبكي
- 🔐 **أدوات أمان متخصصة** - كسر التشفير وفحص الثغرات
- 📊 **الطب الشرعي الرقمي** - تحليل السجلات واسترداد البيانات
- 🤖 **أتمتة متقدمة** - تشغيل آلي وتقارير ذكية
- 🌐 **واجهة ويب تفاعلية** - لوحة تحكم شاملة
- 📱 **تطبيقات محمولة** - مراقبة عن بُعد
- 🐳 **دعم Docker** - بيئة منعزلة وآمنة

## 🚀 البدء السريع

### 1. استنساخ المشروع
```bash
git clone https://github.com/asrarmared/digital-genie-cybersecurity.git
cd digital-genie-cybersecurity
```

### 2. تشغيل الإعداد التلقائي
```bash
chmod +x scripts/core/setup_security_lab.sh
./scripts/core/setup_security_lab.sh
```

### 3. تشغيل لوحة التحكم
```bash
cd web/dashboard
python3 -m http.server 8080
```

## 📋 متطلبات النظام

- **نظام التشغيل**: Linux (Ubuntu 20.04+ مفضل)
- **الذاكرة**: 4GB RAM كحد أدنى
- **التخزين**: 20GB مساحة فارغة
- **الاتصال**: إنترنت مستقر لتحميل الأدوات

## 🏗️ هيكل المشروع

```
digital-genie-cybersecurity/
├── 📁 scripts/          # السكريپتات الأساسية
├── 📁 config/           # ملفات التكوين
├── 📁 tools/            # أدوات البرمجة
├── 📁 docs/             # الوثائق والأدلة
├── 📁 web/              # واجهة الويب
├── 📁 mobile/           # التطبيقات المحمولة
└── 📁 docker/           # حاويات Docker
```

## 🛠️ الأدوات المتضمنة

### 🌐 أدوات الشبكة
- **Port Scanner** - ماسح منافذ متقدم
- **Network Monitor** - مراقب الشبكة الفوري
- **WiFi Analyzer** - محلل شبكات اللاسلكي
- **DNS Enumerator** - تعداد DNS شامل

### 🔐 أدوات الأمان
- **Vulnerability Scanner** - فحص الثغرات الشامل
- **Password Generator** - مولد كلمات مرور قوية
- **Hash Cracker** - كاسر التشفير متعدد الخيوط
- **Malware Detector** - كاشف البرمجيات الخبيثة

### 📊 الطب الشرعي الرقمي
- **Log Analyzer** - محلل السجلات المتقدم
- **File Carver** - استرداد الملفات المحذوفة
- **Memory Analyzer** - تحليل ذاكرة النظام
- **Disk Forensics** - الطب الشرعي للقرص

## 📚 الوثائق

- 📖 [دليل المستخدم](docs/user-guide/quick-start.md)
- 👨‍💻 [دليل المطور](docs/developer/api-reference.md)
- 🎓 [الدروس التعليمية](docs/tutorials/beginner-guide.md)
- 🔧 [استكشاف الأخطاء](docs/user-guide/troubleshooting.md)

## 🤝 المساهمة

نرحب بمساهماتكم! يرجى قراءة [دليل المساهمة](CONTRIBUTING.md) قبل إرسال Pull Request.

## 📜 الترخيص

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للتفاصيل.

## 👨‍💻 المطور

- **المحارب** - [GitHub Profile](https://github.com/asrarmared)

## 🙏 شكر خاص

شكر خاص لجميع المساهمين في مجتمع الأمن السيبراني العربي.

---

<div align="center">
  <strong>⭐ إذا أعجبك المشروع، لا تنس إعطاؤه نجمة! ⭐</strong>
</div>
EOF

# LICENSE
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2026 asrarmared درع  زايد 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# .gitignore
cat > .gitignore << 'EOF'
# Operating System Files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE Files
.vscode/
.idea/
*.swp
*.swo
*~

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Go
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out

# Rust
target/
Cargo.lock

# Java
*.class
*.jar
*.war
*.ear
*.nar
hs_err_pid*

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
lib-cov

# Coverage directory used by tools like istanbul
coverage

# nyc test coverage
.nyc_output

# Grunt intermediate storage
.grunt

# Bower dependency directory
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons
build/Release

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# Security sensitive files
*.key
*.pem
*.p12
*.pfx
config/secrets/
data/sensitive/

# Database files
*.db
*.sqlite
*.sqlite3

# Temporary files
tmp/
temp/
.tmp/

# Reports and data
data/reports/*
!data/reports/.gitkeep
data/backups/*
!data/backups/.gitkeep

# Docker
.docker/
EOF

# CONTRIBUTING.md
cat > CONTRIBUTING.md << 'EOF'
# 🤝 دليل المساهمة في المارد الرقمي للأمن السيبراني

## 🎯 كيفية المساهمة

### 1. إبلاغ عن الأخطاء
- استخدم [GitHub Issues](https://github.com/nike1212a/digital-genie-cybersecurity/issues)
- قدم وصفاً مفصلاً للخطأ
- أرفق لقطات شاشة عند الإمكان
- اذكر نظام التشغيل والإصدار

### 2. اقتراح ميزات جديدة
- افتح Issue جديد مع تسمية "Feature Request"
- اشرح الميزة المقترحة بالتفصيل
- وضح فائدة الميزة للمجتمع

### 3. المساهمة بالكود
1. Fork المشروع
2. أنشئ branch جديد (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'Add amazing feature'`)
4. Push للـ branch (`git push origin feature/amazing-feature`)
5. افتح Pull Request

## 📋 معايير الكود

### Python
- اتبع PEP 8
- استخدم docstrings للوظائف
- أضف type hints حيث أمكن

### Bash Scripts
- استخدم `#!/bin/bash`
- أضف تعليقات مفصلة
- تحقق من المتغيرات قبل الاستخدام

### Documentation
- اكتب باللغة العربية أولاً
- أضف ترجمة إنجليزية عند الضرورة
- استخدم Markdown للتنسيق

## 🏆 شكر المساهمين
جميع المساهمين سيتم ذكرهم في قائمة الشكر الخاصة بالمشروع.
EOF

# SECURITY.md
cat > SECURITY.md << 'EOF'
# 🔐 سياسة الأمان

## 🚨 الإبلاغ عن الثغرات الأمنية

إذا وجدت ثغرة أمنية في المشروع، يرجى عدم فتح Issue عام. بدلاً من ذلك:

1. أرسل بريد إلكتروني إلى: security@digital-genie.com
2. اذكر تفاصيل الثغرة
3. أرفق طريقة إعادة إنتاج المشكلة
4. سنرد عليك في غضون 48 ساعة

## 🛡️ الإصدارات المدعومة

| الإصدار | الدعم |
| ------- | ------ |
| 2.0.x   | ✅     |
| 1.9.x   | ✅     |
| < 1.9   | ❌     |

## 🔧 أفضل الممارسات الأمنية

- لا تشارك كلمات المرور في الكود
- استخدم متغيرات البيئة للمعلومات الحساسة
- قم بتحديث الأدوات بانتظام
- فعّل المصادقة الثنائية
EOF

# CHANGELOG.md
cat > CHANGELOG.md << 'EOF'
# 📝 سجل التغييرات

## [2.0.0] - 2025-01-XX

### ✨ ميزات جديدة
- إضافة واجهة ويب تفاعلية
- دعم Docker containers
- تطبيقات محمولة
- نظام تقارير متقدم

### 🔧 تحسينات
- تحسين أداء السكريپتات
- واجهة مستخدم محسنة
- دعم لغات برمجة إضافية

### 🐛 إصلاح الأخطاء
- إصلاح مشكلة في port scanner
- تحسين استقرار النظام

## [1.0.0] - 2026-01-XX

### ✨ الإصدار الأول
- سكريپت الإعداد الأساسي
- أدوات الشبكة الأساسية
- أدوات الأمان المتخصصة
EOF

# VERSION
echo "2.0.0-dev" > VERSION

# requirements.txt للPython
cat > requirements.txt << 'EOF'
#
