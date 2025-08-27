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

### Option 1: Pre-build Assets Locally (Recommended)

1. **Build Tailwind CSS locally before Docker build**:
   ```bash
   ./bin/pre-build
   ```

2. **Deploy to Render**:
   - The Dockerfile will copy the pre-built assets without trying to build them
   - This avoids the "tailwindcss:build" error during Docker build

### Option 2: Build During Docker Build (Alternative)

The Dockerfile will automatically:
1. Copy existing assets from `app/assets/builds/` to `public/assets/`
2. Ensure Tailwind CSS is available in production

## Troubleshooting

### Asset Pipeline Issues

If you encounter "The asset 'tailwind.css' is not present in the asset pipeline":

1. **Check that `RAILS_MASTER_KEY` is set in Render**
2. **Verify that the build process completed successfully**
3. **Check the build logs for any asset compilation errors**

### Docker Build Failures

If you get "failed to solve: process '/bin/sh -c ./bin/rails tailwindcss:build' did not complete successfully":

1. **Use the pre-build approach**:
   ```bash
   ./bin/pre-build
   docker build -t your-app-name .
   ```

2. **Check your local Ruby version**:
   ```bash
   ruby --version
   # Should match .ruby-version (3.3.0)
   ```

3. **Ensure Tailwind CSS is built locally**:
   ```bash
   bundle exec rails tailwindcss:build
   ```

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
# Use the pre-build script (recommended)
./bin/pre-build

# Or run individual commands
bundle exec rails tailwindcss:build
bundle exec rails assets:precompile
```

## File Structure

The application expects these files to be present:

- `app/assets/builds/tailwind.css` - Compiled Tailwind CSS (built locally)
- `public/assets/tailwind.css` - Production-ready Tailwind CSS (copied during Docker build)
- `config/initializers/assets.rb` - Asset pipeline configuration
- `app/assets/config/manifest.js` - Asset manifest

## Common Issues

1. **Ruby Version Mismatch**: Ensure your local Ruby version matches the project requirement (3.3.0)
2. **Missing Dependencies**: Run `bundle install` before building
3. **Asset Precompilation Failures**: Check that all required environment variables are set
4. **Permission Issues**: Ensure the build process has write access to the assets directory
5. **Docker Build Failures**: Use the pre-build approach to avoid Rails command issues during Docker build

## Quick Fix for Render Deployment

If you're still having issues, try this simplified approach:

1. **Build assets locally**:
   ```bash
   ./bin/pre-build
   ```

2. **Commit the built assets**:
   ```bash
   git add app/assets/builds/
   git commit -m "Add pre-built Tailwind CSS assets"
   git push
   ```

3. **Deploy to Render**:
   - The Dockerfile will copy the existing assets without building them
   - This should resolve the "tailwindcss:build" error
