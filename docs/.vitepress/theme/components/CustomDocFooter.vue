<script setup lang="ts">
import { computed } from "vue";
import { useData } from "vitepress";

const { theme, page, frontmatter } = useData();

const editLink = computed(() => {
  const { text = "Edit this page", pattern = "" } = theme.value.editLink || {};

  let url: string;
  if (typeof pattern === "function") {
    url = pattern({ relativePath: page.value.relativePath });
  } else {
    url = pattern.replace(/:path/g, page.value.filePath);
  }

  return {
    url,
    text,
  };
});

const showEditLink = computed(() => {
  return frontmatter.value.editLink !== false && editLink.value.url;
});
</script>

<template>
  <div v-if="showEditLink" class="sidebar-edit-link">
    <a
      :href="editLink.url"
      target="_blank"
      rel="noopener noreferrer"
      class="edit-link-button"
    >
      <span class="vpi-square-pen edit-icon" />
      {{ editLink.text }}
    </a>
  </div>
</template>

<style scoped>
/* Hide on desktop, show only on mobile */
.sidebar-edit-link {
  display: none;
}

@media (max-width: 768px) {
  .sidebar-edit-link {
    display: block;
    padding: 12px 0;
    margin-top: 8px;
    border-top: 1px solid var(--vp-c-divider);
  }

  .edit-link-button {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    font-size: 14px;
    font-weight: 500;
    color: var(--vp-c-brand-1);
    text-decoration: none;
    border-radius: 8px;
    transition: all 0.25s;
    width: 100%;
    justify-content: center;
  }

  .edit-link-button:hover {
    background-color: var(--vp-c-brand-soft);
    color: var(--vp-c-brand-1);
  }

  .edit-icon {
    width: 16px;
    height: 16px;
  }
}
</style>
