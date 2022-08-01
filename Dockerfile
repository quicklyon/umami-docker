FROM node:16-alpine AS builder

ENV OS_ARCH="amd64" \
    OS_NAME="alpine-3.15"

COPY alpine/prebuildfs /

ARG VERSION
ARG IS_CHINA="true"
ENV MIRROR=${IS_CHINA}

RUN install_packages libc6-compat curl tar mysql-client

WORKDIR /apps

ENV DATABASE_URL=mysql://username:mypassword@localhost:3306/mydb

RUN mkdir tmp \
    && curl -sL https://github.com/umami-software/umami/archive/refs/tags/v${VERSION}.tar.gz | tar xvz -C tmp \
    && mv tmp/umami-${VERSION} umami

RUN cd /apps/umami \
    && rm -rf yarn.lock \
    && yarn install --verbose --network-concurrency 20 --registry https://registry.npmmirror.com \
    && yarn --verbose build

# Production image, copy all the files and run next
FROM node:16-alpine AS runner
COPY alpine/prebuildfs /
WORKDIR /apps/umami

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

RUN yarn global add prisma --registry https://registry.npmmirror.com --verbose
RUN yarn add prompts npm-run-all dotenv --registry https://registry.npmmirror.com --verbose

ENV OS_ARCH="amd64" \
    OS_NAME="alpine-3.15"
RUN install_packages mysql-client

# You only need to copy next.config.js if you are NOT using the default configuration
COPY --from=builder /apps/umami/next.config.js .
COPY --from=builder /apps/umami/public ./public
COPY --from=builder /apps/umami/package.json ./package.json
COPY --from=builder /apps/umami/prisma ./prisma
COPY --from=builder /apps/umami/scripts ./scripts

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /apps/umami/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /apps/umami/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["yarn", "start-docker"]



#ENTRYPOINT ["/usr/bin/entrypoint.sh"]
