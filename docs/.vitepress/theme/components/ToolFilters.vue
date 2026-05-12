<template>
  <div class="tool-filters-container">
    <div class="filters-row">
      <div class="category-filter">
        <label for="category-filter">Category: </label>
        <select
          id="category-filter"
          v-model="selectedCategory"
          @change="applyFilters"
          class="category-select"
        >
          <option value="All">All</option>
          <option value="ai">Ai</option>
          <option value="build_system">Build_System</option>
          <option value="compression">Compression</option>
          <option value="core">Core</option>
          <option value="database">Database</option>
          <option value="development">Development</option>
          <option value="devops">Devops</option>
          <option value="documentation">Documentation</option>
          <option value="editor">Editor</option>
          <option value="graphics">Graphics</option>
          <option value="json">Json</option>
          <option value="language">Language</option>
          <option value="library">Library</option>
          <option value="math">Math</option>
          <option value="monitoring">Monitoring</option>
          <option value="networking">Networking</option>
          <option value="security">Security</option>
          <option value="shell">Shell</option>
          <option value="source_control">Source_Control</option>
          <option value="testing">Testing</option>
          <option value="uncategorized">Uncategorized</option>
          <option value="utilities">Utilities</option>
          <option value="webframework">Webframework</option>
        </select>
      </div>

      <div class="search-filter">
        <input
          id="toolSearchInput"
          v-model="searchText"
          type="text"
          placeholder="Search tools..."
          class="tool-search-input"
          @input="applyFilters"
        />
      </div>
    </div>

    <div v-if="searchText && visibleCount === 0" class="no-results">
      No tools found matching your search.
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";

const searchText = ref("");
const selectedCategory = ref("All");
const visibleCount = ref(0);

const applyFilters = () => {
  const filterText = searchText.value.toLowerCase().trim();
  const categoryValue = selectedCategory.value.toLowerCase();
  const allToolItems = document.querySelectorAll(".tool-item-filterable");
  const categoryContainers = document.querySelectorAll(".table-category");

  let count = 0;

  // First pass: determine which categories are visible based on category filter
  const visibleCategories = new Set<string>();
  categoryContainers.forEach((container) => {
    const element = container as HTMLElement;
    const containerCategory = element.dataset.category || "";
    if (
      categoryValue === "all" ||
      containerCategory.toLowerCase() === categoryValue
    ) {
      visibleCategories.add(containerCategory);
    }
  });

  // Second pass: apply search filter with category-aware de-duplication
  if (filterText !== "") {
    // Track displayed packages per category
    const displayedPackagesPerCategory = new Map<string, Set<string>>();

    allToolItems.forEach((item) => {
      const element = item as HTMLElement;
      const packageName = element.dataset.packageName || "N/A_PKG_NAME";
      const rawSearchableAttr = element.dataset.searchableText;
      const processedSearchableText = rawSearchableAttr
        ? rawSearchableAttr.toLowerCase().trim()
        : "";

      // Find the parent category container
      const parentCategory = element.closest(".table-category") as HTMLElement;
      const itemCategory = parentCategory?.dataset.category || "";

      let isMatch = false;
      if (processedSearchableText && filterText) {
        isMatch = processedSearchableText.includes(filterText);
      }

      if (isMatch && visibleCategories.has(itemCategory)) {
        // Only apply de-duplication within visible categories
        if (packageName !== "N/A_PKG_NAME") {
          if (!displayedPackagesPerCategory.has(itemCategory)) {
            displayedPackagesPerCategory.set(itemCategory, new Set<string>());
          }
          const categorySet = displayedPackagesPerCategory.get(itemCategory)!;

          if (!categorySet.has(packageName)) {
            element.style.display = "";
            categorySet.add(packageName);
            count++;
          } else {
            element.style.display = "none";
          }
        } else {
          element.style.display = "";
          count++;
        }
      } else {
        element.style.display = "none";
      }
    });
  } else {
    // No search text - show all items
    allToolItems.forEach((item) => {
      (item as HTMLElement).style.display = "";
    });
  }

  // Third pass: show/hide category containers based on visibility and content
  categoryContainers.forEach((container) => {
    const element = container as HTMLElement;
    const containerCategory = element.dataset.category || "";

    if (filterText !== "") {
      // When searching, only show categories that have visible items
      const visibleChildrenInContainer = element.querySelectorAll(
        '.tool-item-filterable:not([style*="display: none"])',
      );

      if (
        visibleChildrenInContainer.length > 0 &&
        visibleCategories.has(containerCategory)
      ) {
        element.style.display = "";
      } else {
        element.style.display = "none";
      }
    } else {
      // No search text - respect category filter only
      if (visibleCategories.has(containerCategory)) {
        element.style.display = "";
      } else {
        element.style.display = "none";
      }
    }
  });

  visibleCount.value = count;
};

onMounted(() => {
  applyFilters();
});
</script>

<style scoped>
.tool-filters-container {
  margin: 20px 0;
}

.filters-row {
  display: flex;
  gap: 15px;
  align-items: center;
  flex-wrap: wrap;
}

.category-filter {
  display: flex;
  align-items: center;
  gap: 10px;
}

.category-filter label {
  font-weight: 500;
  color: var(--vp-c-text-1);
  white-space: nowrap;
}

.category-select {
  padding: 8px 12px;
  font-size: 14px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background-color: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  cursor: pointer;
  transition: border-color 0.2s;
  min-width: 180px;
}

.category-select:focus {
  outline: none;
  border-color: var(--vp-c-brand);
}

.category-select:hover {
  border-color: var(--vp-c-brand-light);
}

.search-filter {
  flex: 1;
  min-width: 250px;
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

@media (max-width: 640px) {
  .filters-row {
    flex-direction: column;
    align-items: stretch;
  }

  .category-filter {
    width: 100%;
  }

  .category-select {
    flex: 1;
  }

  .search-filter {
    width: 100%;
  }

  .tool-search-input {
    max-width: 100%;
  }
}
</style>
