# 🛡️ WARRIOR ENS API - Professional Edition

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/warrior/ens-api)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Node](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org)
[![TypeScript](https://img.shields.io/badge/typescript-5.5.4-blue.svg)](https://www.typescriptlang.org/)

Professional-grade ENS (Ethereum Name Service) API with advanced features including multi-provider fallback, intelligent caching, WebSocket support, comprehensive monitoring, and enterprise-level security.

---

## ✨ Features

### Core Features
- 🔍 **ENS Resolution** - Resolve ENS names to addresses
- 🔄 **Reverse Lookup** - Look up ENS names from addresses
- 🖼️ **Avatar Fetching** - Get ENS avatars
- 📝 **Text Records** - Retrieve all ENS text records
- 📦 **Batch Operations** - Process multiple requests in one call
- 🔎 **Search** - Search for available ENS names

### Advanced Features
- ⚡ **Multi-Provider Fallback** - Automatic failover across 4+ RPC providers
- 💾 **Intelligent Caching** - Dual-layer cache (Memory + Redis optional)
- 🔌 **WebSocket Support** - Real-time blockchain updates
- 🛡️ **Enterprise Security** - Helmet, CORS, rate limiting, input validation
- 📊 **Comprehensive Monitoring** - Health checks, stats, metrics
- 🚀 **High Performance** - Compression, connection pooling, optimized queries
- 📈 **Graceful Degradation** - Falls back gracefully on failures
- 🔐 **Type Safety** - Full TypeScript implementation
- 🐳 **Docker Ready** - Production-ready containerization
- 📝 **Detailed Logging** - Request logging, error tracking

---

## 🚀 Quick Start

### Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0
- Redis (optional but recommended)

### Installation

```bash
# Clone repository
git clone https://github.com/warrior/ens-api.git
cd ens-api

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your settings
nano .env
```

### Development

```bash
# Start in development mode with hot reload
npm run dev

# Or use docker-compose
docker-compose up
```

### Production

```bash
# Build TypeScript
npm run build

# Start production server
npm run start:prod

# Or use Docker
docker-compose -f docker-compose.yml up -d
```

---

## 📋 API Endpoints

### Base URL
```
http://localhost:3000
```

### Available Endpoints

#### 1. Health Check
```bash
GET /health

Response:
{
  "status": "healthy",
  "uptime": 123.45,
  "blockchain": {
    "connected": true,
    "blockNumber": 19234567,
    "network": "mainnet"
  },
  "cache": {
    "hits": 150,
    "misses": 50,
    "hitRate": "75.00%"
  }
}
```

#### 2. Resolve ENS Name
```bash
GET /resolve/:name

Example:
GET /resolve/vitalik.eth

Response:
{
  "name": "vitalik.eth",
  "address": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
  "timestamp": "2026-02-02T...",
  "cached": false
}
```

#### 3. Reverse Lookup
```bash
GET /reverse/:address

Example:
GET /reverse/0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045

Response:
{
  "address": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
  "name": "vitalik.eth",
  "timestamp": "2026-02-02T...",
  "cached": false
}
```

#### 4. Get Avatar
```bash
GET /avatar/:name

Example:
GET /avatar/vitalik.eth

Response:
{
  "name": "vitalik.eth",
  "avatar": "https://...",
  "timestamp": "2026-02-02T...",
  "cached": false
}
```

#### 5. Get Text Records
```bash
GET /records/:name

Example:
GET /records/vitalik.eth

Response:
{
  "name": "vitalik.eth",
  "records": {
    "email": "vitalik@ethereum.org",
    "url": "https://vitalik.ca",
    "com.twitter": "VitalikButerin",
    "com.github": "vbuterin",
    ...
  },
  "timestamp": "2026-02-02T...",
  "cached": false
}
```

#### 6. Batch Operations (NEW)
```bash
POST /batch
Content-Type: application/json

Body:
{
  "operations": [
    { "type": "resolve", "name": "vitalik.eth" },
    { "type": "reverse", "address": "0x..." },
    { "type": "resolve", "name": "ens.eth" }
  ]
}

Response:
{
  "results": [
    {
      "index": 0,
      "status": "fulfilled",
      "data": { "name": "vitalik.eth", "address": "0x..." }
    },
    ...
  ]
}
```

#### 7. Search (NEW)
```bash
GET /search/:query

Example:
GET /search/warrior

Response:
{
  "query": "warrior",
  "suggestions": ["warrior.eth", "warrior-dao.eth", "warrior-nft.eth"],
  "found": [
    { "name": "warrior.eth", "address": "0x...", "available": false }
  ]
}
```

#### 8. Statistics (NEW)
```bash
GET /stats

Response:
{
  "uptime": 12345.67,
  "memory": {
    "heapUsed": "45.23 MB",
    "heapTotal": "60.00 MB",
    "rss": "120.50 MB"
  },
  "cache": {
    "hits": 500,
    "misses": 100,
    "hitRate": "83.33%",
    "memoryKeys": 25
  },
  "provider": {
    "totalProviders": 4,
    "currentProvider": 0,
    "failures": {}
  }
}
```

---

## 🔌 WebSocket API

### Connection
```javascript
const ws = new WebSocket('ws://localhost:8080');

ws.on('open', () => {
  console.log('Connected to ENS live feed');
});

ws.on('message', (data) => {
  const message = JSON.parse(data);
  
  if (message.type === 'welcome') {
    console.log(message.message);
  }
  
  if (message.type === 'block') {
    console.log('New block:', message.blockNumber);
  }
});
```

### Subscribe to Updates
```javascript
ws.send(JSON.stringify({
  type: 'subscribe',
  channel: 'blocks'
}));
```

---

## ⚙️ Configuration

### Environment Variables

```bash
# Server
NODE_ENV=production
PORT=3000
WS_PORT=8080

# Cache
USE_REDIS=true
REDIS_URL=redis://localhost:6379
CACHE_TTL=300

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000  # 15 minutes
RATE_LIMIT_MAX_REQUESTS=100   # 100 requests per window

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com

# WebSocket
WS_HEARTBEAT_INTERVAL=30000
WS_MAX_CLIENTS=1000
```

---

## 🐳 Docker Deployment

### Using Docker Compose (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api

# Stop services
docker-compose down

# Start with Redis UI (for debugging)
docker-compose --profile debug up -d
```

### Using Docker Directly

```bash
# Build image
docker build -t warrior-ens-api .

# Run container
docker run -d \
  -p 3000:3000 \
  -p 8080:8080 \
  --name ens-api \
  warrior-ens-api

# View logs
docker logs -f ens-api
```

---

## 📊 Performance & Caching

### Cache Strategy

The API implements a **dual-layer caching** system:

1. **Memory Cache** (L1) - Ultra-fast, in-process cache
2. **Redis Cache** (L2) - Persistent, distributed cache

**Benefits:**
- ⚡ Reduced RPC calls (90%+ cache hit rate)
- 🚀 Faster response times (< 10ms for cached)
- 💰 Lower infrastructure costs
- 📈 Higher throughput

### Performance Metrics

| Operation | Without Cache | With Cache |
|-----------|---------------|------------|
| Resolve ENS | ~500ms | ~5ms |
| Reverse Lookup | ~400ms | ~5ms |
| Get Records | ~800ms | ~8ms |
| Batch (10 items) | ~3000ms | ~50ms |

---

## 🛡️ Security Features

### Implemented Protections

✅ **Helmet** - Security headers (XSS, CSP, etc.)  
✅ **CORS** - Configurable cross-origin access  
✅ **Rate Limiting** - Prevent abuse (100 req/15min)  
✅ **Input Validation** - Sanitize all inputs  
✅ **Request Size Limits** - Max 10KB payloads  
✅ **Error Handling** - No information leakage  
✅ **Non-Root User** - Docker runs as nodejs user  

### Best Practices

```bash
# Run security audit
npm run security:check

# Fix vulnerabilities
npm run security:fix

# Check for outdated packages
npm outdated
```

---

## 📈 Monitoring & Logging

### Health Monitoring

```bash
# Check API health
curl http://localhost:3000/health

# Check detailed stats
curl http://localhost:3000/stats
```

### Logging

All requests are logged with:
- Timestamp
- Method & URL
- Status code
- Response time
- Request ID

Example log:
```
[2026-02-02T12:34:56.789Z] GET /resolve/vitalik.eth 200 125ms
```

### Error Tracking

Errors include:
- Error message
- Request ID
- Timestamp
- Stack trace (development only)

---

## 🔧 Development

### Available Scripts

```bash
# Development with hot reload
npm run dev

# Build TypeScript
npm run build

# Run tests
npm test

# Run tests in watch mode
npm test:watch

# Type checking
npm run type-check

# Linting
npm run lint
npm run lint:fix

# Code formatting
npm run format

# Clean build files
npm run clean
```

### Project Structure

```
warrior-ens-api/
├── src/
│   ├── index.ts              # Main application
│   ├── config/               # Configuration
│   ├── routes/               # API routes
│   ├── services/             # Business logic
│   ├── middleware/           # Express middleware
│   ├── utils/                # Helper functions
│   └── types/                # TypeScript types
├── dist/                     # Built files
├── tests/                    # Test files
├── docker-compose.yml        # Docker compose config
├── Dockerfile                # Docker build file
├── tsconfig.json             # TypeScript config
├── package.json              # Dependencies
└── .env.example              # Environment template
```

---

## 🧪 Testing

### Run Tests

```bash
# Unit tests
npm test

# E2E tests
npm run test:e2e

# Coverage report
npm run test:coverage
```

### Example Test

```typescript
describe('ENS Resolution', () => {
  it('should resolve vitalik.eth', async () => {
    const response = await request(app)
      .get('/resolve/vitalik.eth')
      .expect(200);
    
    expect(response.body.name).toBe('vitalik.eth');
    expect(response.body.address).toMatch(/^0x[a-fA-F0-9]{40}$/);
  });
});
```

---

## 🚨 Troubleshooting

### Common Issues

#### 1. RPC Provider Errors

**Problem**: "All providers failed"

**Solution**:
```bash
# Check provider status
curl https://eth.llamarpc.com

# Add more providers in .env
RPC_PROVIDER_1=https://eth.llamarpc.com
RPC_PROVIDER_2=https://rpc.ankr.com/eth
RPC_PROVIDER_3=https://cloudflare-eth.com
```

#### 2. Redis Connection Issues

**Problem**: "Redis connection failed"

**Solution**:
```bash
# Check Redis status
redis-cli ping

# Or disable Redis (fallback to memory)
USE_REDIS=false
```

#### 3. Rate Limit Hit

**Problem**: 429 Too Many Requests

**Solution**:
```bash
# Increase limits in .env
RATE_LIMIT_MAX_REQUESTS=200
RATE_LIMIT_WINDOW_MS=900000
```

---

## 📚 Advanced Usage

### Custom RPC Providers

```typescript
// Add Alchemy or Infura
const CONFIG = {
  RPC_PROVIDERS: [
    `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}`,
    `https://mainnet.infura.io/v3/${INFURA_KEY}`,
    "https://eth.llamarpc.com",
  ],
};
```

### Custom Cache TTL

```typescript
// Set different TTL for different data
await cache.set('resolve:vitalik.eth', result, 600);  // 10 minutes
await cache.set('avatar:vitalik.eth', result, 3600);  // 1 hour
```

### WebSocket Authentication

```typescript
wss.on('connection', (ws, req) => {
  const token = req.headers['authorization'];
  
  if (!isValidToken(token)) {
    ws.close(1008, 'Unauthorized');
    return;
  }
  
  // Connection authenticated
});
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Write tests for new features
- Follow TypeScript best practices
- Update documentation
- Run linting before commit
- Keep commits atomic and descriptive

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Ethereum Foundation** - ENS Protocol
- **ethers.js** - Ethereum library
- **Express.js** - Web framework
- **Redis** - Caching solution

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/warrior/ens-api/issues)
- **Email**: nike49424@gmail.com 
- **Twitter**: [@nike49424](https://twitter.com/nike49424)

---

## 🗺️ Roadmap

### v2.1.0 (Q2 2026)
- [ ] GraphQL API
- [ ] ENS subdomain support
- [ ] Advanced analytics dashboard
- [ ] Prometheus metrics export

### v2.2.0 (Q3 2026)
- [ ] Multi-chain support (Polygon, Optimism)
- [ ] NFT metadata integration
- [ ] Advanced caching strategies
- [ ] Admin dashboard

### v3.0.0 (Q4 2026)
- [ ] Microservices architecture
- [ ] Kubernetes deployment
- [ ] AI-powered name suggestions
- [ ] Enterprise features

---

## ⭐ Star History

If you find this project useful, please consider giving it a star ⭐

---

**Built with ❤️ by Digital Warriors**

🛡️ **Stay Secure. Stay Updated. Stay Warrior.**

