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
    && curl -sL https://github.com/umami-software/umami/archive/refs/tags/v${VERSION}.tar.gz | tar xvz -C /apps/tmp \
    && mv /apps/tmp/umami-${VERSION} /apps/umami

RUN cd /apps/umami \
    && rm -rf yarn.lock \
    && docker_yarn install --verbose \
    && docker_yarn add next --verbose

ENV NEXT_TELEMETRY_DISABLED 1
RUN cd /apps/umami && yarn --verbose build

# Production image, copy all the files and run next
FROM node:16-alpine AS runner
COPY alpine/prebuildfs /
WORKDIR /apps/umami

ARG IS_CHINA="true"
ENV MIRROR=${IS_CHINA}

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
ENV APP_VERSION=${VERSION}
ENV EASYSOFT_APP_NAME="Umami $APP_VERSION"

RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs

RUN docker_yarn global add prisma \
    && docker_yarn add prompts npm-run-all dotenv \
    && rm -rf /usr/local/share/.cache/yarn

ENV OS_ARCH="amd64" \
    OS_NAME="alpine-3.15"
RUN install_packages netcat-openbsd mysql-client bash s6 && rm /bin/sh && ln -s /bin/bash /bin/sh

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
COPY alpine/rootfs /

USER nextjs

EXPOSE 3000

ENV PORT 3000

USER root

CMD ["/bin/sh", "/usr/bin/entrypoint.sh"]
