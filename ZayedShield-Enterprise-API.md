# 🚀 Professional API - Enterprise Level REST API

[![Node.js](https://img.shields.io/badge/Node.js-16+-green.svg)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-4.18+-blue.svg)](https://expressjs.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-5.0+-green.svg)](https://www.mongodb.com/)
[![Redis](https://img.shields.io/badge/Redis-7.0+-red.svg)](https://redis.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📋 وصف المشروع

API احترافي مبني بـ Node.js و Express مع جميع المعايير العالمية للمشاريع التجارية:

- 🔐 **مصادقة وتفويض كاملة** مع JWT
- 🛡️ **حماية متقدمة** ضد OWASP Top 10
- 📊 **مراقبة وقياسات** مع Prometheus & Grafana
- 🚀 **أداء عالي** مع Redis Cache
- 📝 **توثيق تلقائي** مع Swagger
- 🐳 **جاهز للDocker** مع docker-compose كامل
- ⚡ **قابل للتوسع** مع PM2 clustering

## 🏗️ البنية التقنية

```
📁 professional-api/
├── 📄 server.js              # الملف الرئيسي للAPI
├── 📦 package.json           # مكتبات المشروع
├── 🔧 ecosystem.config.js    # إعدادات PM2
├── 🐳 Dockerfile            # Docker configuration
├── 🐳 docker-compose.yml    # Full environment setup
├── 🔒 .env.example          # مثال المتغيرات البيئية
├── 📁 scripts/              # سكريبتات الإدارة
│   ├── deploy.js            # نشر المشروع
│   ├── migrate.js           # migration قاعدة البيانات
│   ├── seed.js             # بيانات تجريبية
│   └── backup.js           # نسخ احتياطية
├── 📁 config/               # ملفات الإعدادات
├── 📁 logs/                 # ملفات السجلات
└── 📁 uploads/              # الملفات المرفوعة
```

## ⚡ التشغيل السريع

### 1. 📥 تحميل وإعداد المشروع
```bash
# استنساخ المشروع
git clone https://github.com/yourusername/professional-api.git
cd professional-api

# تثبيت المكتبات
npm install

# إعداد المتغيرات البيئية
cp .env.example .env
# عدّل الملف حسب إعداداتك

# إنشاء المجلدات المطلوبة
mkdir -p logs uploads temp
```

### 2. 🚀 التشغيل مع Docker (الأسرع والأفضل)
```bash
# تشغيل كامل (API + MongoDB + Redis + Monitoring)
docker-compose up -d

# فقط الخدمات الأساسية
docker-compose up -d api mongodb redis

# مع المراقبة الكاملة
docker-compose --profile full up -d
```

### 3. 🛠️ التشغيل اليدوي (للتطوير)
```bash
# تأكد من تشغيل MongoDB و Redis
# MongoDB: mongod
# Redis: redis-server

# تشغيل التطوير مع hot-reload
npm run dev

# أو التشغيل العادي
npm start
```

## 📚 الـ API Endpoints

### 🔐 Authentication
```http
POST /api/v1/auth/register    # تسجيل مستخدم جديد
POST /api/v1/auth/login       # تسجيل الدخول
```

### 👥 Users
```http
GET    /api/v1/users/me       # الملف الشخصي
PUT    /api/v1/users/me       # تحديث الملف الشخصي  
GET    /api/v1/users          # جميع المستخدمين (Admin فقط)
```

### 📝 Posts
```http
GET    /api/v1/posts          # جميع المنشورات
POST   /api/v1/posts          # إنشاء منشور
GET    /api/v1/posts/:id      # منشور محدد
PUT    /api/v1/posts/:id      # تحديث منشور
DELETE /api/v1/posts/:id      # حذف منشور
```

### 📊 System
```http
GET /api/v1/health            # فحص صحة النظام
GET /api/v1/metrics           # قياسات الأداء
```

## 🔧 إعدادات متقدمة

### 🎯 متغيرات البيئة المهمة
```bash
# الأساسيات
NODE_ENV=production
PORT=3000
JWT_SECRET=your-super-secret-key

# قواعد البيانات
MONGO_URL=mongodb://localhost:27017/professional_api
REDIS_URL=redis://localhost:6379

# الحماية
CORS_ORIGINS=https://yourapp.com
RATE_LIMIT_MAX=100
MAX_REQUEST_SIZE=10mb
```

### 🛡️ ميزات الحماية
- **Helmet.js** - حماية HTTP headers
- **CORS** - تحكم في مصادر الطلبات
- **Rate Limiting** - منع الهجمات
- **Input Validation** - فحص البيانات الواردة
- **JWT Authentication** - مصادقة آمنة
- **Password Hashing** - تشفير كلمات المرور
- **Anti-tampering** - منع التلاعب

### 📊 المراقبة والقياسات
```bash
# Prometheus metrics
http://localhost:9090

# Grafana dashboard  
http://localhost:3001
Username: admin
Password: admin123

# API Documentation
http://localhost:3000/api/docs

# Health Check
http://localhost:3000/api/v1/health
```

## 🚀 النشر والإنتاج

### 🐳 مع Docker (الأفضل)
```bash
# بناء الimage
docker build -t professional-api .

# تشغيل الإنتاج
docker-compose -f docker-compose.yml up -d

# مع المراقبة الكاملة
docker-compose --profile full up -d
```

### ⚙️ مع PM2
```bash
# تشغيل الإنتاج
npm install pm2 -g
pm2 start ecosystem.config.js --env production

# حفظ الإعدادات
pm2 save
pm2 startup

# المراقبة
pm2 monit
```

### 🌐 النشر على الخادم
```bash
# نشر تلقائي
npm run deploy production

# أو يدوياً
pm2 deploy ecosystem.config.js production setup
pm2 deploy ecosystem.config.js production
```

## 🛠️ أدوات التطوير

### 📋 الأوامر المتاحة
```bash
npm run dev          # تشغيل التطوير مع hot-reload
npm run test         # تشغيل الاختبارات
npm run lint         # فحص جودة الكود
npm run build        # بناء المشروع
npm run migrate      # تشغيل migrations
npm run seed         # إضافة بيانات تجريبية
npm run backup       # نسخ احتياطي لقاعدة البيانات
```

### 🧪 اختبار الـ API
```bash
# إنشاء مستخدم جديد
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"Password123!"}'

# تسجيل الدخول
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login":"testuser","password":"Password123!"}'

# الحصول على المنشورات (مع التوكن)
curl -X GET http://localhost:3000/api/v1/posts \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 📊 الأداء والتحسينات

### ⚡ ميزات الأداء
- **Redis Caching** - تخزين مؤقت سريع
- **Database Indexing** - فهرسة قاعدة البيانات
- **Compression** - ضغط الاستجابات
- **Connection Pooling** - إدارة الاتصالات
- **Clustering** - متعدد العمليات

### 📈 القياسات المتاحة
- HTTP request duration
- Request count by endpoint
- Active connections
- Memory usage
- Database queries
- Cache hit/miss ratio

## 🔧 التخصيص والإضافات

### 📝 إضافة endpoint جديد
```javascript
// في setupRoutes()
router.get('/my-endpoint', [
    this.auth.authenticate(),
    query('param').optional().trim()
], async (req, res, next) => {
    try {
        // منطق العمل هنا
        res.json({
            success: true,
            data: { message: 'Hello World!' }
        });
    } catch (error) {
        next(error);
    }
});
```

### 🔌 إضافة middleware جديد
```javascript
// في setupMiddleware()
this.app.use((req, res, next) => {
    // منطق الmiddleware هنا
    next();
});
```

## 🐛 استكشاف الأخطاء

### 📋 مشاكل شائعة وحلولها

**❌ MongoDB connection failed**
```bash
# تأكد من تشغيل MongoDB
sudo systemctl start mongod
# أو
mongod --dbpath /path/to/db
```

**❌ Redis connection failed**
```bash
# تأكد من تشغيل Redis
sudo systemctl start redis
# أو
redis-server
```

**❌ Port 3000 already in use**
```bash
# تغيير البورت في .env
PORT=3001
# أو إيقاف العملية المتصارعة
lsof -ti:3000 | xargs kill
```

### 📊 فحص السجلات
```bash
# جميع السجلات
tail -f logs/combined.log

# الأخطاء فقط
tail -f logs/error.log

# مع Docker
docker-compose logs -f api

# مع PM2
pm2 logs professional-api
```

## 📁 ملفات المشروع

### 📄 القائمة الكاملة للملفات:

1. **`server.js`** - الملف الرئيسي للAPI (من الـ artifact الأول)
2. **`package.json`** - مكتبات المشروع (من artifact الثاني)
3. **`.env.example`** - مثال المتغيرات البيئية (من artifact الثالث)
4. **`Dockerfile`** - Docker setup (من artifact الرابع)
5. **`docker-compose.yml`** - البيئة الكاملة (من artifact الرابع)
6. **`ecosystem.config.js`** - PM2 و scripts الإدارة (من artifact الخامس)

## 📞 الدعم والمساعدة

- 📧 **Email**: nike49424@gmail.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/professional-api/issues)
- 📚 **Documentation**: [API Docs](http://localhost:3000/api/docs)
- 💬 **Discord**: [Join our Discord](https://discord.gg/yourserver)

## 📄 الترخيص

هذا المشروع مرخص تحت [MIT License](LICENSE) - انظر ملف LICENSE للتفاصيل.

## 🙏 الشكر والتقدير

شكر خاص لجميع المساهمين ومطوري المكتبات المستخدمة في هذا المشروع.

---

**🚀 مصنوع بـ ❤️ للمطورين العرب**

> "الكود النظيف ليس مجرد كود يعمل، بل كود يفهمه المطورون الآخرون" - Clean Code Principles
