FROM python:3.8.5-slim-buster
LABEL maintainer="Ivan Ega Pratama"

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

# Prepare the GUI
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    dbus-x11 \
    gnupg2 \
    jq \
    software-properties-common \
    tzdata \
    unzip \
    wget \
    x11-xserver-utils \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Install wine
ARG WINE_BRANCH="stable"
RUN wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && apt-add-repository "deb https://dl.winehq.org/wine-builds/debian/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" \
    && wget -nv -O- https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && apt-add-repository "deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-${WINE_BRANCH} \
    && rm -rf /var/lib/apt/lists/*

# Install winetricks
RUN wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/bin/winetricks

# Download gecko and mono installers
COPY download_gecko_and_mono.sh /root/download_gecko_and_mono.sh
RUN /root/download_gecko_and_mono.sh "$(dpkg -s wine-${WINE_BRANCH} | grep "^Version:\s" | awk '{print $2}' | sed -E 's/~.*$//')"

# Download AutoHotkey
ARG AHK_VERSION="1.1.33.02"
COPY configure.sh /root/configure.sh
RUN wget -nv -O /root/AHK.exe https://github.com/Lexikos/AutoHotkey_L/releases/download/v${AHK_VERSION}/AutoHotkey_${AHK_VERSION}_setup.exe && \
    /root/configure.sh

COPY entrypoint.sh /usr/bin/entrypoint

ENTRYPOINT [ "/usr/bin/entrypoint" ]