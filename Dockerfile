# Ray Chad — IRC server (InspIRCd)
# Build:  docker build -t raychd .
# Run:    docker run -d --name raychd -p 6667:6667 -p 6697:6697 \
#           -v $(pwd)/inspircd.conf:/etc/inspircd/inspircd.conf:ro \
#           -v raychd-data:/var/log/inspircd \
#           raychd

FROM debian:bookworm-slim

# Install InspIRCd from Debian's official package repo (no build-from-source needed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        inspircd \
        netcat-openbsd \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Your server config — swap this for a bind-mount in `docker run`/compose
# so you can edit it without rebuilding the image.
COPY inspircd.conf /etc/inspircd/inspircd.conf

# 6667 = plaintext IRC, 6697 = TLS IRC
EXPOSE 6667 6697

# The Debian package already creates an unprivileged "irc" user — don't run as root
USER irc

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD nc -z localhost 6667 || exit 1

ENTRYPOINT ["/usr/sbin/inspircd"]
CMD ["--nofork"]
