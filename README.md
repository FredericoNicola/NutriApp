# App placeholder scaffold

Monorepo scaffold for a Nutrium-like app (solo dev + nutritionist).

Structure:
- apps/web - Next.js (App Router) frontend
- apps/api - NestJS backend + Prisma
- packages/db - Prisma schema / migrations
- packages/config - shared TS types
- packages/ui - shared React components

Quick start:
1. Install pnpm v8+, Node 20+, and optionally the GitHub CLI (gh).
2. At repo root:
   pnpm install
3. Bootstrap (generates Prisma client):
   pnpm -w -r run prisma:generate
4. Dev (starts web and api concurrently):
   pnpm dev

CI:
- GitHub Actions workflow is provided at .github/workflows/ci.yml and runs lint, type-check, tests, and builds.

.env files:
- Examples are included as .env.example in apps and packages. Fill secrets in a local .env (do not commit).

Notes:
- This scaffold is intentionally minimal to get started quickly. Add auth, payments, and production infra separately.
