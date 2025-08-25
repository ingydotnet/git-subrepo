FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y \
    bison \
    build-essential \
    git \
    git-lfs \
    golang-go \
    vim \
    wget \
    autoconf \
    libssl-dev \
    libghc-zlib-dev \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
    libpcre3-dev \
    unzip \
    libz-dev \
    make \
    && true

# Install shellcheck-0.7.1
RUN cd /root \
    && wget https://github.com/koalaman/shellcheck/releases/download/v0.7.1/shellcheck-v0.7.1.linux.x86_64.tar.xz \
    && tar xf shellcheck-v0.7.1.linux.x86_64.tar.xz \
    && mv shellcheck-v0.7.1/shellcheck /usr/local/bin/ \
    && rm -fr shellcheck* \
    && true

# Buil/install bash-4.0
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-4.0.tar.gz \
    && tar -xzf bash-4.0.tar.gz \
    && cd bash-4.0 \
    && ./configure --prefix=/bash-4.0 \
    && make \
    && make install \
    && rm -fr bash* \
    && true

# Buil/install bash-4.1
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-4.1.tar.gz \
    && tar -xzf bash-4.1.tar.gz \
    && cd bash-4.1 \
    && ./configure --prefix=/bash-4.1 \
    && make \
    && make install \
    && rm -fr bash* \
    && true

# Buil/install bash-4.2
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-4.2.tar.gz \
    && tar -xzf bash-4.2.tar.gz \
    && cd bash-4.2 \
    && ./configure --prefix=/bash-4.2 \
    && make \
    && make install \
    && rm -fr bash* \
    && true

# Buil/install bash-4.3
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz \
    && tar -xzf bash-4.3.tar.gz \
    && cd bash-4.3 \
    && ./configure --prefix=/bash-4.3 \
    && make \
    && make install \
    && rm -fr bash* \
    && true

# Buil/install bash-4.4
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-4.4.tar.gz \
    && tar -xzf bash-4.4.tar.gz \
    && cd bash-4.4 \
    && ./configure --prefix=/bash-4.4 \
    && make \
    && make install \
    && rm -fr bash* \
    && true

# Buil/install bash-5.0
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz \
    && tar -xzf bash-5.0.tar.gz \
    && cd bash-5.0 \
    && ./configure --prefix=/bash-5.0 \
    && make \
    && make install \
    && rm -fr bash* \
    && true

# Buil/install bash-5.1-rc1
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-5.1-rc1.tar.gz \
    && tar -xzf bash-5.1-rc1.tar.gz \
    && cd bash-5.1-rc1 \
    && ./configure --prefix=/bash-5.1 \
    && make \
    && make install \
    && rm -fr bash* \
    && true

# Buil/install bash-5.2
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz \
    && tar -xzf bash-5.2.tar.gz \
    && cd bash-5.2 \
    && ./configure --prefix=/bash-5.2 \
    && make \
    && make install \
    && rm -fr bash* \
    && true

# Buil/install bash-5.3
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-5.3.tar.gz \
    && tar -xzf bash-5.3.tar.gz \
    && cd bash-5.3 \
    && ./configure --prefix=/bash-5.3 \
    && make \
    && make install \
    && rm -fr bash* \
    && true


# Build/install git-2.17
RUN cd /root \
    && wget --timeout=60 --retry-connrefused --tries=3 https://github.com/git/git/archive/v2.23.4.tar.gz \
    && tar -xzf v2.23.4.tar.gz \
    && cd git-2.23.4 \
    && make configure \
    && ./configure --prefix=/git-2.23 --with-openssl --with-libpcre --with-curl \
    && make all -j$(nproc) \
    && make install \
    && cd /root && rm -fr git* v2.23.4.tar.gz

# Build/install git-2.25
RUN cd /root \
    && wget --timeout=60 --retry-connrefused --tries=3 https://github.com/git/git/archive/v2.25.5.tar.gz \
    && tar -xzf v2.25.5.tar.gz \
    && cd git-2.25.5 \
    && make configure \
    && ./configure --prefix=/git-2.25 --with-openssl --with-libpcre --with-curl \
    && make all -j$(nproc) \
    && make install \
    && cd /root && rm -fr git* v2.25.5.tar.gz

# Build/install git-2.29
RUN cd /root \
    && wget --timeout=60 --retry-connrefused --tries=3 https://github.com/git/git/archive/v2.29.3.tar.gz \
    && tar -xzf v2.29.3.tar.gz \
    && cd git-2.29.3 \
    && make configure \
    && ./configure --prefix=/git-2.29 --with-openssl --with-libpcre --with-curl \
    && make all -j$(nproc) \
    && make install \
    && cd /root && rm -fr git* v2.29.3.tar.gz

# Build/install git-2.30
RUN cd /root \
    && wget --timeout=60 --retry-connrefused --tries=3 https://github.com/git/git/archive/v2.30.9.tar.gz \
    && tar -xzf v2.30.9.tar.gz \
    && cd git-2.30.9 \
    && make configure \
    && ./configure --prefix=/git-2.30 --with-openssl --with-libpcre --with-curl \
    && make all -j$(nproc) \
    && make install \
    && cd /root && rm -fr git* v2.30.9.tar.gz

# Build/install git-2.40
RUN cd /root \
    && wget --timeout=60 --retry-connrefused --tries=3 https://github.com/git/git/archive/v2.40.1.tar.gz \
    && tar -xzf v2.40.1.tar.gz \
    && cd git-2.40.1 \
    && make configure \
    && ./configure --prefix=/git-2.40 --with-openssl --with-libpcre --with-curl \
    && make all -j$(nproc) \
    && make install \
    && cd /root && rm -fr git* v2.40.1.tar.gz

# Build/install git-2.48
RUN cd /root \
    && wget --timeout=60 --retry-connrefused --tries=3 https://github.com/git/git/archive/v2.48.0.tar.gz \
    && tar -xzf v2.48.0.tar.gz \
    && cd git-2.48.0 \
    && make configure \
    && ./configure --prefix=/git-2.48 --with-openssl --with-libpcre --with-curl \
    && make all -j$(nproc) \
    && make install \
    && cd /root && rm -fr git* v2.48.0.tar.gz

# Build/install git-2.51
RUN cd /root \
    && wget --timeout=60 --retry-connrefused --tries=3 https://github.com/git/git/archive/v2.51.0.tar.gz \
    && tar -xzf v2.51.0.tar.gz \
    && cd git-2.51.0 \
    && make configure \
    && ./configure --prefix=/git-2.51 --with-openssl --with-libpcre --with-curl \
    && make all -j$(nproc) \
    && make install \
    && cd /root && rm -fr git* v2.51.0.tar.gz

# Buil/install bash-5.3
RUN cd /root \
    && wget https://ftp.gnu.org/gnu/bash/bash-5.3.tar.gz \
    && tar -xzf bash-5.3.tar.gz \
    && cd bash-5.3 \
    && ./configure --prefix=/bash-5.3 \
    && make \
    && make install \
    && rm -fr bash* \
    && true

RUN git config --global user.email "you@example.com" \
    && git config --global user.name "Your Name" \
    && true
