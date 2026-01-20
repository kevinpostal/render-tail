# ----------------------------------------
# Tailscale Headless Dockerfile for Render
# ----------------------------------------
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        iproute2 \
        sudo \
        ca-certificates \
        iptables \
        libcap2-bin \
        && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Create a directory for Tailscale state (inside container)
RUN mkdir -p /tailscale-state && \
    chmod 700 /tailscale-state

# Set environment variable for Tailscale auth key
# (Set RENDER_TAILSCALE_AUTHKEY in Render Dashboard)
ENV TAILSCALE_AUTH_KEY=""

# Entrypoint: start tailscaled and run "tailscale up" with auth key
ENTRYPOINT ["/bin/bash", "-c", "\
    tailscaled --tun=userspace-networking --state=/tailscale-state/tailscale.state --socket=/tailscale-state/tailscale.sock & \
    sleep 2 && \
    if [ -n \"$TAILSCALE_AUTH_KEY\" ]; then \
        tailscale up --authkey=$TAILSCALE_AUTH_KEY --hostname=$(hostname) --accept-routes --accept-dns; \
    else \
        echo 'Set TAILSCALE_AUTH_KEY environment variable to authenticate'; \
        tail -f /dev/null; \
    fi \
"]

