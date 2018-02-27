FROM ruby:2.4

RUN mkdir -p /gem
WORKDIR /gem

ADD . ./

RUN gem install bundler && bundle install --jobs 20 --retry 5
