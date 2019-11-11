# -*- Dockerfile -*-
FROM alpine:3.10

ARG ORG_RELEASE=9.2.2

RUN apk --update add --no-cache \
        bash \
        curl \
        emacs \
        gnutls \
        git \
        libxml2-utils \
        libxslt \
        ncurses \
        python3 \
        py3-pip \
        py3-lxml \
        tidyhtml && \
    apk --update add --no-cache libyang --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
        pip3 install --no-cache-dir -U pip && \
        pip3 install --no-cache-dir pyang xml2rfc==2.22.3 && \
    apk --update add --virtual build-dependencies make && \
    # Add newer org mode.
    mkdir -p /tmp/org-${ORG_RELEASE} && \
    (cd /tmp/org-${ORG_RELEASE} && \
    curl -fL --silent https://code.orgmode.org/bzg/org-mode/archive/release_${ORG_RELEASE}.tar.gz | tar --strip-components=1 -xzf - && \
    make autoloads lisp) && \
    # Add yang models
    mkdir -p /yang /yang-drafts /yang-git /work && \
    (cd /yang-git && curl -L https://github.com/YangModels/yang/tarball/master | tar --strip 1 -xzf -) && \
    find /yang-git/standard -name '*.yang' ! -path '*vendor*' -exec mv {} /yang \; && \
    find /yang-git/experimental -name '*.yang' ! -path '*vendor*' -exec mv {} /yang-drafts \; && \
    rm -rf /yang-git && \
    # Remove unneeded packages.
    apk del build-dependencies

ENV YANG_MODPATH=/yang:/yang-drafts
VOLUME /work
WORKDIR /work
CMD [ "bash" ]
