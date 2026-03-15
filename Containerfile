FROM registry.alpinelinux.org/img/alpine
ARG VERSION="local-oci"

COPY caddy-${TARGETARCH} /usr/bin/caddy

LABEL org.opencontainers.image.title="xtex's Home"
LABEL org.opencontainers.image.description="xtex's Home Directory"
LABEL org.opencontainers.image.url=https://xtexx.eu.org
LABEL org.opencontainers.image.vendor=xtex
LABEL org.opencontainers.image.licenses=MPL-2.0
LABEL org.opencontainers.image.source="https://codeberg.org/xtex/home"

COPY Caddyfile /etc/caddy/Caddyfile
COPY src /srv/src
RUN apk add --no-cache bash
RUN set -euxo pipefail; \
	printf "${VERSION}" > /srv/src/version.txt; \
	mkdir /srv/run;

ENV PROD true
WORKDIR /srv
ENV UDS_DIR_ADMIN run
ENV UDS_DIR run
ENV BLOG_DIR blog
ENTRYPOINT ["/usr/bin/caddy", "run", "-c", "/etc/caddy/Caddyfile"]
