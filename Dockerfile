FROM docker

RUN apk -U add ruby ruby-rdoc
RUN gem install octokit

COPY *.rb /

ENTRYPOINT ["/main.rb"]
