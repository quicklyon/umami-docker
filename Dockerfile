# Install dependencies only when needed
FROM node:16-alpine AS deps

ENV OS_ARCH="amd64" \
    OS_NAME="alpine-3.15"

COPY alpine/prebuildfs /

ARG VERSION
ARG IS_CHINA="true"
ENV MIRROR=${IS_CHINA}

# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN install_packages libc6-compat git

WORKDIR /app
RUN git clone --branch v${VERSION} https://github.com/umami-software/umami.git /app
#COPY package.json yarn.lock ./
RUN set_npm_registry && yarn install --frozen-lockfile

# Rebuild the source code only when needed
FROM node:16-alpine AS builder
COPY alpine/prebuildfs /
WORKDIR /app
#COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app .
#COPY . .

ARG MYSQL_HOST
ARG MYSQL_PORT
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG DATABASE_TYPE
#ARG DATABASE_URL
ARG BASE_PATH
ARG DISABLE_LOGIN

ENV DATABASE_TYPE $DATABASE_TYPE
ENV DATABASE_URL ${DATABASE_TYPE}://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}
ENV BASE_PATH $BASE_PATH
ENV DISABLE_LOGIN $DISABLE_LOGIN

ENV NEXT_TELEMETRY_DISABLED 1

RUN set_npm_registry && yarn build

# Production image, copy all the files and run next
FROM node:16-alpine AS runner
COPY alpine/prebuildfs /
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

RUN set_npm_registry
RUN yarn global add prisma
RUN yarn add npm-run-all dotenv

# You only need to copy next.config.js if you are NOT using the default configuration
COPY --from=builder /app/next.config.js .
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/scripts ./scripts

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["yarn", "start-docker"]
