# Deploy Command

**Purpose**: Deploy generated application to production

**Trigger**: User says "deploy", "publish", or "go live"

---

## What This Command Does

Automated deployment of the generated fullstack application:
- Validates production readiness
- Configures deployment platforms
- Deploys frontend to Vercel
- Deploys backend to Railway/Render
- Sets up database and environment variables
- Runs smoke tests on production

---

## Usage

```
/deploy

# Deploy to specific platforms
/deploy --frontend vercel --backend railway

# Deploy with custom domain
/deploy --domain myapp.com

# Dry run (check without deploying)
/deploy --dry-run

# Deploy specific component only
/deploy frontend
/deploy backend
```

---

## Pre-Deployment Checks

```
🔍 Pre-deployment validation...

✓ Build Tests
  ✓ Frontend builds successfully
  ✓ Backend builds successfully
  ✓ No TypeScript errors
  ✓ No linting errors

✓ Functionality Tests
  ✓ All unit tests passing (87/87)
  ✓ Integration tests passing (23/23)
  ✓ API endpoints responding

✓ Security Checks
  ✓ No exposed secrets
  ✓ Environment variables configured
  ✓ HTTPS enforced
  ✓ CORS configured

✓ Performance
  ✓ Lighthouse score: 94/100
  ✓ Bundle size: 245 KB (within limit)
  ✓ API response time: avg 145ms

✓ Documentation
  ✓ README.md exists
  ✓ API documentation exists
  ✓ Environment variables documented

✅ Ready for deployment!
```

---

## Deployment Flow

### Phase 1: Platform Selection

```
🎯 Deployment Platform Selection

Frontend Options:
  1. Vercel (Recommended for Next.js)
  2. Netlify
  3. AWS Amplify
  4. Cloudflare Pages

Backend Options:
  1. Railway (Recommended)
  2. Render
  3. Fly.io
  4. AWS ECS

Database:
  1. Railway PostgreSQL (Recommended)
  2. Supabase
  3. PlanetScale
  4. AWS RDS

Select platforms: [1,1,1] (default)
```

### Phase 2: Configuration

```
⚙️ Deployment Configuration

📝 Creating deployment configs...
  ✓ vercel.json (frontend)
  ✓ railway.toml (backend)
  ✓ Dockerfile (backend)
  ✓ .env.production (template)

🔐 Environment Variables Required:

Frontend (.env.production):
  ✓ NEXT_PUBLIC_API_URL (auto-configured)
  ⚠ NEXT_PUBLIC_ANALYTICS_ID (enter value or skip)

Backend (.env.production):
  ⚠ DATABASE_URL (will be auto-configured by Railway)
  ⚠ JWT_SECRET (generate random or enter)
  ⚠ OPENAI_API_KEY (enter value)

Enter missing values now or configure later? [now/later]
```

### Phase 3: Deployment Execution

```
🚀 Deploying to Production...

[Frontend → Vercel]
  ⚙ Connecting to Vercel...
  ✓ Authenticated as user@example.com
  ⚙ Creating project 'my-service-name'...
  ✓ Project created
  ⚙ Deploying...
    - Installing dependencies... (25s)
    - Building Next.js app... (48s)
    - Optimizing images... (12s)
    - Uploading to CDN... (8s)
  ✓ Deployed successfully!
  🌐 URL: https://my-service-name.vercel.app

[Backend → Railway]
  ⚙ Connecting to Railway...
  ✓ Authenticated
  ⚙ Creating project 'my-service-name-api'...
  ✓ Project created
  ⚙ Provisioning PostgreSQL database...
  ✓ Database created (connection string set)
  ⚙ Deploying FastAPI app...
    - Building Docker image... (35s)
    - Starting container... (8s)
    - Running migrations... (3s)
    - Health check... ✓
  ✓ Deployed successfully!
  🌐 URL: https://my-service-name-api.railway.app

[Database → Railway]
  ⚙ Running migrations...
  ✓ Created 8 tables
  ✓ Seed data inserted (if applicable)
  ✓ Database ready

⏱ Total deployment time: 2m 34s
```

### Phase 4: Post-Deployment Validation

```
✅ Post-Deployment Checks

🌐 Frontend Health
  ✓ https://my-service-name.vercel.app - 200 OK
  ✓ Home page loads (534ms)
  ✓ Static assets loading
  ✓ API connection successful

🔌 Backend Health
  ✓ https://my-service-name-api.railway.app/health - 200 OK
  ✓ Database connected
  ✓ All endpoints responding

🔒 Security
  ✓ HTTPS enabled
  ✓ CORS configured correctly
  ✓ Rate limiting active

📊 Performance
  ✓ Lighthouse score: 94/100
  ✓ API latency: avg 156ms
  ✓ Database query time: avg 12ms

✅ Deployment successful!
```

---

## Implementation Logic

```javascript
async function deployApplication(args) {
  // 1. Pre-deployment validation
  const checks = await runPreDeploymentChecks();
  if (!checks.passed) {
    return handleFailedChecks(checks.errors);
  }

  // 2. Platform selection
  const platforms = args.platforms || await selectPlatforms();

  // 3. Configuration
  await generateDeploymentConfigs(platforms);
  await setupEnvironmentVariables(platforms);

  // 4. Deploy components
  const results = {
    frontend: await deployFrontend(platforms.frontend),
    backend: await deployBackend(platforms.backend),
    database: await setupDatabase(platforms.database)
  };

  // 5. Post-deployment validation
  await runPostDeploymentChecks(results);

  // 6. Generate deployment report
  return generateDeploymentReport(results);
}
```

---

## Supported Platforms

### Frontend
| Platform | Auto-Setup | Custom Domain | SSL | CDN |
|----------|-----------|---------------|-----|-----|
| Vercel | ✓ | ✓ | ✓ | ✓ |
| Netlify | ✓ | ✓ | ✓ | ✓ |
| AWS Amplify | ✓ | ✓ | ✓ | ✓ |
| Cloudflare | ✓ | ✓ | ✓ | ✓ |

### Backend
| Platform | Auto-Setup | Database | Docker | Auto-Scale |
|----------|-----------|----------|--------|------------|
| Railway | ✓ | ✓ | ✓ | ✓ |
| Render | ✓ | ✓ | ✓ | ✓ |
| Fly.io | ✓ | ✗ | ✓ | ✓ |
| AWS ECS | ✗ | ✗ | ✓ | ✓ |

---

## Generated Deployment Files

```
my-service-name/
├── vercel.json              # Vercel config
├── netlify.toml             # Netlify config (if selected)
├── railway.toml             # Railway config
├── Dockerfile               # Backend container
├── docker-compose.yml       # Local testing
├── .env.production.example  # Environment template
└── docs/
    └── deployment.md        # Deployment guide
```

---

## Environment Variable Management

### Auto-Configured
- `DATABASE_URL` - Set by platform
- `API_URL` / `NEXT_PUBLIC_API_URL` - Generated from deployment
- `NODE_ENV=production`

### User-Provided (prompted during deploy)
- `JWT_SECRET` - Auth secret (can auto-generate)
- Third-party API keys (OpenAI, Stripe, etc.)
- Custom configuration values

### Secure Handling
- Never commits `.env.production` to git
- Uses platform-native secret management
- Provides `.env.production.example` template

---

## Rollback Support

```
/deploy --rollback

🔄 Available Rollback Points:

1. v1.2.3 (current) - 5 minutes ago
2. v1.2.2 - 2 hours ago  ← Suggested
3. v1.2.1 - 1 day ago
4. v1.2.0 - 3 days ago

Select version to rollback to: [2]

⚙️ Rolling back to v1.2.2...
✓ Frontend rolled back
✓ Backend rolled back
✓ Database migrations reverted (if needed)
✅ Rollback complete
```

---

## Custom Domain Setup

```
/deploy --domain myapp.com

🌐 Custom Domain Setup

Frontend: myapp.com
Backend: api.myapp.com

📋 DNS Configuration Required:

Add these records to your DNS provider:

Type  | Name  | Value
------|-------|-------
A     | @     | 76.76.21.21
CNAME | www   | cname.vercel-dns.com
CNAME | api   | my-service.railway.app

✓ SSL certificates will be auto-provisioned (Let's Encrypt)
✓ HTTPS redirect enabled

Waiting for DNS propagation... (this may take up to 48 hours)
```

---

## Cost Estimation

```
💰 Estimated Monthly Costs

Vercel (Frontend):
  - Free tier: 100GB bandwidth
  - Estimated: $0/month (within free tier)

Railway (Backend + Database):
  - 500MB RAM, PostgreSQL 1GB
  - Estimated: $5-10/month

Total: ~$5-10/month for moderate traffic

Note: Costs may vary based on usage.
View detailed pricing: /deploy --pricing
```

---

## Integration with Pipeline

Deploy command requires completion phase to pass:

```
Prerequisites:
  ✓ /completion verified all deliverables
  ✓ All tests passing
  ✓ No critical errors
  ✓ Documentation complete

If prerequisites not met:
  → Run /autopilot to complete pipeline first
  → Or use /deploy --force (not recommended)
```

---

## Dry Run Mode

```
/deploy --dry-run

🔍 Deployment Simulation (no actual deployment)

✓ Would create Vercel project
✓ Would build frontend (estimated 45s)
✓ Would deploy to https://my-service-name.vercel.app
✓ Would create Railway project
✓ Would build Docker image (estimated 35s)
✓ Would provision PostgreSQL database
✓ Would deploy backend to https://my-service-name-api.railway.app

💰 Estimated cost: $5-10/month
⏱ Estimated deployment time: 2-3 minutes

Ready to deploy for real? Run: /deploy
```

---

## Behavior Rules

1. **Safe**: Validate before deploying
2. **Transparent**: Show all steps and costs
3. **Reversible**: Support rollback
4. **Documented**: Generate deployment guide
5. **Secure**: Prompt for secrets, never log them

---

## Examples

```
User: "deploy"
→ Full deployment with guided setup

User: "deploy --dry-run"
→ Simulate deployment, show what would happen

User: "deploy frontend"
→ Deploy only frontend component

User: "deploy --domain myapp.com"
→ Deploy with custom domain

User: "deploy --rollback"
→ Rollback to previous version
```
