import DefaultTheme from 'vitepress/theme'
import './custom.css'
import type { Theme } from 'vitepress'
import ToolSearch from './components/ToolSearch.vue'
import CategoryFilter from './components/CategoryFilter.vue'
import ToolFilters from './components/ToolFilters.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app, router, siteData }) {
    // Register global components
    app.component('ToolSearch', ToolSearch)
    app.component('CategoryFilter', CategoryFilter)
    app.component('ToolFilters', ToolFilters)
  }
} satisfies Theme

// Made with Bob
