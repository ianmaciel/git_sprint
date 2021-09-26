# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.187.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends \
  wget \
  # Flutter dependencies:
  curl unzip xz-utils zip \
  # Flutter desktop dependencies
  clang cmake ninja-build pkg-config libgtk-3-dev \
  # Desktop support (enable x11 inside docker)
  x11-apps \
  # xdg-user-dirs is used by HiveStore/graphql_flutter
  xdg-user-dirs

# Install Flutter
WORKDIR "/opt"
ENV FLUTTER_TARBALL=flutter_linux_2.5.0-stable.tar.xz
ENV FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TARBALL}"
RUN wget --progress=dot:mega "${FLUTTER_SDK_URL}" && \
  tar xf "${FLUTTER_TARBALL}" && \
  rm "${FLUTTER_TARBALL}" && \
  # Give permissions to users write on Flutter folder.
  # Flutter requires RW access at least for ./cache, ./version ./.pub-cache and .git
  chmod -R a+rw /opt/flutter

# Add Flutter PATH.
ENV PATH="/opt/flutter/bin:${PATH}"
