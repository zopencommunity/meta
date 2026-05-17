<template>
  <div
    v-if="showEditLink"
    class="mobile-edit-link-wrapper"
    :class="{ scrolled: isScrolled }"
  >
    <a
      :href="editUrl"
      class="mobile-edit-link"
      target="_blank"
      rel="noopener noreferrer"
    >
      <span class="vpi-square-pen edit-icon"></span>
      {{ editText }}
    </a>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from "vue";
import { useData } from "vitepress";

const { theme, page } = useData();
const isScrolled = ref(false);

const showEditLink = computed(() => {
  if (typeof window === "undefined") return false;
  if (window.innerWidth > 768) return false;
  if (!theme.value.editLink) return false;
  if (page.value.frontmatter?.editLink === false) return false;
  return true;
});

const editUrl = computed(() => {
  const editLinkConfig = theme.value.editLink;
  if (!editLinkConfig) return "";

  if (typeof editLinkConfig.pattern === "function") {
    return editLinkConfig.pattern({ relativePath: page.value.relativePath });
  } else if (typeof editLinkConfig.pattern === "string") {
    return editLinkConfig.pattern.replace(/:path/g, page.value.filePath);
  }
  return "";
});

const editText = computed(() => {
  return theme.value.editLink?.text || "Edit this page";
});

const handleScroll = () => {
  isScrolled.value = window.scrollY > 50;
};

onMounted(() => {
  window.addEventListener("scroll", handleScroll);
  handleScroll();
});

onUnmounted(() => {
  window.removeEventListener("scroll", handleScroll);
});
</script>
