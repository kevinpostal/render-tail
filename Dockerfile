# Use lightweight Ubuntu base
FROM ubuntu:22.04

# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        iproute2 \
        sudo \
        ca-certificates \
        iptables \
        net-tools \
        procps \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Create persistent state directory
RUN mkdir -p /tailscale-state && chmod 700 /tailscale-state

# Set environment variable for Tailscale socket
ENV TAILSCALE_SOCKET=/tailscale-state/tailscale.sock

# Entrypoint: start tailscaled and optionally bring up Tailscale using auth key
ENTRYPOINT ["/bin/bash", "-c", "\
    tailscaled --tun=userspace-networking --state=/tailscale-state/tailscale.state --socket=/tailscale-state/tailscale.sock & \
    sleep 2; \
    if [ -n \"$TAILSCALE_AUTH_KEY\" ]; then \
        tailscale up --authkey=$TAILSCALE_AUTH_KEY --hostname=$(hostname) --accept-routes --accept-dns; \
    else \
        echo 'Set TAILSCALE_AUTH_KEY environment variable to authenticate'; \
        tail -f /dev/null; \
    fi \
"]

