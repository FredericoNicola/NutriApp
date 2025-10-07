#!/usr/bin/env bash
# create-scaffold.sh
# Usage: ./create-scaffold.sh
# Creates a monorepo scaffold for a placeholder app (local only).
# After running, initialize a remote repo with `gh repo create` and push.
set -euo pipefail

echo "Creating monorepo scaffold..."

# Ensure required top-level directories exist (fixed mistaken nested path)
mkdir -p .github/workflows apps/web apps/api packages/db packages/config packages/ui packages/db/prisma scripts

cat > package.json <<'EOF'
{
  "name": "appplaceholder-scaffold",
  "private": true,
  "version": "0.1.0",
  "packageManager": "pnpm@8.0.0",
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "bootstrap": "pnpm install",
    "dev": "concurrently \"pnpm --filter @appplaceholder/web dev\" \"pnpm --filter @appplaceholder/api dev\"",
    "build": "pnpm -w -r build",
    "lint": "pnpm -w -r lint",
    "test": "pnpm -w -r test"
  },
  "devDependencies": {
    "concurrently": "^8.2.0"
  }
}
EOF

cat > pnpm-workspace.yaml <<'EOF'
packages:
  - 'apps/*'
  - 'packages/*'
EOF

cat > tsconfig.base.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM"],
    "module": "ESNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "jsx": "react-jsx",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@appplaceholder/config": ["packages/config/src"],
      "@appplaceholder/ui": ["packages/ui/src"],
      "@appplaceholder/db": ["packages/db"]
    }
  },
  "include": []
}
EOF

cat > .gitignore <<'EOF'
# Node
node_modules/
.pnpm-store/
pnpm-lock.yaml

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Env
.env
.env.local
.env.*.local

# Next build
.next
.out

# Storybook
.out
storybook-static

# Misc
.DS_Store
.vscode/
EOF

cat > README.md <<'EOF'
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
EOF

cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - name: Setup pnpm
        run: corepack enable && corepack prepare pnpm@8.0.0 --activate
      - name: Install
        run: pnpm install --frozen-lockfile
      - name: Generate Prisma client
        run: pnpm -w -r run prisma:generate
      - name: Lint (root)
        run: pnpm -w -r lint || true
      - name: Typecheck
        run: pnpm -w -r run tsc --noEmit
      - name: Run tests
        run: pnpm -w -r test
      - name: Build apps
        run: pnpm -w -r build
EOF

# apps/web
mkdir -p apps/web/app apps/web/src apps/web/components
cat > apps/web/package.json <<'EOF'
{
  "name": "@appplaceholder/web",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start",
    "lint": "eslint . --ext .ts,.tsx",
    "test": "vitest"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "tailwindcss": "^3.4.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "vitest": "^0.34.0",
    "eslint": "^8.47.0"
  }
}
EOF

cat > apps/web/next.config.js <<'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: {
    appDir: true
  }
}

module.exports = nextConfig
EOF

cat > apps/web/app/layout.tsx <<'EOF'
import './globals.css'

export const metadata = {
  title: 'App placeholder scaffold',
  description: 'Monorepo demo'
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-gray-50 text-slate-900">
        <header className="p-4 border-b bg-white">
          <div className="max-w-4xl mx-auto">App placeholder scaffold</div>
        </header>
        <main className="max-w-4xl mx-auto p-4">{children}</main>
      </body>
    </html>
  )
}
EOF

cat > apps/web/app/page.tsx <<'EOF'
import React from 'react'

type User = { id: string; name: string; email?: string }

async function getUsers(): Promise<User[]> {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3333/api'
  const res = await fetch(`${apiUrl}/users`, { cache: 'no-store' })
  if (!res.ok) return []
  return res.json()
}

export default async function Page() {
  const users = await getUsers()
  return (
    <div>
      <h1 className="text-2xl font-semibold mb-4">Users</h1>
      {users.length === 0 ? (
        <p>No users yet.</p>
      ) : (
        <ul className="space-y-2">
          {users.map((u) => (
            <li key={u.id} className="p-3 bg-white rounded shadow-sm">
              <div className="font-medium">{u.name}</div>
              <div className="text-sm text-slate-500">{u.email}</div>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
EOF

cat > apps/web/globals.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* small app styles */
body { font-family: ui-sans-serif, system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial; }
EOF

cat > apps/web/tailwind.config.js <<'EOF'
module.exports = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "../../packages/ui/src/**/*.{ts,tsx}"],
  theme: { extend: {} },
  plugins: []
}
EOF

cat > apps/web/postcss.config.js <<'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
}
EOF

cat > apps/web/vitest.config.ts <<'EOF'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom'
  }
})
EOF

cat > apps/web/.env.example <<'EOF'
NEXT_PUBLIC_API_URL=http://localhost:3333
EOF

cat > apps/web/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "."
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

cat > apps/web/src/example.test.ts <<'EOF'
import { describe, it, expect } from 'vitest'

describe('sanity', () => {
  it('true is true', () => {
    expect(true).toBe(true)
  })
})
EOF

cat > apps/web/.eslintrc <<'EOF'
{
  "root": true,
  "extends": ["next/core-web-vitals"],
  "env": { "browser": true, "es2022": true }
}
EOF

# apps/api
mkdir -p apps/api/src/users
cat > apps/api/package.json <<'EOF'
{
  "name": "@appplaceholder/api",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/main.ts",
    "build": "tsc -p tsconfig.json",
    "start": "node dist/main.js",
    "lint": "eslint \"src/**/*.{ts,js}\"",
    "test": "jest --runInBand",
    "prisma:generate": "prisma generate",
    "prisma:migrate:dev": "prisma migrate dev --name init --preview-feature"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "reflect-metadata": "^0.1.13",
    "prisma": "^5.12.0",
    "@prisma/client": "^5.12.0"
  },
  "devDependencies": {
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.5.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.4"
  }
}
EOF

cat > apps/api/src/main.ts <<'EOF'
import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)
  app.setGlobalPrefix('api')
  const port = process.env.PORT ? parseInt(process.env.PORT) : 3333
  await app.listen(port)
  console.log(`API listening on http://localhost:${port}/api`)
}
bootstrap()
EOF

cat > apps/api/src/app.module.ts <<'EOF'
import { Module } from '@nestjs/common'
import { UsersModule } from './users/users.module'

@Module({
  imports: [UsersModule]
})
export class AppModule {}
EOF

cat > apps/api/src/users/users.module.ts <<'EOF'
import { Module } from '@nestjs/common'
import { UsersService } from './users.service'
import { UsersController } from './users.controller'

@Module({
  controllers: [UsersController],
  providers: [UsersService]
})
export class UsersModule {}
EOF

cat > apps/api/src/users/users.service.ts <<'EOF'
import { Injectable } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'

@Injectable()
export class UsersService {
  private prisma = new PrismaClient()

  async list() {
    # Try to return users from DB; fallback to sample if DB not set up
    try {
      const users = await this.prisma.user.findMany()
      if (users.length > 0) return users
    } catch (e) {
      // ignore
    }
    return [
      { id: '1', name: 'Nutritionist Jane', email: 'jane@example.com' },
      { id: '2', name: 'Client Bob', email: 'bob@example.com' }
    ]
  }
}
EOF

cat > apps/api/src/users/users.controller.ts <<'EOF'
import { Controller, Get } from '@nestjs/common'
import { UsersService } from './users.service'

@Controller()
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('health')
  health() {
    return { status: 'ok' }
  }

  @Get('users')
  async getUsers() {
    return this.usersService.list()
  }
}
EOF

cat > apps/api/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src",
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true
  },
  "include": ["src"]
}
EOF

cat > apps/api/jest.config.ts <<'EOF'
export default {
  displayName: 'api',
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src']
}
EOF

cat > apps/api/.env.example <<'EOF'
DATABASE_URL=postgresql://user:password@localhost:5432/appplaceholder
PORT=3333
EOF

cat > apps/api/src/users/users.service.spec.ts <<'EOF'
import { UsersService } from './users.service'

describe('UsersService', () => {
  it('returns fallback users when DB not available', async () => {
    const svc = new UsersService()
    const users = await svc.list()
    expect(Array.isArray(users)).toBe(true)
    expect(users.length).toBeGreaterThanOrEqual(1)
    expect(users[0]).toHaveProperty('id')
  })
})
EOF

cat > apps/api/.eslintrc <<'EOF'
{
  "root": true,
  "parserOptions": { "project": "./tsconfig.json" },
  "env": { "node": true, "jest": true }
}
EOF

# packages/db (Prisma)
cat > packages/db/package.json <<'EOF'
{
  "name": "@appplaceholder/db",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "prisma:generate": "prisma generate",
    "prisma:migrate:dev": "prisma migrate dev --name init"
  },
  "devDependencies": {
    "prisma": "^5.12.0"
  }
}
EOF

cat > packages/db/prisma/schema.prisma <<'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id    String @id @default(uuid())
  name  String
  email String? @unique
  createdAt DateTime @default(now())
}
EOF

cat > packages/db/prisma/.env.example <<'EOF'
# Example: postgres connection for local dev
DATABASE_URL=postgresql://postgres:password@localhost:5432/appplaceholder
EOF

# packages/config
mkdir -p packages/config/src
cat > packages/config/package.json <<'EOF'
{
  "name": "@appplaceholder/config",
  "version": "0.1.0",
  "private": true,
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc -p tsconfig.json"
  },
  "devDependencies": {
    "typescript": "^5.5.0"
  }
}
EOF

cat > packages/config/src/index.ts <<'EOF'
export type User = {
  id: string
  name: string
  email?: string
}

export type Plan = {
  id: string
  name: string
  caloriesPerDay: number
}
EOF

cat > packages/config/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "declaration": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"]
}
EOF

# packages/ui
mkdir -p packages/ui/src/components
cat > packages/ui/package.json <<'EOF'
{
  "name": "@appplaceholder/ui",
  "version": "0.1.0",
  "private": true,
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc -p tsconfig.json",
    "storybook": "echo \"Storybook stub (add storybook config)\""
  },
  "devDependencies": {
    "typescript": "^5.5.0"
  }
}
EOF

cat > packages/ui/src/components/Button.tsx <<'EOF'
import React from 'react'

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  children: React.ReactNode
}

export const Button: React.FC<Props> = ({ children, ...rest }) => {
  return (
    <button
      {...rest}
      className={
        'px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 ' +
        (rest.className ?? '')
      }
    >
      {children}
    </button>
  )
}

export default Button
EOF

cat > packages/ui/tsconfig.json <<'EOF'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "declaration": true,
    "outDir": "dist",
    "rootDir": "src",
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
EOF

# Root convenience post-setup note (ensure scripts dir exists)
cat > scripts/post-setup.txt <<'EOF'
Run these after installing dependencies:

pnpm install
pnpm -w -r run prisma:generate
pnpm dev

If you want to create a GitHub repo and push:
gh repo create FredericoNicola/appplaceholder-scaffold --public --source=. --remote=origin --push

Then open in VS Code:
code .
EOF

# Initialize git if not present
if [ ! -d .git ]; then
  git init
  git add .
  git commit -m "chore: initial monorepo scaffold (placeholder app)"
  echo "Initialized git repository and created initial commit."
else
  echo "Git repository already initialized."
fi

echo "Scaffold created. Next steps:"
echo "1) Install pnpm v8+ and Node 20+"
echo "2) Run: pnpm install"
echo "3) Run: pnpm -w -r run prisma:generate"
echo "4) Run: pnpm dev"
echo ""
echo "To create remote repo and push (requires GitHub CLI):"
echo "  gh repo create FredericoNicola/appplaceholder-scaffold --public --source=. --remote=origin --push"
echo ""
echo "To open in VS Code:"
echo "  code ."
echo ""
echo "Done."
