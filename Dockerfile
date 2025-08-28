# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Build Tailwind CSS first
RUN ./bin/rails tailwindcss:build

# Precompiling assets for production
# Note: This requires RAILS_MASTER_KEY to be set during build or runtime
RUN if [ -n "$RAILS_MASTER_KEY" ]; then \
      ./bin/rails assets:precompile; \
    else \
      echo "Warning: RAILS_MASTER_KEY not set, assets will be precompiled at runtime"; \
    fi

# Ensure the builds directory exists and contains the compiled assets
RUN mkdir -p public/assets && \
    if [ -d "app/assets/builds" ]; then \
      cp -r app/assets/builds/* public/assets/ 2>/dev/null || true; \
    fi

# Alternative asset compilation if RAILS_MASTER_KEY is not available
RUN if [ ! -f "public/assets/tailwind.css" ] && [ -f "app/assets/builds/tailwind.css" ]; then \
      mkdir -p public/assets && \
      cp app/assets/builds/tailwind.css public/assets/; \
    fi

# Use Rake task to ensure Tailwind CSS is available
RUN ./bin/rails assets:ensure_tailwind

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp config
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
