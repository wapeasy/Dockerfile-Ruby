# https://github.com/tianon/docker-brew-ubuntu-core/blob/bf61e139e84e04f9d87fff5dc588a3f0398da627/focal/Dockerfile
FROM scratch
ADD ubuntu-focal-core-cloudimg-amd64-root.tar.gz /

ENV LANG C.UTF-8
ENV USER ruby
ENV RUBY_VERSION 2.7.5
ENV RUBY_SOURCE https://cache.ruby-china.com/pub/ruby/

# 国内源
# ARG RUBY_SOURCE=https://cache.ruby-china.com/pub/ruby/

# 官方源
# ARG RUBY_SOURCE=https://cache.ruby-lang.org/pub/ruby/

# creat new user
RUN useradd --create-home --no-log-init --shell /bin/bash $USER; \
    mkdir -p /home/ruby/workspace; \
    # apt update and install basic tools
    sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list; \
    sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list; \
    apt-get update; \
		apt-get install -y --no-install-recommends \
        gnupg2 \
        ca-certificates \
        git \
        vim \
		curl; \
        apt-get clean;

# install rvm for ubuntu
# RUN apt-get update; \
# 		apt-get install -y --no-install-recommends \
#         software-properties-common; \
#         apt-get clean;

# RUN apt-get update; \
# 	apt-add-repository -y ppa:rael-gc/rvm; \
# 	apt-get update; \
# 	apt-get install -y --no-install-recommends \
# 					rvm; \ 
# 	rm -rf /var/lib/apt/lists/*;

SHELL [ "/bin/bash", "-l", "-c" ]

RUN gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB; \
    curl -sSL https://gitee.com/wapeasy/dockerfile-ruby/raw/master/scripts/rvm-installer.sh | bash -s stable; \
    source /etc/profile.d/rvm.sh; \
    rvm group add rvm $USER; \
    echo "ruby_url=$RUBY_SOURCE" > /usr/local/rvm/db; \
    rvm install $RUBY_VERSION; \
    rvm use $RUBY_VERSION --default; \
    gem sources --remove https://rubygems.org/; \
    gem sources -a https://gems.ruby-china.com/; \
    gem update --system; \
    gem install bundler jekyll; \
    bundle config mirror.https://rubygems.org https://gems.ruby-china.com/; \
    gem cleanup;

# use ruby user login
USER $USER

# docker default dir
WORKDIR /home/ruby
