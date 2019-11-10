# -*- Dockerfile -*-
FROM ubuntu:19.10
RUN apt-get update && \
        apt-get upgrade -y && \
        apt-get install -y \
            build-essential \
            curl \
            git \
            gnutls-bin \
            gnutls-dev \
            jing \
            libncurses-dev \
            libxml2 \
            libxml2-dev \
            libxml2-utils \
            libxslt-dev \
            python-dev \
            python-pip \
            subversion \
            tidy \
            wget \
            xsltproc \
            yang-tools \
        && \
        pip install pyang xml2rfc==2.22.3

ENV SHELL=/bin/bash
ARG EVERSION=26.3
RUN curl -O http://ftp.gnu.org/gnu/emacs/emacs-$EVERSION.tar.gz && \
        tar xf emacs-$EVERSION.tar.gz

WORKDIR emacs-$EVERSION
RUN env CANNOT_DUMP=yes ./configure --with-gnutls=no && make && make install

ARG ORG_RELEASE=9.2.2
RUN mkdir -p /tmp/org-${ORG_RELEASE} && \
        (cd /tmp/org-${ORG_RELEASE} && \
        curl -fL --silent https://code.orgmode.org/bzg/org-mode/archive/release_${ORG_RELEASE}.tar.gz | tar --strip-components=1 -xzf - && \
        make autoloads lisp)

RUN mkdir -p /yang && mkdir -p /work && \
        git clone https://github.com/YangModels/yang.git /yang-git
RUN find /yang-git -type f -name '*.yang' ! -path '*vendor*' -exec cp -f -t /yang {} \;

ENV YANG_MODPATH=/yang
VOLUME /work
WORKDIR /work
CMD [ "bash" ]
