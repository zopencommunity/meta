import DefaultTheme from 'vitepress/theme'
import './custom.css'
import type { Theme } from 'vitepress'
import ToolSearch from './components/ToolSearch.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app, router, siteData }) {
    // Register global components
    app.component('ToolSearch', ToolSearch)
  }
} satisfies Theme

// Made with Bob
