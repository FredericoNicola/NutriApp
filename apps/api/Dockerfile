FROM node:20-alpine

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /usr/src/app

# Copy workspace manifests first (speeds rebuilds)
COPY package.json pnpm-workspace.yaml ./
COPY apps/api/package.json apps/api/package.json
COPY packages/db/package.json packages/db/package.json
# copy lockfile
COPY pnpm-lock.yaml ./

# Install deps
RUN pnpm install --frozen-lockfile

# Copy full workspace source
COPY . .

# Build API (if you use tsc)
RUN pnpm --filter=@appplaceholder/api build

EXPOSE 3333

ENV NODE_ENV=production
# Ensure container knows the DB host 'db' from compose
CMD ["pnpm", "--filter=@appplaceholder/api", "start"]