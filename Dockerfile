FROM docker

ARG buildx_version="0.3.1"
ARG buildx_path="/usr/bin/buildx"
ARG buildx_url="https://github.com/docker/buildx/releases/download/v${buildx_version}/buildx-v${buildx_version}.linux-amd64"

RUN apk -U add ruby-full
RUN gem install octokit

RUN wget -O ${buildx_path} ${buildx_url}
RUN chmod +x ${buildx_path}

COPY *.rb /

ENTRYPOINT ["/main.rb"]
