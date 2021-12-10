#!/usr/bin/env bash

set -eu

# docker stop $(docker ps -aq)
# docker rm $(docker ps -aq)
# docker rmi $(docker images -q)

# x86_64
base_url="https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-amd64-root.tar.gz"

RUBY_MAJOR="2.7"
RUBY_VERSION="ruby-2.7.5"

# Ubuntu 20.04
core_name="ubuntu-focal"
image_ver="v0.1"

_download() {
    echo "Ubuntu focal core 下载中..."
    wget $1
}

# 如果build过程下载非常慢，或者下载失败，请挂上你的科学小神器...
# docker build 参数加入 --build-arg "HTTP_PROXY=你的代理地址"
#                      --build-arg "HTTPS_PROXY=你的代理地址"
_build() {
    docker build . \
                 --no-cache \
                 -t ${RUBY_VERSION}/${core_name}:${image_ver}
}

_main() {
    if [[ ! -f "${base_url##*/}" ]]; then
        _download "${base_url}"
    else
        echo "Ubuntu focal core 已存在，跳过下载..."
        _build
    fi
}

_main