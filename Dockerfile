# -*- Dockerfile -*-
FROM alpine:3.10

ARG ORG_RELEASE=9.2.2

RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    apk --update add --no-cache \
        bash \
        curl \
        emacs \
        gnutls \
        git \
        libxml2-utils \
        libxslt \
        libyang \
        make \
        ncurses \
        python3 \
        py3-pip \
        py3-lxml \
        tidyhtml && \
        pip3 install --no-cache-dir -U pip && \
        pip3 install --no-cache-dir pyang xml2rfc==2.44.0 && \
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
    rm -rf /yang-git

ENV YANG_MODPATH=/yang:/yang-drafts
VOLUME /work
WORKDIR /work
CMD [ "bash" ]
