FROM node:18-alpine AS base

FROM base AS builder
RUN apk add --no-cache libc6-compat curl
RUN apk update

# Set working directory
WORKDIR /app
COPY . .

# First install the dependencies (as they change less often)
RUN npm ci
RUN npm run build

FROM base AS runner
WORKDIR /app

# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 sveltejs
USER sveltejs

COPY --from=builder /app/package.json .
COPY --from=builder --chown=sveltejs:nodejs /app/build ./
COPY --from=builder /app/node_modules ./node_modules

CMD node index.js
