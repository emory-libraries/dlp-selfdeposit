ARG ALPINE_VERSION=3.19
ARG RUBY_VERSION=3.2.3

FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION AS hyrax-base

ARG DATABASE_APK_PACKAGE="postgresql-dev"
ARG EXTRA_APK_PACKAGES="git"
ARG RUBYGEMS_VERSION=""

RUN apk --no-cache upgrade && \
  apk --no-cache add acl \
  build-base \
  bash \
  curl \
  gcompat \
  imagemagick \
  imagemagick-heic \
  imagemagick-jpeg \
  imagemagick-jxl \
  imagemagick-pdf \
  imagemagick-svg \
  imagemagick-tiff \
  imagemagick-webp \
  libxml2-dev \
  jemalloc \
  tzdata \
  nodejs \
  yarn \
  zip \
  ffmpeg \
  mediainfo \
  perl \
  $DATABASE_APK_PACKAGE \
  $EXTRA_APK_PACKAGES

RUN setfacl -d -m o::rwx /usr/local/bundle && \
  gem update --system $RUBYGEMS_VERSION

RUN addgroup -S --gid 101 app && \
  adduser -S -G app -u 1001 -s /bin/sh -h /app app
USER app

RUN mkdir -p /app
WORKDIR /app
COPY .env.docker_dev /app/.env.production

COPY --chown=1001:101 ./scripts/*.sh /app/scripts/

ENV RAILS_ROOT="/app" \
    RAILS_SERVE_STATIC_FILES="1" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so.2"

ENTRYPOINT ["./scripts/entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]


FROM hyrax-base AS hyrax

ARG APP_PATH=.
ARG BUNDLE_WITHOUT=

ONBUILD COPY --chown=1001:101 $APP_PATH /app
ONBUILD RUN bundle install --jobs "$(nproc)"
ONBUILD RUN yarn
ONBUILD RUN RAILS_ENV=production SECRET_KEY_BASE=dummy DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile


FROM hyrax-base AS hyrax-worker-base

USER root
RUN apk --no-cache add bash \
  ffmpeg \
  mediainfo \
  openjdk17-jre \
  perl
USER app

RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://github.com/harvard-lts/fits/releases/download/1.6.0/fits-1.6.0.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip tools/mediainfo/linux/libmediainfo.so.0 tools/mediainfo/linux/libzen.so.0 && \
    chmod a+x /app/fits/fits.sh && \
    sed -i 's/\(<tool.*TikaTool.*>\)/<!--\1-->/' /app/fits/xml/fits.xml
ENV PATH="${PATH}:/app/fits"

CMD bundle exec sidekiq


FROM hyrax-worker-base AS hyrax-worker

ARG APP_PATH=.
ARG BUNDLE_WITHOUT=

COPY --chown=1001:101 $APP_PATH /app
RUN bundle install --jobs "$(nproc)"
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile

