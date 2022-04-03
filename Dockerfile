FROM mysql:8.0.18

RUN mkdir /var/log/mysql
RUN chown mysql:mysql /var/log/mysql
RUN mkdir /var/run/mysql
RUN chown mysql:mysql /var/run/mysql

FROM ruby:3.0.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /app
WORKDIR /app 
ADD Gemfile /app/Gemfile
# ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install
ADD . /app
