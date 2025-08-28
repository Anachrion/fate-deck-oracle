# Deployment Guide for Render

## Prerequisites

1. Ensure you have the `RAILS_MASTER_KEY` environment variable set in your Render service
2. Make sure your Ruby version matches the one specified in `.ruby-version` (3.3.0)

## Environment Variables

Set these environment variables in your Render service:

- `RAILS_MASTER_KEY`: Your Rails master key (required for asset precompilation)
- `RAILS_ENV`: Set to `production`
- `DATABASE_URL`: Your database connection string

## Build Process

The Dockerfile will automatically:

1. Build Tailwind CSS using `./bin/rails tailwindcss:build`
2. Precompile assets using `./bin/rails assets:precompile`
3. Copy compiled assets to the public directory
4. Ensure Tailwind CSS is available in production

## Troubleshooting

### Asset Pipeline Issues

If you encounter "The asset 'tailwind.css' is not present in the asset pipeline":

1. Check that `RAILS_MASTER_KEY` is set in Render
2. Verify that the build process completed successfully
3. Check the build logs for any asset compilation errors

### Manual Asset Building

If assets still aren't working, you can manually build them:

```bash
# Build Tailwind CSS
bundle exec rails tailwindcss:build

# Precompile assets
bundle exec rails assets:precompile

# Ensure Tailwind CSS is available
bundle exec rails assets:ensure_tailwind
```

### Local Testing

To test the build process locally:

```bash
# Use the build script
./bin/build

# Or run individual commands
bundle exec rails tailwindcss:build
bundle exec rails assets:precompile
```

## File Structure

The application expects these files to be present:

- `app/assets/builds/tailwind.css` - Compiled Tailwind CSS
- `public/assets/tailwind.css` - Production-ready Tailwind CSS
- `config/initializers/assets.rb` - Asset pipeline configuration
- `app/assets/config/manifest.js` - Asset manifest

## Common Issues

1. **Ruby Version Mismatch**: Ensure your local Ruby version matches the project requirement (3.3.0)
2. **Missing Dependencies**: Run `bundle install` before building
3. **Asset Precompilation Failures**: Check that all required environment variables are set
4. **Permission Issues**: Ensure the build process has write access to the assets directory
