# Build Configuration Guide

This document explains how to build the documentation site with different base paths for different deployment targets.

## Base Path Configuration

The site supports two different base paths:

1. **Development (tejaswiniIBM/meta)**: Uses `/meta/` as the base path
2. **Production (zopencommunity)**: Uses `/` as the base path

## Building for Different Environments

### For Development (tejaswiniIBM/meta)

When building for the development repository at `tejaswiniIBM/meta`, use:

```bash
npm run build:dev
# or
npm run docs:build:dev
```

This sets `BASE_PATH=/meta/` and builds the site with the correct base path for GitHub Pages deployment at `https://tejaswiniibm.github.io/meta/`.

### For Production (zopencommunity)

When building for the production repository at `zopencommunity/meta`, use:

```bash
npm run build:prod
# or
npm run docs:build:prod
# or simply
npm run build
```

This sets `BASE_PATH=/` (or uses the default) and builds the site with the correct base path for deployment at `https://zopen.community/`.

## Manual Base Path Override

You can also manually set the base path when building:

```bash
BASE_PATH=/custom-path/ npm run docs:build
```

## How It Works

The `docs/.vitepress/config.mts` file reads the `BASE_PATH` environment variable and uses it to configure the VitePress base path. If no environment variable is set, it defaults to `/` (production).

## CI/CD Integration

In your CI/CD pipeline:

- For the `tejaswiniIBM/meta` repository, use: `npm run build:dev`
- For the `zopencommunity/meta` repository, use: `npm run build:prod`

This ensures the correct base path is used automatically based on which repository is being deployed.
