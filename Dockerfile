# Use the official Home Assistant add-on base image
FROM ghcr.io/hassio-addons/base:21.0.9

# Define the Pangolin version (used everywhere below)
ARG PANGOLIN_VERSION=1.19.0
ENV PANGOLIN_VERSION=${PANGOLIN_VERSION}

# Install dependencies
RUN apk add --no-cache bash curl jq

# Detect system architecture and download the correct Pangolin binary
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -fsSL -o /usr/bin/pangolin https://github.com/fosrl/cli/releases/download/${PANGOLIN_VERSION}/pangolin-cli_linux_amd64; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl -fsSL -o /usr/bin/pangolin https://github.com/fosrl/cli/releases/download/${PANGOLIN_VERSION}/pangolin-cli_linux_arm64; \
    elif [ "$ARCH" = "riscv64" ]; then \
        curl -fsSL -o /usr/bin/pangolin https://github.com/fosrl/cli/releases/download/${PANGOLIN_VERSION}/pangolin-cli_linux_riscv64; \
    else \
        echo "❌ ERROR: Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    chmod +x /usr/bin/pangolin


# Copy the script into the container
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Run the script as the main process
ENTRYPOINT [ "/run.sh" ]
