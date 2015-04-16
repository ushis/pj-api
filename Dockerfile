FROM ruby:2.2.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN mkdir /pj-api
WORKDIR /pj-api

COPY Gemfile /pj-api/Gemfile
COPY Gemfile.lock /pj-api/Gemfile.lock
RUN bundle install --jobs 4

COPY . /pj-api

EXPOSE 3000

CMD rails s -b 0.0.0.0
