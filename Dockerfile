FROM alpine:latest
RUN apk --update --no-cache add build-base ruby-dev ruby-etc ruby-json ruby-bigdecimal ruby-webrick \
        && gem install bundler
WORKDIR /srv/jekyll
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install
