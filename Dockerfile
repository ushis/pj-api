FROM ruby:2.3.0

RUN apt-get update -qq && \
  apt-get install -y build-essential libpq-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /pj-api
WORKDIR /pj-api

COPY Gemfile Gemfile.lock /pj-api/
RUN bundle install --jobs 4

COPY . /pj-api

EXPOSE 3000

CMD rails s -b 0.0.0.0
