# Migration from Docsify to VitePress

This document outlines the migration from Docsify to VitePress for the zopen community documentation.

## What Changed

### 1. Documentation Framework
- **Before**: Docsify (runtime-based documentation generator)
- **After**: VitePress (static site generator built on Vite and Vue 3)

### 2. Configuration
- **Before**: Configuration in `index.html` with JavaScript
- **After**: Configuration in `.vitepress/config.mts` with TypeScript

### 3. File Structure
```
docs/
├── .vitepress/
│   ├── config.mts              # Main configuration file
│   ├── theme/
│   │   ├── index.ts            # Theme customization
│   │   ├── custom.css          # Custom styles
│   │   ├── vue-shim.d.ts       # TypeScript declarations
│   │   └── components/
│   │       └── ToolFilters.vue  # Custom search component
│   └── docsify-backup/         # Backup of old Docsify files
│       ├── index.html
│       ├── _sidebar.md
│       └── styles.css
├── Guides/                     # Documentation content (unchanged)
├── reference/                  # Reference docs (unchanged)
├── images/                     # Images (unchanged)
└── README.md                   # Homepage (unchanged)
```

### 4. Scripts (package.json)
- **Before**:
  - `npm run serve` - Start Docsify dev server
  - `npm run update-sidebar` - Update sidebar
  
- **After**:
  - `npm run docs:dev` or `npm run serve` - Start VitePress dev server
  - `npm run docs:build` or `npm run build` - Build static site
  - `npm run docs:preview` - Preview built site

## Key Features Migrated

### ✅ Successfully Migrated
1. **Navigation & Sidebar**: Converted from `_sidebar.md` to VitePress sidebar configuration
2. **Search**: Using VitePress built-in local search (replaces Docsify search plugin)
3. **Dark Mode**: VitePress has built-in dark mode support
4. **Edit on GitHub**: Configured via `editLink` in config
5. **Custom Styling**: Migrated to `.vitepress/theme/custom.css`
6. **Tool Search Component**: Recreated as Vue component
7. **Footer**: Configured in theme config
8. **Social Links**: GitHub, LinkedIn, Discord links in navbar

### 📝 Notes on Changes
1. **URLs**: VitePress uses clean URLs by default (no `.html` extension)
2. **Markdown**: VitePress uses enhanced markdown with Vue component support
3. **Performance**: VitePress generates static HTML, resulting in faster load times
4. **SEO**: Better SEO with pre-rendered static pages
5. **TypeScript**: Configuration uses TypeScript for better type safety

## Running the Site

### Development
```bash
npm run docs:dev
# or
npm run serve
```
Visit: http://localhost:5173/

### Build for Production
```bash
npm run docs:build
# or
npm run build
```
Output directory: `.vitepress/dist/`

### Preview Production Build
```bash
npm run docs:preview
```

## Deployment

### GitHub Pages
VitePress builds to `.vitepress/dist/`. Update your deployment workflow to:
1. Run `npm run docs:build`
2. Deploy the `.vitepress/dist/` directory

### Example GitHub Actions Workflow
```yaml
name: Deploy VitePress site to Pages

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run docs:build
      - uses: actions/upload-pages-artifact@v2
        with:
          path: docs/.vitepress/dist
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/deploy-pages@v2
        id: deployment
```

## Customization

### Adding Custom Components
1. Create component in `.vitepress/theme/components/`
2. Register in `.vitepress/theme/index.ts`:
```typescript
import MyComponent from './components/MyComponent.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('MyComponent', MyComponent)
  }
}
```

### Modifying Styles
Edit `.vitepress/theme/custom.css` to customize:
- Colors (CSS variables)
- Layout
- Component styles

### Configuration Options
See `.vitepress/config.mts` for all available options. Refer to [VitePress documentation](https://vitepress.dev/reference/site-config) for details.

## Troubleshooting

### Issue: Links not working
- Ensure markdown links don't include `.md` extension
- VitePress automatically handles `.md` to clean URLs

### Issue: Images not loading
- Check image paths are relative to the markdown file
- Images in `/images/` should work as before

### Issue: Custom scripts not working
- Convert JavaScript to Vue components
- Use VitePress lifecycle hooks in theme

## Rollback Plan

If you need to rollback to Docsify:
1. Restore files from `.vitepress/docsify-backup/`
2. Reinstall Docsify dependencies:
   ```bash
   npm install docsify-cli docsify-tools
   ```
3. Update package.json scripts back to Docsify commands

## Resources

- [VitePress Documentation](https://vitepress.dev/)
- [VitePress GitHub](https://github.com/vuejs/vitepress)
- [Migration Guide](https://vitepress.dev/guide/migration-from-vitepress-0)
- [Theme Customization](https://vitepress.dev/guide/custom-theme)

## Benefits of VitePress

1. **Performance**: Static site generation for faster load times
2. **Modern Stack**: Built on Vite and Vue 3
3. **Better SEO**: Pre-rendered HTML pages
4. **TypeScript Support**: Type-safe configuration
5. **Hot Module Replacement**: Faster development experience
6. **Built-in Features**: Search, dark mode, i18n support
7. **Active Development**: Regular updates and improvements

## Support

For issues or questions about the migration:
- Open an issue on [GitHub](https://github.com/zopencommunity/meta/issues)
- Join discussions on [Discord](https://discord.com/invite/sze)