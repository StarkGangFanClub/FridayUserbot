FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TERM xterm-256color
RUN apt-get update && apt upgrade -y && apt-get install sudo -y

RUN apt-get install -y\
    coreutils \
    bash \
    bzip2 \
    curl \
    tesseract-ocr \
    tesseract-ocr-eng \
    imagemagick \
    figlet \
    gcc \
    g++ \
    git \
    libevent-dev \
    libjpeg-dev \
    libffi-dev \
    libpq-dev \
    libsqlite3-dev \
    libwebp-dev \
    libgl1 \
    musl \
    neofetch \
    libcurl4-openssl-dev \
    postgresql \
    postgresql-client \
    postgresql-server-dev-all \
    openssl \
    mediainfo \
    wget \
    python3 \
    python3-dev \
    python3-pip \
    libreadline-dev \
    zipalign \
    sqlite3 \
    ffmpeg \
    libsqlite3-dev \
    axel \
    zlib1g-dev \
    recoverjpeg \
    zip \
    megatools \
    libfreetype6-dev \
    procps \
    pulseaudio \
    policykit-1

RUN cd /root && \
    sed -i 's/^#\s*\(deb.*partner\)$/\1/g' /etc/apt/sources.list && \
    sed -i 's/^#\s*\(deb.*restricted\)$/\1/g' /etc/apt/sources.list && \ 
    apt-get update -y && \ 
    apt-get install -yqq locales  && \ 
    apt-get install -yqq \
        mate-desktop-environment-core \
        mate-themes \
        mate-accessibility-profiles \
        mate-applet-appmenu \
        mate-applet-brisk-menu \
        mate-applets \
        mate-applets-common \
        mate-calc \
        mate-calc-common \
        mate-dock-applet \
        mate-hud \
        mate-indicator-applet \
        mate-indicator-applet-common \
        mate-menu \
        mate-notification-daemon \
        mate-notification-daemon-common \
        mate-utils \
        mate-utils-common \
        mate-window-applets-common \
        mate-window-buttons-applet \
        mate-window-menu-applet \
        mate-window-title-applet \
        ubuntu-mate-icon-themes \
        ubuntu-mate-themes \
        tightvncserver \
        pulseaudio && \
    apt-get install --no-install-recommends -yqq \
        supervisor \
        sudo \
        tzdata \
        vim \
        mc \
        ca-certificates \
        xterm \
        curl \
        wget \
        wmctrl \
        epiphany-browser && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime && dpkg-reconfigure -f noninteractive tzdata && \
    apt-get -y install \
        git \
        libxfont-dev \
        xserver-xorg-core \
        libx11-dev \
        libxfixes-dev \
        libssl-dev \
        libpam0g-dev \
        libtool \
        libjpeg-dev \
        flex \
        bison \
        gettext \
        autoconf \
        libxml-parser-perl \
        libfuse-dev \
        xsltproc \
        libxrandr-dev \
        python-libxml2 \
        nasm \
        xserver-xorg-dev \
        fuse \
        build-essential \
        pkg-config \
        libpulse-dev m4 intltool dpkg-dev \
        libfdk-aac-dev \
        libopus-dev \
        libmp3lame-dev && \ 
    apt-get update && apt build-dep pulseaudio -y && \
    cd /tmp && apt source pulseaudio && \
    pulsever=$(pulseaudio --version | awk '{print $2}') && cd /tmp/pulseaudio-$pulsever && ./configure  && \
    git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git && cd pulseaudio-module-xrdp && ./bootstrap && ./configure PULSE_DIR="/tmp/pulseaudio-$pulsever" && make && \
    cd /tmp/pulseaudio-$pulsever/pulseaudio-module-xrdp/src/.libs && install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so && \
    cd /root && \
    #git clone -b master https://github.com/neutrinolabs/xrdp.git && \
    #git clone -b master https://github.com/neutrinolabs/xorgxrdp.git && \
    git clone -b devel https://github.com/neutrinolabs/xrdp.git && \
    git clone -b devel https://github.com/neutrinolabs/xorgxrdp.git && \
    cd /root/xrdp && ./bootstrap && ./configure --enable-fuse --enable-jpeg --enable-vsock --enable-fdkaac --enable-opus --enable-mp3lame --enable-pixman && make && make install && \
    cd /root/xorgxrdp  && ./bootstrap && ./configure && make && make install && \
    cd /root && \
    rm -R /root/xrdp && \
    rm -R /root/xorgxrdp && \
    # bugfix clipboard bug: [xrdp-chansrv] <defunct> && \
    apt-mark manual libfdk-aac1 && \
    apt-get -y purge \
        git \
        libxfont-dev \
        libx11-dev \
        libxfixes-dev \
        libssl-dev \
        libpam0g-dev \
        libtool \
        libjpeg-dev \
        flex \
        bison \
        gettext \
        autoconf \
        libxml-parser-perl \
        libfuse-dev \
        xsltproc \
        libxrandr-dev \
        python-libxml2 \
        nasm \
        xserver-xorg-dev \
        build-essential \
        pkg-config \
        libfdk-aac-dev \
        libopus-dev \
        libmp3lame-dev && \
        #        fuse \
    apt-get -y autoclean && apt-get -y autoremove && \
    apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/*  && \
    echo "mate-session" > /etc/skel/.xsession && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini  && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini  && \
    sed -i -e '/DisconnectedTimeLimit=/ s/=.*/=0/' /etc/xrdp/sesman.ini && \
    sed -i -e '/IdleTimeLimit=/ s/=.*/=0/' /etc/xrdp/sesman.ini && \
    xrdp-keygen xrdp auto  && \
    mkdir -p /var/run/xrdp && \
    chmod 2775 /var/run/xrdp  && \
    mkdir -p /var/run/xrdp/sockdir && \
    chmod 3777 /var/run/xrdp/sockdir && \
    touch /etc/skel/.Xauthority && \
    mkdir /run/dbus/ && chown messagebus:messagebus /run/dbus/ && \
    #dbus-uuidgen > /etc/machine-id && \
    #ln -sf /var/lib/dbus/machine-id /etc/machine-id && \  
    echo "[program:xrdp-sesman]" > /etc/supervisor/conf.d/xrdp.conf && \
    echo "command=/usr/local/sbin/xrdp-sesman --nodaemon" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "process_name = xrdp-sesman" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "[program:xrdp]" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "command=/usr/local/sbin/xrdp -nodaemon" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "process_name = xrdp" >> /etc/supervisor/conf.d/xrdp.conf
#RUN     echo "[program:dbus-daemon]" > /etc/supervisor/conf.d/dbus-daemon.conf && \
#    echo "command=/usr/bin/dbus-daemon --system --nofork" >> /etc/supervisor/conf.d/dbus-daemon.conf && \
#    echo "process_name = dbus-daemon" >> /etc/supervisor/conf.d/dbus-daemon.conf && \
#    echo "user = messagebus"  >> /etc/supervisor/conf.d/dbus-daemon.conf
RUN git clone https://github.com/StarkGang/docker-ubuntu-xrdp-mate-custom
RUN cd docker-ubuntu-xrdp-mate-custom
RUN ["bash", "autostartup.sh"]
RUN apt-get autoremove --purge
RUN pip3 install --upgrade pip setuptools 
RUN pip3 install --upgrade pip
RUN if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi 
RUN if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi 
RUN rm -r /root/.cache
RUN axel https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && apt install -y ./google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb
RUN axel https://chromedriver.storage.googleapis.com/88.0.4324.96/chromedriver_linux64.zip && unzip chromedriver_linux64.zip && chmod +x chromedriver && mv -f chromedriver /usr/bin/ && rm chromedriver_linux64.zip
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/master.zip && unzip opencv.zip && mv -f opencv-master /usr/bin/ && rm opencv.zip
RUN git clone https://github.com/DevsExpo/FridayUserbot /root/fridaybot
RUN mkdir /root/fridaybot/bin/
WORKDIR /root/fridaybot/
RUN chmod +x /usr/local/bin/*
RUN pip3 install -r requirements.txt
RUN echo Friday
CMD ["bash","start.sh"]
EXPOSE 3389 22
