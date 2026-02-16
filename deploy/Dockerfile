# syntax=docker/dockerfile:1.5
FROM node:20-bookworm AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

FROM node:20-bookworm AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ARG BUILD_TIMESTAMP="unknown"
ENV BUILD_TIMESTAMP=$BUILD_TIMESTAMP
ENV DATABASE_URL=postgresql://postgres:postgres@localhost:5432/scheduler
RUN npm run prisma:generate
RUN mkdir -p /app/.next/cache
RUN --mount=type=cache,target=/app/.next/cache npm run build

FROM node:20-bookworm AS runner
WORKDIR /app
ENV NODE_ENV=production
ARG BUILD_TIMESTAMP="unknown"
ENV BUILD_TIMESTAMP=$BUILD_TIMESTAMP
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/next.config.ts ./next.config.ts
COPY --from=builder /app/prisma ./prisma
EXPOSE 3000
CMD ["npm", "start"]
