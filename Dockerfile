FROM swift:5.9-jammy 

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  && apt-get -q update \
  && apt-get -q dist-upgrade -y \
  && rm -rf /var/lib/apt/lists/*

RUN apt update && apt install wget g++ unzip zip -y

RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.20.0/bazelisk-linux-arm64 && \
  chmod 755 bazelisk-linux-arm64 && \
  mv bazelisk-linux-arm64 /usr/bin/bazelisk

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

ENV CC=clang

RUN cat >>local.bazelrc <<EOF
build --action_env=PATH
EOF

RUN bazelisk build //:server

ENTRYPOINT ["tail", "-f", "/dev/null"]
