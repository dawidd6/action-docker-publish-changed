FROM docker

RUN apk -U add ruby ruby-rdoc
RUN gem install octokit

COPY entrypoint.rb /

ENTRYPOINT ["/entrypoint.rb"]
