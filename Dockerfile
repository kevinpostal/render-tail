# Use lightweight Linux base
FROM ubuntu:22.04

# Install Tailscale
RUN apt-get update && \
    apt-get install -y curl iproute2 sudo && \
    curl -fsSL https://tailscale.com/install.sh | sh

# Start Tailscale headless
CMD ["tailscaled", "--tun=userspace-networking", "--state=/tmp/tailscale.state", "--socket=/tmp/tailscale.sock"]

