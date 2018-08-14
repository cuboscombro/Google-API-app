FROM ruby:2.5.0-alpine3.7
RUN mkdir /app
WORKDIR /app
ADD . .
RUN bundle install
ENTRYPOINT ["bundle","exec","rackup","-o","0.0.0.0"]
