FROM alpinelinux/docker-cli

MAINTAINER Brad Soper <bradley.soper@dell.com>

RUN apk --no-cache add git \
            python3 \
            curl \
            bash \
            vault \
            tar \
            jq && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip \
            setuptools \
            wheel \
            yq \
            jinja2 && \
    curl -LJO https://github.com/concourse/concourse/releases/download/v6.3.0/fly-6.3.0-linux-amd64.tgz && \
    tar xvzf fly-6.3.0-linux-amd64.tgz && \
    rm fly-6.3.0-linux-amd64.tgz && \
    chmod +x fly && \
    mv fly /usr/local/bin
