FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl iproute2 sudo ca-certificates iptables net-tools procps \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Create persistent state
RUN mkdir -p /tailscale-state && chmod 700 /tailscale-state

ENV TAILSCALE_SOCKET=/tailscale-state/tailscale.sock
ENV TAILSCALE_AUTH_KEY=""

# Start tailscaled in userspace networking mode and automatically up
ENTRYPOINT ["/bin/bash", "-c", "\
    tailscaled --tun=userspace-networking --state=/tailscale-state/tailscale.state --socket=$TAILSCALE_SOCKET & \
    sleep 5; \
    if [ -n \"$TAILSCALE_AUTH_KEY\" ]; then \
        tailscale up --authkey=$TAILSCALE_AUTH_KEY --hostname=$(hostname) --accept-routes --accept-dns --userspace-networking; \
    else \
        echo 'Set TAILSCALE_AUTH_KEY environment variable to authenticate'; \
        tail -f /dev/null; \
    fi \
"]

