# Install dependencies only when needed
FROM node:16-alpine AS deps

ENV OS_ARCH="amd64" \
    OS_NAME="alpine-3.15"

COPY alpine/prebuildfs /

ARG VERSION
ARG IS_CHINA="true"
ENV MIRROR=${IS_CHINA}

# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN install_packages libc6-compat curl tar

WORKDIR /app

RUN mkdir tmp \
    && curl -sL https://github.com/umami-software/umami/archive/refs/tags/v${VERSION}.tar.gz | tar xvz -C tmp \
    && mv tmp/umami-${VERSION}/* . \
    && rm tmp -rf

#RUN git clone --branch v${VERSION} https://github.com/umami-software/umami.git /app
#COPY package.json yarn.lock ./
RUN yarn config set registry https://registry.npmmirror.com  && yarn install --verbose

# Rebuild the source code only when needed
FROM node:16-alpine AS builder
COPY alpine/prebuildfs /
WORKDIR /app
#COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app .
#COPY . .

ARG MYSQL_HOST=localhost
ARG MYSQL_PORT=3306
ARG MYSQL_DB=umami
ARG MYSQL_USER=root
ARG MYSQL_PASSWORD=pass4Umami
ARG DATABASE_TYPE=mysql
ARG DATABASE_URL=${DATABASE_TYPE}://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DB}
ARG BASE_PATH
ARG DISABLE_LOGIN

ENV DATABASE_TYPE $DATABASE_TYPE
ENV DATABASE_URL $DATABASE_URL
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

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
