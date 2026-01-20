# Use lightweight Linux base
FROM ubuntu:22.04

# Install dependencies and Tailscale
RUN apt-get update && \
    apt-get install -y curl iproute2 sudo iptables && \
    curl -fsSL https://tailscale.com/install.sh | sh

# Set environment variable for Tailscale auth key (to be set in Render)
ENV TAILSCALE_AUTHKEY=""

# Expose any port you need (optional)
EXPOSE 10000

# Start Tailscale daemon and log in headlessly
CMD tailscaled --tun=userspace-networking --state=/tmp/tailscale.state --socket=/tmp/tailscale.sock & \
    sleep 2 && \
    tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=render-node-1 --accept-routes --tun=userspace-networking && \
    tail -f /dev/null

