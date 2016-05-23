FROM ruby:2.3.1

RUN apt-get update -qq && \
  apt-get install -y build-essential libpq-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN adduser --gecos GECOS --disabled-password --shell /bin/bash app

RUN mkdir /home/app/src
WORKDIR /home/app/src

ENV BUNDLE_JOBS=4 \
  BUNDLE_PATH=/home/app/bundle \
  BUNDLE_APP_CONFIG=/home/app/bundle/config \
  GEM_PATH=/home/app/bundle:$GEM_PATH \
  PATH=/home/app/bundle/bin:$PATH

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./
RUN chown -R app:app /home/app

EXPOSE 3000

USER app
CMD rails s -b 0.0.0.0
