# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.3.9
FROM ruby:$RUBY_VERSION-slim

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        libpq-dev \
        postgresql-client \
        libsqlite3-dev \
        libyaml-dev \
        pkg-config \
        git \
        curl \
        gnupg \
        sqlite3 \
        libvips \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    corepack enable && corepack prepare yarn@stable --activate


COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v 2.7.2 && \
    bundle config set force_ruby_platform true && \
    bundle install

COPY . .

EXPOSE 3000

CMD ["bash", "-c", "bin/rails db:create db:migrate && bin/rails server -b 0.0.0.0"]
