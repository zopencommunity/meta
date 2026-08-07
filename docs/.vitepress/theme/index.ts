import DefaultTheme from 'vitepress/theme'
import './custom.css'
import type { Theme } from 'vitepress'
import ToolFilters from './components/ToolFilters.vue'
import PackageRequests from './components/PackageRequests.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app, router, siteData }) {
    // Register global components
    app.component('ToolFilters', ToolFilters)
    app.component('PackageRequests', PackageRequests)
  }
} satisfies Theme

// Made with Bob
