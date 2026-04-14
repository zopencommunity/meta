<template>
  <div class="tool-search-container">
    <input
      id="toolSearchInput"
      v-model="searchText"
      type="text"
      placeholder="Search tools..."
      class="tool-search-input"
      @input="handleSearch"
    />
    <div v-if="searchText && visibleCount === 0" id="toolNoResultsMessage" class="no-results">
      No tools found matching your search.
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const searchText = ref('')
const visibleCount = ref(0)

const handleSearch = () => {
  const filterText = searchText.value.toLowerCase().trim()
  const allToolItems = document.querySelectorAll('.tool-item-filterable')
  const categoryContainers = document.querySelectorAll('.table-category')
  
  let count = 0
  const displayedPackageNames = new Set<string>()

  if (filterText !== '') {
    allToolItems.forEach((item) => {
      const element = item as HTMLElement
      const packageName = element.dataset.packageName || 'N/A_PKG_NAME'
      const rawSearchableAttr = element.dataset.searchableText
      const processedSearchableText = rawSearchableAttr ? rawSearchableAttr.toLowerCase().trim() : ''
      
      let isMatch = false
      if (processedSearchableText && filterText) {
        isMatch = processedSearchableText.includes(filterText)
      }

      if (isMatch) {
        if (packageName !== 'N/A_PKG_NAME' && !displayedPackageNames.has(packageName)) {
          element.style.display = ''
          displayedPackageNames.add(packageName)
          count++
        } else if (packageName !== 'N/A_PKG_NAME' && displayedPackageNames.has(packageName)) {
          element.style.display = 'none'
        } else {
          element.style.display = ''
          count++
        }
      } else {
        element.style.display = 'none'
      }
    })

    categoryContainers.forEach((container) => {
      const element = container as HTMLElement
      const visibleChildrenInContainer = element.querySelectorAll('.tool-item-filterable:not([style*="display: none"])')
      
      if (visibleChildrenInContainer.length > 0) {
        element.style.display = ''
      } else {
        element.style.display = 'none'
      }
    })
  } else {
    allToolItems.forEach((item) => {
      (item as HTMLElement).style.display = ''
    })
    categoryContainers.forEach((container) => {
      (container as HTMLElement).style.display = ''
    })
  }

  visibleCount.value = count
}

onMounted(() => {
  handleSearch()
})
</script>

<style scoped>
.tool-search-container {
  margin: 20px 0;
}

.tool-search-input {
  width: 100%;
  max-width: 500px;
  padding: 10px 15px;
  font-size: 16px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background-color: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  transition: border-color 0.2s;
}

.tool-search-input:focus {
  outline: none;
  border-color: var(--vp-c-brand);
}

.no-results {
  margin-top: 10px;
  padding: 10px;
  color: var(--vp-c-text-2);
  font-style: italic;
}
</style>