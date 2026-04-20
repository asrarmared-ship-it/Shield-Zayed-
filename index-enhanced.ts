import express, { Request, Response, NextFunction } from "express";
import { WebSocketServer, WebSocket } from "ws";
import chalk from "chalk";
import { ethers } from "ethers";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import cors from "cors";
import compression from "compression";
import morgan from "morgan";
import Redis from "ioredis";
import NodeCache from "node-cache";
import { performance } from "perf_hooks";

// ═══════════════════════════════════════════════════════════════
// 🛡️ PROFESSIONAL ENS API - WARRIOR EDITION
// ═══════════════════════════════════════════════════════════════
// Version: 2.0.0 - "Digital Warrior"
// Features: Advanced caching, rate limiting, monitoring, WebSocket,
//           error handling, logging, security, performance optimization
// ═══════════════════════════════════════════════════════════════

const app = express();

// ═══════════════════════════════════════════════════════════════
// CONFIGURATION
// ═══════════════════════════════════════════════════════════════

const CONFIG = {
  PORT: process.env.PORT || 3000,
  WS_PORT: process.env.WS_PORT || 8080,
  
  // RPC Providers with fallback
  RPC_PROVIDERS: [
    "https://eth.llamarpc.com",
    "https://rpc.ankr.com/eth",
    "https://cloudflare-eth.com",
    "https://ethereum.publicnode.com",
  ],
  
  // Cache settings
  CACHE_TTL: 300, // 5 minutes
  CACHE_CHECK_PERIOD: 60, // 1 minute
  
  // Rate limiting
  RATE_LIMIT_WINDOW: 15 * 60 * 1000, // 15 minutes
  RATE_LIMIT_MAX: 100, // requests per window
  
  // WebSocket settings
  WS_HEARTBEAT_INTERVAL: 30000, // 30 seconds
  WS_MAX_CLIENTS: 1000,
  
  // Redis (optional - falls back to in-memory)
  REDIS_URL: process.env.REDIS_URL,
  USE_REDIS: process.env.USE_REDIS === "true",
};

// ═══════════════════════════════════════════════════════════════
// PROVIDER SETUP WITH FALLBACK & RETRY LOGIC
// ═══════════════════════════════════════════════════════════════

class ProviderManager {
  private providers: ethers.JsonRpcProvider[];
  private currentIndex: number = 0;
  private failureCount: Map<number, number> = new Map();
  
  constructor(urls: string[]) {
    this.providers = urls.map(url => new ethers.JsonRpcProvider(url));
    console.log(chalk.green(`✅ Initialized ${urls.length} RPC providers`));
  }
  
  getProvider(): ethers.JsonRpcProvider {
    // Return current provider
    return this.providers[this.currentIndex];
  }
  
  async executeWithFallback<T>(
    operation: (provider: ethers.JsonRpcProvider) => Promise<T>,
    maxRetries: number = 3
  ): Promise<T> {
    let lastError: Error | null = null;
    
    for (let attempt = 0; attempt < maxRetries; attempt++) {
      const provider = this.providers[this.currentIndex];
      
      try {
        const result = await operation(provider);
        
        // Reset failure count on success
        this.failureCount.set(this.currentIndex, 0);
        
        return result;
      } catch (error) {
        lastError = error as Error;
        
        // Increment failure count
        const failures = (this.failureCount.get(this.currentIndex) || 0) + 1;
        this.failureCount.set(this.currentIndex, failures);
        
        console.warn(chalk.yellow(
          `⚠️  Provider ${this.currentIndex} failed (attempt ${attempt + 1}/${maxRetries}): ${lastError.message}`
        ));
        
        // Switch to next provider
        this.currentIndex = (this.currentIndex + 1) % this.providers.length;
      }
    }
    
    throw new Error(`All providers failed after ${maxRetries} attempts: ${lastError?.message}`);
  }
  
  getStats() {
    return {
      totalProviders: this.providers.length,
      currentProvider: this.currentIndex,
      failures: Object.fromEntries(this.failureCount),
    };
  }
}

const providerManager = new ProviderManager(CONFIG.RPC_PROVIDERS);

// ═══════════════════════════════════════════════════════════════
// ADVANCED CACHING SYSTEM
// ═══════════════════════════════════════════════════════════════

class CacheManager {
  private memoryCache: NodeCache;
  private redisClient: Redis | null = null;
  private stats = {
    hits: 0,
    misses: 0,
    sets: 0,
  };
  
  constructor() {
    // Initialize in-memory cache
    this.memoryCache = new NodeCache({
      stdTTL: CONFIG.CACHE_TTL,
      checkperiod: CONFIG.CACHE_CHECK_PERIOD,
      useClones: false,
    });
    
    // Initialize Redis if configured
    if (CONFIG.USE_REDIS && CONFIG.REDIS_URL) {
      try {
        this.redisClient = new Redis(CONFIG.REDIS_URL);
        console.log(chalk.green("✅ Redis cache connected"));
      } catch (error) {
        console.warn(chalk.yellow("⚠️  Redis connection failed, using in-memory cache"));
      }
    }
  }
  
  async get<T>(key: string): Promise<T | null> {
    // Try memory cache first (fastest)
    const memoryValue = this.memoryCache.get<T>(key);
    if (memoryValue !== undefined) {
      this.stats.hits++;
      return memoryValue;
    }
    
    // Try Redis if available
    if (this.redisClient) {
      try {
        const redisValue = await this.redisClient.get(key);
        if (redisValue) {
          const parsed = JSON.parse(redisValue) as T;
          
          // Store in memory cache for faster access
          this.memoryCache.set(key, parsed);
          
          this.stats.hits++;
          return parsed;
        }
      } catch (error) {
        console.error(chalk.red("Redis get error:"), error);
      }
    }
    
    this.stats.misses++;
    return null;
  }
  
  async set<T>(key: string, value: T, ttl?: number): Promise<void> {
    // Set in memory cache
    this.memoryCache.set(key, value, ttl);
    
    // Set in Redis if available
    if (this.redisClient) {
      try {
        const serialized = JSON.stringify(value);
        if (ttl) {
          await this.redisClient.setex(key, ttl, serialized);
        } else {
          await this.redisClient.set(key, serialized);
        }
      } catch (error) {
        console.error(chalk.red("Redis set error:"), error);
      }
    }
    
    this.stats.sets++;
  }
  
  async invalidate(pattern: string): Promise<void> {
    // Clear memory cache
    const keys = this.memoryCache.keys();
    keys.forEach(key => {
      if (key.includes(pattern)) {
        this.memoryCache.del(key);
      }
    });
    
    // Clear Redis if available
    if (this.redisClient) {
      try {
        const keys = await this.redisClient.keys(`*${pattern}*`);
        if (keys.length > 0) {
          await this.redisClient.del(...keys);
        }
      } catch (error) {
        console.error(chalk.red("Redis invalidate error:"), error);
      }
    }
  }
  
  getStats() {
    const hitRate = this.stats.hits + this.stats.misses > 0
      ? ((this.stats.hits / (this.stats.hits + this.stats.misses)) * 100).toFixed(2)
      : "0.00";
    
    return {
      ...this.stats,
      hitRate: `${hitRate}%`,
      memoryKeys: this.memoryCache.keys().length,
    };
  }
  
  async close() {
    this.memoryCache.close();
    if (this.redisClient) {
      await this.redisClient.quit();
    }
  }
}

const cache = new CacheManager();

// ═══════════════════════════════════════════════════════════════
// MIDDLEWARE SETUP
// ═══════════════════════════════════════════════════════════════

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
    },
  },
}));

// CORS
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(",") || "*",
  methods: ["GET", "POST"],
  credentials: true,
}));

// Compression
app.use(compression());

// Body parsing
app.use(express.json({ limit: "10kb" }));
app.use(express.urlencoded({ extended: true, limit: "10kb" }));

// HTTP request logging
app.use(morgan("combined"));

// Custom request logging
app.use((req: Request, res: Response, next: NextFunction) => {
  const startTime = performance.now();
  
  res.on("finish", () => {
    const duration = (performance.now() - startTime).toFixed(2);
    const statusColor = res.statusCode >= 400 ? chalk.red : chalk.green;
    
    console.log(
      chalk.blue(`[${new Date().toISOString()}]`),
      chalk.cyan(req.method),
      req.url,
      statusColor(res.statusCode),
      chalk.gray(`${duration}ms`)
    );
  });
  
  next();
});

// Rate limiting with custom handler
const limiter = rateLimit({
  windowMs: CONFIG.RATE_LIMIT_WINDOW,
  max: CONFIG.RATE_LIMIT_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      error: "Too many requests",
      message: "Rate limit exceeded. Please try again later.",
      retryAfter: Math.ceil(CONFIG.RATE_LIMIT_WINDOW / 1000),
    });
  },
});

app.use(limiter);

// Request ID middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  req.id = Math.random().toString(36).substring(2, 15);
  res.setHeader("X-Request-ID", req.id);
  next();
});

// ═══════════════════════════════════════════════════════════════
// UTILITY FUNCTIONS
// ═══════════════════════════════════════════════════════════════

function isValidENSName(name: string): boolean {
  return /^[a-z0-9-]+\.eth$/.test(name.toLowerCase());
}

function isValidAddress(address: string): boolean {
  return ethers.isAddress(address);
}

function sanitizeInput(input: string): string {
  return input.trim().toLowerCase();
}

// ═══════════════════════════════════════════════════════════════
// ERROR HANDLER MIDDLEWARE
// ═══════════════════════════════════════════════════════════════

interface ApiError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

function createError(message: string, statusCode: number = 500): ApiError {
  const error: ApiError = new Error(message);
  error.statusCode = statusCode;
  error.isOperational = true;
  return error;
}

const errorHandler = (
  err: ApiError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const statusCode = err.statusCode || 500;
  const message = err.isOperational ? err.message : "Internal server error";
  
  console.error(chalk.red(`❌ Error [${req.id}]:`, err.message));
  console.error(chalk.gray(err.stack));
  
  res.status(statusCode).json({
    error: message,
    requestId: req.id,
    timestamp: new Date().toISOString(),
  });
};

// ═══════════════════════════════════════════════════════════════
// API ROUTES
// ═══════════════════════════════════════════════════════════════

// Health check
app.get("/health", async (req: Request, res: Response) => {
  try {
    const provider = providerManager.getProvider();
    const blockNumber = await provider.getBlockNumber();
    
    res.json({
      status: "healthy",
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      blockchain: {
        connected: true,
        blockNumber,
        network: await provider.getNetwork().then(n => n.name),
      },
      cache: cache.getStats(),
      provider: providerManager.getStats(),
    });
  } catch (error) {
    res.status(503).json({
      status: "unhealthy",
      error: (error as Error).message,
    });
  }
});

// Root endpoint
app.get("/", (req: Request, res: Response) => {
  res.json({
    name: "Warrior ENS API",
    version: "2.0.0",
    status: "online",
    endpoints: {
      resolve: "/resolve/:name",
      reverse: "/reverse/:address",
      avatar: "/avatar/:name",
      records: "/records/:name",
      batch: "/batch",
      search: "/search/:query",
      stats: "/stats",
      health: "/health",
    },
    websocket: {
      url: `ws://localhost:${CONFIG.WS_PORT}`,
      features: ["live-blocks", "ens-updates"],
    },
  });
});

// ENS name resolution
app.get("/resolve/:name", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const name = sanitizeInput(req.params.name);
    
    if (!isValidENSName(name)) {
      throw createError("Invalid ENS name format", 400);
    }
    
    const cacheKey = `resolve:${name}`;
    const cached = await cache.get<any>(cacheKey);
    
    if (cached) {
      return res.json({ ...cached, cached: true });
    }
    
    const address = await providerManager.executeWithFallback(
      (provider) => provider.resolveName(name)
    );
    
    if (!address) {
      throw createError("ENS name not found", 404);
    }
    
    const result = {
      name,
      address,
      timestamp: new Date().toISOString(),
    };
    
    await cache.set(cacheKey, result);
    
    res.json({ ...result, cached: false });
  } catch (error) {
    next(error);
  }
});

// Reverse ENS lookup
app.get("/reverse/:address", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const address = sanitizeInput(req.params.address);
    
    if (!isValidAddress(address)) {
      throw createError("Invalid Ethereum address", 400);
    }
    
    const cacheKey = `reverse:${address}`;
    const cached = await cache.get<any>(cacheKey);
    
    if (cached) {
      return res.json({ ...cached, cached: true });
    }
    
    const name = await providerManager.executeWithFallback(
      (provider) => provider.lookupAddress(address)
    );
    
    const result = {
      address,
      name: name || null,
      timestamp: new Date().toISOString(),
    };
    
    await cache.set(cacheKey, result);
    
    res.json({ ...result, cached: false });
  } catch (error) {
    next(error);
  }
});

// ENS avatar
app.get("/avatar/:name", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const name = sanitizeInput(req.params.name);
    
    if (!isValidENSName(name)) {
      throw createError("Invalid ENS name format", 400);
    }
    
    const cacheKey = `avatar:${name}`;
    const cached = await cache.get<any>(cacheKey);
    
    if (cached) {
      return res.json({ ...cached, cached: true });
    }
    
    const avatar = await providerManager.executeWithFallback(async (provider) => {
      const resolver = await provider.getResolver(name);
      return await resolver?.getAvatar();
    });
    
    const result = {
      name,
      avatar: avatar || null,
      timestamp: new Date().toISOString(),
    };
    
    await cache.set(cacheKey, result);
    
    res.json({ ...result, cached: false });
  } catch (error) {
    next(error);
  }
});

// ENS text records
app.get("/records/:name", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const name = sanitizeInput(req.params.name);
    
    if (!isValidENSName(name)) {
      throw createError("Invalid ENS name format", 400);
    }
    
    const cacheKey = `records:${name}`;
    const cached = await cache.get<any>(cacheKey);
    
    if (cached) {
      return res.json({ ...cached, cached: true });
    }
    
    const records = await providerManager.executeWithFallback(async (provider) => {
      const resolver = await provider.getResolver(name);
      
      if (!resolver) {
        throw createError("ENS resolver not found", 404);
      }
      
      const keys = [
        "email",
        "url",
        "avatar",
        "description",
        "com.twitter",
        "com.github",
        "com.discord",
        "com.telegram",
      ];
      
      const recordPromises = keys.map(async (key) => {
        try {
          const value = await resolver.getText(key);
          return [key, value || null];
        } catch {
          return [key, null];
        }
      });
      
      const recordEntries = await Promise.all(recordPromises);
      return Object.fromEntries(recordEntries);
    });
    
    const result = {
      name,
      records,
      timestamp: new Date().toISOString(),
    };
    
    await cache.set(cacheKey, result);
    
    res.json({ ...result, cached: false });
  } catch (error) {
    next(error);
  }
});

// Batch operations (NEW)
app.post("/batch", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { operations } = req.body;
    
    if (!Array.isArray(operations) || operations.length === 0) {
      throw createError("Invalid batch request format", 400);
    }
    
    if (operations.length > 10) {
      throw createError("Batch size limit exceeded (max 10)", 400);
    }
    
    const results = await Promise.allSettled(
      operations.map(async (op: any) => {
        if (op.type === "resolve") {
          const name = sanitizeInput(op.name);
          const cacheKey = `resolve:${name}`;
          const cached = await cache.get(cacheKey);
          
          if (cached) return cached;
          
          const address = await providerManager.executeWithFallback(
            (provider) => provider.resolveName(name)
          );
          
          const result = { name, address };
          await cache.set(cacheKey, result);
          return result;
        } else if (op.type === "reverse") {
          const address = sanitizeInput(op.address);
          const cacheKey = `reverse:${address}`;
          const cached = await cache.get(cacheKey);
          
          if (cached) return cached;
          
          const name = await providerManager.executeWithFallback(
            (provider) => provider.lookupAddress(address)
          );
          
          const result = { address, name };
          await cache.set(cacheKey, result);
          return result;
        }
        
        throw new Error("Invalid operation type");
      })
    );
    
    res.json({
      results: results.map((r, i) => ({
        index: i,
        status: r.status,
        data: r.status === "fulfilled" ? r.value : null,
        error: r.status === "rejected" ? r.reason.message : null,
      })),
    });
  } catch (error) {
    next(error);
  }
});

// Search ENS names (NEW)
app.get("/search/:query", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = sanitizeInput(req.params.query);
    
    if (query.length < 3) {
      throw createError("Query must be at least 3 characters", 400);
    }
    
    // This is a simplified search - in production, you'd use a proper indexing service
    const suggestions = [
      `${query}.eth`,
      `${query}-dao.eth`,
      `${query}-nft.eth`,
    ];
    
    const results = await Promise.allSettled(
      suggestions.map(async (name) => {
        try {
          const address = await providerManager.executeWithFallback(
            (provider) => provider.resolveName(name)
          );
          
          return address ? { name, address, available: false } : null;
        } catch {
          return null;
        }
      })
    );
    
    const available = results
      .filter((r) => r.status === "fulfilled" && r.value !== null)
      .map((r: any) => r.value);
    
    res.json({
      query,
      suggestions,
      found: available,
    });
  } catch (error) {
    next(error);
  }
});

// Statistics endpoint (NEW)
app.get("/stats", async (req: Request, res: Response) => {
  const memoryUsage = process.memoryUsage();
  
  res.json({
    uptime: process.uptime(),
    memory: {
      heapUsed: `${(memoryUsage.heapUsed / 1024 / 1024).toFixed(2)} MB`,
      heapTotal: `${(memoryUsage.heapTotal / 1024 / 1024).toFixed(2)} MB`,
      rss: `${(memoryUsage.rss / 1024 / 1024).toFixed(2)} MB`,
    },
    cache: cache.getStats(),
    provider: providerManager.getStats(),
    process: {
      pid: process.pid,
      nodeVersion: process.version,
      platform: process.platform,
    },
  });
});

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    error: "Not found",
    message: `Route ${req.method} ${req.path} not found`,
    requestId: req.id,
  });
});

// Error handler (must be last)
app.use(errorHandler);

// ═══════════════════════════════════════════════════════════════
// WEBSOCKET SERVER - LIVE ENS UPDATES
// ═══════════════════════════════════════════════════════════════

const wss = new WebSocketServer({ 
  port: CONFIG.WS_PORT,
  maxPayload: 100 * 1024, // 100KB max message size
});

const connectedClients = new Set<WebSocket>();

wss.on("connection", (ws: WebSocket) => {
  // Check client limit
  if (connectedClients.size >= CONFIG.WS_MAX_CLIENTS) {
    ws.close(1008, "Maximum clients reached");
    return;
  }
  
  connectedClients.add(ws);
  
  console.log(chalk.green(`✅ WebSocket client connected (${connectedClients.size} total)`));
  
  // Send welcome message
  ws.send(JSON.stringify({
    type: "welcome",
    message: "Connected to Warrior ENS WebSocket",
    features: ["live-blocks", "ens-updates"],
    timestamp: new Date().toISOString(),
  }));
  
  // Heartbeat
  let isAlive = true;
  
  ws.on("pong", () => {
    isAlive = true;
  });
  
  const heartbeatInterval = setInterval(() => {
    if (!isAlive) {
      clearInterval(heartbeatInterval);
      ws.terminate();
      return;
    }
    
    isAlive = false;
    ws.ping();
  }, CONFIG.WS_HEARTBEAT_INTERVAL);
  
  // Handle messages from client
  ws.on("message", (data: Buffer) => {
    try {
      const message = JSON.parse(data.toString());
      
      if (message.type === "subscribe") {
        // Handle subscription requests
        ws.send(JSON.stringify({
          type: "subscribed",
          channel: message.channel,
          timestamp: new Date().toISOString(),
        }));
      }
    } catch (error) {
      console.error(chalk.red("WebSocket message parse error:"), error);
    }
  });
  
  // Handle disconnection
  ws.on("close", () => {
    clearInterval(heartbeatInterval);
    connectedClients.delete(ws);
    console.log(chalk.yellow(`⚠️  WebSocket client disconnected (${connectedClients.size} remaining)`));
  });
  
  ws.on("error", (error) => {
    console.error(chalk.red("WebSocket error:"), error);
  });
});

// Broadcast new blocks to all clients
const provider = providerManager.getProvider();

provider.on("block", async (blockNumber: number) => {
  const message = JSON.stringify({
    type: "block",
    blockNumber,
    timestamp: new Date().toISOString(),
  });
  
  connectedClients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
});

console.log(chalk.green(`✅ WebSocket server running on port ${CONFIG.WS_PORT}`));

// ═══════════════════════════════════════════════════════════════
// SERVER STARTUP
// ═══════════════════════════════════════════════════════════════

const server = app.listen(CONFIG.PORT, () => {
  console.log("\n" + chalk.cyan("═".repeat(70)));
  console.log(chalk.cyan.bold("           🛡️  WARRIOR ENS API - DIGITAL WARRIOR EDITION  🛡️"));
  console.log(chalk.cyan("═".repeat(70)));
  console.log("");
  console.log(chalk.green("✅ HTTP server running on:"), chalk.yellow(`http://localhost:${CONFIG.PORT}`));
  console.log(chalk.green("✅ WebSocket server on:"), chalk.yellow(`ws://localhost:${CONFIG.WS_PORT}`));
  console.log(chalk.green("✅ Environment:"), chalk.yellow(process.env.NODE_ENV || "development"));
  console.log(chalk.green("✅ Cache backend:"), chalk.yellow(CONFIG.USE_REDIS ? "Redis" : "In-Memory"));
  console.log(chalk.green("✅ RPC providers:"), chalk.yellow(CONFIG.RPC_PROVIDERS.length));
  console.log("");
  console.log(chalk.cyan("📖 API Documentation:"), chalk.blue("http://localhost:" + CONFIG.PORT));
  console.log(chalk.cyan("💚 Health Check:"), chalk.blue("http://localhost:" + CONFIG.PORT + "/health"));
  console.log(chalk.cyan("📊 Statistics:"), chalk.blue("http://localhost:" + CONFIG.PORT + "/stats"));
  console.log("");
  console.log(chalk.cyan("═".repeat(70)));
  console.log("");
});

// ═══════════════════════════════════════════════════════════════
// GRACEFUL SHUTDOWN
// ═══════════════════════════════════════════════════════════════

const gracefulShutdown = async (signal: string) => {
  console.log(chalk.yellow(`\n⚠️  Received ${signal}, starting graceful shutdown...`));
  
  // Stop accepting new connections
  server.close(() => {
    console.log(chalk.green("✅ HTTP server closed"));
  });
  
  // Close WebSocket server
  wss.close(() => {
    console.log(chalk.green("✅ WebSocket server closed"));
  });
  
  // Close cache connections
  await cache.close();
  console.log(chalk.green("✅ Cache connections closed"));
  
  // Give time for cleanup
  setTimeout(() => {
    console.log(chalk.green("✅ Graceful shutdown complete"));
    process.exit(0);
  }, 5000);
};

process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));

// Unhandled errors
process.on("unhandledRejection", (reason, promise) => {
  console.error(chalk.red("❌ Unhandled Rejection at:"), promise);
  console.error(chalk.red("Reason:"), reason);
});

process.on("uncaughtException", (error) => {
  console.error(chalk.red("❌ Uncaught Exception:"), error);
  gracefulShutdown("uncaughtException");
});

// Export for testing
export { app, wss, cache, providerManager };

