import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "zopen community",
  description: "Open Source for z/OS",
  head: [
    ['link', { rel: 'icon', type: 'image/png', href: '/images/zopen-community_icon.png' }],
    ['script', {}, `
    function liveSearchTools() {
      const input = document.getElementById('toolSearchInput');
      if (!input) return;
      const filterText = input.value.toLowerCase().trim();
      const allToolItems = document.querySelectorAll('.tool-item-filterable');
      const categoryContainers = document.querySelectorAll('.table-category');
      const noResultsEl = document.getElementById('toolNoResultsMessage');
      let visibleCount = 0;
      const displayedPackageNames = new Set();
      if (filterText !== "") {
        allToolItems.forEach((item, index) => {
          const packageName = item.dataset.packageName || "N/A_PKG_NAME";
          const rawSearchableAttr = item.dataset.searchableText;
          const processedSearchableText = rawSearchableAttr ? rawSearchableAttr.toLowerCase().trim() : '';
          let isMatch = processedSearchableText.includes(filterText);
          if (isMatch) {
            if (packageName !== "N/A_PKG_NAME" && !displayedPackageNames.has(packageName)) {
              item.style.display = ""; 
              displayedPackageNames.add(packageName);
              visibleCount++;
            } else {
              item.style.display = "none"; 
            }
          } else {
            item.style.display = "none";
          }
        });
        categoryContainers.forEach(container => {
          const visibleChildrenInContainer = container.querySelectorAll('.tool-item-filterable:not([style*="display: none"])');
          container.style.display = visibleChildrenInContainer.length > 0 ? "" : "none";
        });
      } else {
        allToolItems.forEach(item => { item.style.display = ""; });
        categoryContainers.forEach(container => { container.style.display = ""; });
        if (typeof filterTable === "function") filterTable(); 
      }
      if (noResultsEl) noResultsEl.style.display = (filterText !== "" && visibleCount === 0) ? "block" : "none";
    }
    function filterTable() {
      const selectedCategory = document.getElementById("category-filter").value;
      const categories = document.querySelectorAll(".table-category");
      categories.forEach((category) => {
        if (selectedCategory === "All" || category.dataset.category === selectedCategory) {
          category.style.display = "block";
        } else {
          category.style.display = "none";
        }
      });
    }
    // Need to re-attach listener after navigation in VitePress
    document.addEventListener('input', (e) => {
      if (e.target.id === 'toolSearchInput') liveSearchTools();
    });
    `]
  ],
  themeConfig: {
    logo: '/images/zopen-community_icon.png',
    nav: [
      { text: 'Getting Started', link: '/Guides/QuickStart' },
      { text: 'Tools', link: '/Latest' },
      { text: 'Reference', link: '/reference/zopen-reference' },
    ],
    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'Introduction', link: '/Guides/QuickStart' },
          { text: 'Prerequisites', link: '/Guides/Pre-req' },
          { text: 'The package manager', link: '/Guides/ThePackageManager' },
          { text: 'Developing tools', link: '/Guides/developing' },
          { text: 'Recommended tools', link: '/Guides/recommended' },
          { text: 'Usage Analytics', link: '/Guides/Analytics' },
          { text: 'Updating the Docs', link: '/UpdateDocs' },
        ]
      },
      {
        text: 'Available Tools and Libraries',
        items: [
          { text: 'Ports List', link: '/Latest' },
          { text: 'Newly Released Packages', link: '/newly_released' },
          { text: 'Package Vulnerabilities', link: '/Vulnerabilities' },
          {
            text: 'Status',
            collapsed: true,
            items: [
              { text: 'Overall Status', link: '/Progress' },
              { text: 'Currency', link: '/updatestatus' },
              { text: 'Upstreaming', link: '/upstreamstatus' },
            ]
          },
          { text: 'Usage Stats', link: 'https://usage.zopen.community' },
          { text: 'CICD Pipeline', link: '/Guides/Testing' },
        ]
      },
      {
        text: 'Reference',
        items: [
          { text: 'zopen', link: '/reference/zopen-reference' },
        ]
      },
      {
        text: 'Contributing',
        items: [
          { text: 'Porting guide', link: '/Guides/Porting' },
          { text: 'Leveraging the zoslib library', link: '/Guides/Zoslib' },
          { text: 'Troubleshooting', link: '/Guides/CommonSolutions' },
          { text: 'Getting z/OS Access', link: 'https://community.ibm.com/zsystems/form/zos-program/' },
        ]
      },
      { text: 'Badges', link: '/Badges' },
      { text: 'FAQ', link: '/Guides/FAQ' },
      {
        text: 'Workshops',
        items: [
          { text: 'Beginner', link: '/workshop/workshop' },
        ]
      },
      {
        text: 'Resources',
        items: [
          { text: 'Discussions', link: 'https://github.com/zopencommunity/meta/discussions' },
          { text: 'Guild Meetings', link: 'https://github.com/zopencommunity/meta/discussions/categories/guild' },
          { text: 'Guild Meetings By Topics', link: '/Guides/ToolsGuildMeetingLinks' },
          { text: 'External Blogs', link: '/Guides/blogs' },
        ]
      },
      {
        text: 'Articles',
        items: [
          { text: 'Using GPG on z/OS', link: '/Guides/GpgOnZOS' },
          { text: 'Using Git on z/OS', link: '/Guides/GitOnZOS' },
          { text: 'Using Vim on z/OS', link: '/Guides/VimOnZOS' },
          { text: 'Using Bash on z/OS', link: '/Guides/BashOnZOS' },
          { text: 'Using Neovim on z/OS', link: '/Guides/NeovimOnZOS' },
          { text: 'Terminal Settings on z/OS', link: '/Guides/TerminalOnZOS' },
        ]
      },
      { text: 'Meet the Team', link: '/team' },
      { text: 'Success Stories', link: '/SuccessStories' },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/zopencommunity' },
      { icon: 'linkedin', link: 'https://www.linkedin.com/groups/9588308/' },
      { icon: 'discord', link: 'https://discord.com/invite/sze' }
    ],
    editLink: {
      pattern: 'https://github.com/zopencommunity/meta/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    },
    footer: {
      message: 'Copyright © zopen community a Series of LF Projects, LLC. For website terms of use, trademark policy, and other project policies, please see <a href="https://lfprojects.org" target="_blank">https://lfprojects.org</a>.',
      copyright: 'Copyright © zopen community'
    },
    search: {
      provider: 'local'
    }
  }
})
