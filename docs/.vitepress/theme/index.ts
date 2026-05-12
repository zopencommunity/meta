import DefaultTheme from 'vitepress/theme'
import './custom.css'
import type { Theme } from 'vitepress'
import ToolFilters from './components/ToolFilters.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app, router, siteData }) {
    // Register global components
    app.component('ToolFilters', ToolFilters)
  }
} satisfies Theme

// Made with Bob
