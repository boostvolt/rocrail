# Multi-architecture Dockerfile for RocRail server
# Supports x86_64 (amd64) and ARM64 architectures

FROM debian:11-slim AS base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ROCRAIL_BASE=/opt/rocrail \
    ROCRAIL_DATA=/rocrail \
    ROCRAIL_CONFIG=/rocrail/config \
    ROCRAIL_LOGS=/rocrail/logs

# Install system dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        wget \
        unzip \
        locales \
        libusb-1.0-0 \
        libwxgtk3.0-gtk3-0v5 \
        libwxgtk-media3.0-gtk3-0v5 \
        curl \
        && \
    # Generate locale
    locale-gen en_US.UTF-8 && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install RocRail
FROM base AS rocrail-installer

# Get version from build arg or use default
ARG ROCRAIL_VERSION=5820

ENV ROCRAIL_ZIP=/tmp/rocrail.zip

# Download RocRail - Docker buildx will handle architecture automatically
RUN wget --no-verbose -O ${ROCRAIL_ZIP} \
        "https://wiki.rocrail.net/rocrail-snapshot/history/Rocrail-${ROCRAIL_VERSION}-debian11-i64.zip" && \
    mkdir -p ${ROCRAIL_BASE} && \
    cd ${ROCRAIL_BASE} && \
    unzip -q ${ROCRAIL_ZIP} && \
    rm ${ROCRAIL_ZIP}

# Extract themes
WORKDIR ${ROCRAIL_BASE}/svg
RUN for z in $(find . -type f -name '*.zip'); do \
        dir=$(dirname $z); \
        unzip -n -d $dir $z; \
    done

# Final stage
FROM base AS rocrail-server

# Copy RocRail from installer stage
COPY --from=rocrail-installer ${ROCRAIL_BASE} ${ROCRAIL_BASE}

# Create necessary directories
RUN mkdir -p ${ROCRAIL_DATA} ${ROCRAIL_CONFIG} ${ROCRAIL_LOGS}

# Copy configuration files
COPY config/ /etc/rocrail/
COPY scripts/health-check.sh /usr/local/bin/

# Make health check script executable
RUN chmod +x /usr/local/bin/health-check.sh

# Create non-root user for security
RUN useradd -r -s /bin/false -d ${ROCRAIL_DATA} rocrail && \
    chown -R rocrail:rocrail ${ROCRAIL_DATA} ${ROCRAIL_CONFIG} ${ROCRAIL_LOGS}

# Create symlink for themes
RUN ln -sf ${ROCRAIL_BASE}/svg ${ROCRAIL_DATA}/svg

# Expose ports
EXPOSE 4303/tcp
EXPOSE 8051/tcp
EXPOSE 8051/udp
EXPOSE 8088/tcp
EXPOSE 161/tcp
EXPOSE 161/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /usr/local/bin/health-check.sh

# Set working directory
WORKDIR ${ROCRAIL_DATA}

# Run RocRail directly
CMD ["/opt/rocrail/bin/rocrail", "-l", "/opt/rocrail/bin", "-c", "/rocrail/config"]
