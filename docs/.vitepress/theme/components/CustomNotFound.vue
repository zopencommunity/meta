<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { withBase, useRoute, useData } from 'vitepress'

const route = useRoute()
const { theme, site } = useData()

const browserPath = ref('')

onMounted(() => {
  if (typeof window !== 'undefined') {
    browserPath.value = window.location.pathname
  }
})

// Determine path either from route or browser location
const normalizedPath = computed(() => {
  let p = route.path || browserPath.value || ''
  if (typeof window !== 'undefined' && (!p || p === '/' || p === '/404.html')) {
    p = window.location.pathname
  }
  const base = site.value?.base || '/'
  if (base !== '/' && p.startsWith(base)) {
    p = '/' + p.slice(base.length)
  }
  return p
})

interface DynamicDocInfo {
  name: string
  file: string
  description: string
}

const dynamicDoc = computed<DynamicDocInfo | null>(() => {
  const p = normalizedPath.value.replace(/\.html$/, '').replace(/\/$/, '') || '/'

  if (/^\/latest$/i.test(p)) {
    return {
      name: 'All Tools',
      file: 'docs/Latest.md',
      description: 'The directory of all ported tools and packages for z/OS.'
    }
  }
  if (/^\/progress$/i.test(p)) {
    return {
      name: 'Overall Status & Porting Progress',
      file: 'docs/Progress.md',
      description: 'Porting status, active work, and completion progress metrics.'
    }
  }
  if (/^\/updatestatus$/i.test(p)) {
    return {
      name: 'Currency Status',
      file: 'docs/updatestatus.md',
      description: 'Status of upstream version bumps and package currency.'
    }
  }
  if (/^\/upstreamstatus$/i.test(p)) {
    return {
      name: 'Upstream Status & Patch Trends',
      file: 'docs/upstreamstatus.md',
      description: 'Upstream patch health and historical trend charts.'
    }
  }
  if (/^\/newly_released$/i.test(p)) {
    return {
      name: 'Newly Released Packages',
      file: 'docs/newly_released.md',
      description: 'Recent releases and package updates.'
    }
  }
  if (/^\/vulnerabilities$/i.test(p)) {
    return {
      name: 'Package Vulnerabilities',
      file: 'docs/Vulnerabilities.md',
      description: 'Vulnerability advisories and package audit feed.'
    }
  }
  if (/^\/reference(\/.*)?$/i.test(p)) {
    return {
      name: 'Command Reference & Manuals',
      file: 'docs/reference/*.md',
      description: 'Generated man pages and zopen CLI reference documentation.'
    }
  }

  return null
})

const copied = ref(false)
async function copyCommand(cmd: string) {
  if (typeof navigator !== 'undefined' && navigator.clipboard) {
    try {
      await navigator.clipboard.writeText(cmd)
      copied.value = true
      setTimeout(() => {
        copied.value = false
      }, 2000)
    } catch {
      // ignore
    }
  }
}

function refreshPage() {
  if (typeof window !== 'undefined') {
    window.location.reload()
  }
}
</script>

<template>
  <div class="NotFound">
    <!-- View when accessing an unbuilt dynamic page -->
    <div v-if="dynamicDoc" class="dynamic-container">
      <div class="badge-wrapper">
        <span class="dynamic-badge">DYNAMIC DOCUMENTATION</span>
      </div>

      <h1 class="heading">Page Not Generated Yet</h1>

      <p class="description">
        <strong>{{ dynamicDoc.name }}</strong> (<code>{{ normalizedPath }}</code>) is dynamically compiled from repository data and is not stored in git.
      </p>

      <div class="instruction-box">
        <div class="instruction-header">
          <span>Run this in your project root to generate dynamic pages:</span>
        </div>
        <div class="code-block" @click="copyCommand('npm run docs:generate')">
          <code>npm run docs:generate</code>
          <button class="copy-btn" type="button" :title="copied ? 'Copied!' : 'Copy command'">
            {{ copied ? '✓ Copied' : 'Copy' }}
          </button>
        </div>
        <p class="instruction-alt">
          or directly: <code>./cicd/generate_docs.sh</code>
        </p>
      </div>

      <p class="hint">
        💡 Requires Python with dependencies installed (<code>pip install -r requirements.txt</code>).<br />
        In CI/CD, this step runs automatically before deploying to GitHub Pages.
      </p>

      <div class="action-buttons">
        <button class="primary-btn" type="button" @click="refreshPage">
          Refresh Page
        </button>
        <a class="secondary-btn" :href="withBase('/')">
          Take Me Home
        </a>
      </div>
    </div>

    <!-- Standard 404 view for all other non-existent routes -->
    <div v-else>
      <p class="code">{{ theme.notFound?.code ?? '404' }}</p>
      <h1 class="title">{{ theme.notFound?.title ?? 'PAGE NOT FOUND' }}</h1>
      <div class="divider" />
      <blockquote class="quote">
        {{
          theme.notFound?.quote ??
          "But if you don't change your direction, and if you keep looking, you may end up where you are heading."
        }}
      </blockquote>

      <div class="action">
        <a
          class="link"
          :href="withBase('/')"
          :aria-label="theme.notFound?.linkLabel ?? 'go to home'"
        >
          {{ theme.notFound?.linkText ?? 'Take me home' }}
        </a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.NotFound {
  padding: 64px 24px 96px;
  text-align: center;
}

@media (min-width: 768px) {
  .NotFound {
    padding: 80px 32px 140px;
  }
}

/* Dynamic unbuilt page styles */
.dynamic-container {
  max-width: 640px;
  margin: 0 auto;
}

.badge-wrapper {
  margin-bottom: 16px;
}

.dynamic-badge {
  display: inline-block;
  padding: 4px 12px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.8px;
  text-transform: uppercase;
  color: var(--vp-c-brand-1, #3eaf7c);
  background-color: var(--vp-c-brand-soft, rgba(62, 175, 124, 0.14));
  border: 1px solid var(--vp-c-brand-1, #3eaf7c);
  border-radius: 9999px;
}

.heading {
  font-size: 28px;
  font-weight: 700;
  line-height: 1.3;
  margin-bottom: 12px;
  color: var(--vp-c-text-1);
}

@media (min-width: 640px) {
  .heading {
    font-size: 34px;
  }
}

.description {
  font-size: 16px;
  color: var(--vp-c-text-2);
  margin-bottom: 24px;
  line-height: 1.6;
}

.description code {
  padding: 2px 6px;
  font-size: 14px;
  background-color: var(--vp-c-bg-mute);
  border-radius: 4px;
  color: var(--vp-c-brand-1, #3eaf7c);
}

.instruction-box {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  text-align: left;
}

.instruction-header {
  font-size: 14px;
  font-weight: 500;
  color: var(--vp-c-text-2);
  margin-bottom: 10px;
}

.code-block {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--vp-c-bg-alt);
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  padding: 10px 14px;
  font-family: var(--vp-font-family-mono);
  font-size: 14px;
  cursor: pointer;
  transition: border-color 0.2s;
}

.code-block:hover {
  border-color: var(--vp-c-brand-1, #3eaf7c);
}

.code-block code {
  color: var(--vp-c-brand-1, #3eaf7c);
  font-weight: 600;
}

.copy-btn {
  font-size: 12px;
  font-weight: 500;
  padding: 4px 10px;
  border-radius: 4px;
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  color: var(--vp-c-text-2);
  cursor: pointer;
  transition: all 0.2s;
}

.copy-btn:hover {
  border-color: var(--vp-c-brand-1, #3eaf7c);
  color: var(--vp-c-brand-1, #3eaf7c);
}

.instruction-alt {
  margin-top: 12px;
  margin-bottom: 0;
  font-size: 13px;
  color: var(--vp-c-text-3);
}

.instruction-alt code {
  padding: 1px 4px;
  font-size: 12px;
  background-color: var(--vp-c-bg-mute);
  border-radius: 4px;
}

.hint {
  font-size: 13px;
  color: var(--vp-c-text-3);
  line-height: 1.6;
  margin-bottom: 28px;
}

.hint code {
  font-size: 12px;
  padding: 1px 4px;
  background-color: var(--vp-c-bg-mute);
  border-radius: 4px;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}

.primary-btn {
  display: inline-block;
  background-color: var(--vp-c-brand-1, #3eaf7c);
  color: #fff;
  border: 1px solid var(--vp-c-brand-1, #3eaf7c);
  border-radius: 20px;
  padding: 8px 22px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.25s, border-color 0.25s;
}

.primary-btn:hover {
  background-color: var(--vp-c-brand-2, #33a06f);
  border-color: var(--vp-c-brand-2, #33a06f);
}

.secondary-btn {
  display: inline-block;
  border: 1px solid var(--vp-c-divider);
  border-radius: 20px;
  padding: 8px 22px;
  font-size: 14px;
  font-weight: 500;
  color: var(--vp-c-text-1);
  background: var(--vp-c-bg-alt);
  transition: border-color 0.25s, color 0.25s;
}

.secondary-btn:hover {
  border-color: var(--vp-c-brand-1, #3eaf7c);
  color: var(--vp-c-brand-1, #3eaf7c);
}

/* Default 404 styles */
.code {
  line-height: 64px;
  font-size: 64px;
  font-weight: 600;
}

.title {
  padding-top: 12px;
  letter-spacing: 2px;
  line-height: 20px;
  font-size: 20px;
  font-weight: 700;
}

.divider {
  margin: 24px auto 18px;
  width: 64px;
  height: 1px;
  background-color: var(--vp-c-divider);
}

.quote {
  margin: 0 auto;
  max-width: 256px;
  font-size: 14px;
  font-weight: 500;
  color: var(--vp-c-text-2);
}

.action {
  padding-top: 20px;
}

.link {
  display: inline-block;
  border: 1px solid var(--vp-c-brand-1, #3eaf7c);
  border-radius: 16px;
  padding: 3px 16px;
  font-size: 14px;
  font-weight: 500;
  color: var(--vp-c-brand-1, #3eaf7c);
  transition: border-color 0.25s, color 0.25s;
}

.link:hover {
  border-color: var(--vp-c-brand-2, #33a06f);
  color: var(--vp-c-brand-2, #33a06f);
}
</style>
