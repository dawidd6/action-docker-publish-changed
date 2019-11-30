FROM docker

RUN apk -U add ruby-full
RUN gem install octokit

COPY *.rb /

ENTRYPOINT ["/main.rb"]
