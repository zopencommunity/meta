<script setup lang="ts">
import { computed, ref } from "vue";
import { withBase } from "vitepress";
import catalogData from "../../../api/python_packages.json";

interface PythonPackage {
  name: string;
  displayName: string;
  version: string;
  description: string;
  categories: string[];
  runtimeDependencies: string[];
  passedTests: number | null;
  totalTests: number | null;
  verificationRate: number | null;
  publishedAt: string;
  pythonVersions: string[];
  wheelCount: number;
  indexUrl: string;
  portRepositoryUrl: string;
  releaseUrl: string;
}

const catalog = catalogData as {
  generatedAt: string;
  wheelIndexUrl: string;
  supportedPythonVersions: string[];
  packageCount: number;
  wheelCount: number;
  packages: PythonPackage[];
};

const search = ref("");
const pythonVersion = ref("all");
const verification = ref("all");
type SortKey = "name" | "version" | "python" | "verification" | "recent";
type SortDirection = "asc" | "desc";
const sort = ref<SortKey>("recent");
const sortDirection = ref<SortDirection>("desc");
const copied = ref("");

const pipSetup = `export PIP_EXTRA_INDEX_URL="https://repo.zopen.community/pypi/wheels/simple/"
export PIP_CONSTRAINT="https://repo.zopen.community/pulp/content/constraints/zopen-constraints.txt"`;
const uvSetup = `export UV_INDEX="https://repo.zopen.community/pypi/wheels/simple/"
export UV_CONSTRAINT="https://repo.zopen.community/pulp/content/constraints/zopen-constraints.txt"`;

function verificationKind(pkg: PythonPackage) {
  if (pkg.passedTests === null || !pkg.totalTests) return "unreported";
  return pkg.passedTests === pkg.totalTests ? "passed" : "partial";
}

const filteredPackages = computed(() => {
  const query = search.value.trim().toLowerCase();
  const packages = catalog.packages.filter((pkg) => {
    const searchable = [
      pkg.name,
      pkg.displayName,
      pkg.description,
      ...pkg.categories,
      ...pkg.runtimeDependencies,
    ].join(" ").toLowerCase();
    return (!query || searchable.includes(query))
      && (pythonVersion.value === "all" || pkg.pythonVersions.includes(pythonVersion.value))
      && (verification.value === "all" || verificationKind(pkg) === verification.value);
  });
  return packages.sort((left, right) => {
    let comparison = 0;
    if (sort.value === "recent") {
      comparison = (left.publishedAt || "").localeCompare(right.publishedAt || "");
    } else if (sort.value === "verification") {
      comparison = (left.verificationRate ?? -1) - (right.verificationRate ?? -1)
        || (left.totalTests ?? -1) - (right.totalTests ?? -1);
    } else if (sort.value === "version") {
      comparison = (left.version || "").localeCompare(right.version || "", undefined, { numeric: true, sensitivity: "base" });
    } else if (sort.value === "python") {
      comparison = left.pythonVersions.length - right.pythonVersions.length
        || left.pythonVersions.join(".").localeCompare(right.pythonVersions.join("."), undefined, { numeric: true });
    } else {
      comparison = left.name.localeCompare(right.name);
    }
    return (sortDirection.value === "asc" ? comparison : -comparison)
      || left.name.localeCompare(right.name);
  });
});

function defaultDirection(key: SortKey): SortDirection {
  return key === "name" ? "asc" : "desc";
}

function changeSort(key: SortKey) {
  if (sort.value === key) {
    sortDirection.value = sortDirection.value === "asc" ? "desc" : "asc";
    return;
  }
  sort.value = key;
  sortDirection.value = defaultDirection(key);
}

function resetSortDirection() {
  sortDirection.value = defaultDirection(sort.value);
}

function ariaSort(key: SortKey): "ascending" | "descending" | undefined {
  if (sort.value !== key) return undefined;
  return sortDirection.value === "asc" ? "ascending" : "descending";
}

function sortIndicator(key: SortKey) {
  if (sort.value !== key) return "↕";
  return sortDirection.value === "asc" ? "↑" : "↓";
}

function displayDate(value: string) {
  if (!value) return "Not reported";
  const parsed = new Date(value);
  return Number.isNaN(parsed.valueOf())
    ? value
    : new Intl.DateTimeFormat(undefined, { year: "numeric", month: "short", day: "numeric" }).format(parsed);
}

function installCommand(pkg: PythonPackage, manager: "pip" | "uv") {
  return manager === "uv" ? `uv pip install ${pkg.name}` : `pip install ${pkg.name}`;
}

async function copyText(value: string, key: string) {
  try {
    await navigator.clipboard.writeText(value);
    copied.value = key;
    window.setTimeout(() => { if (copied.value === key) copied.value = ""; }, 1800);
  } catch {
    copied.value = "";
  }
}
</script>

<template>
  <div class="python-packages">
    <section class="catalog-intro">
      <div>
        <p class="eyebrow">Available now</p>
        <h1>Python packages for z/OS</h1>
        <p class="intro-copy">
          Browse wheels published by the zopen community, see which Python interpreters are covered,
          and review the latest reported port-verification results before installing.
        </p>
      </div>
      <div class="catalog-summary" aria-label="Catalogue summary">
        <div><strong>{{ catalog.packageCount }}</strong><span>packages</span></div>
        <div><strong>{{ catalog.wheelCount }}</strong><span>wheels</span></div>
        <div><strong>3.12–3.14</strong><span>Python</span></div>
      </div>
    </section>

    <aside class="verification-note">
      <strong>What “verification” means</strong>
      <span>
        Counts come from the latest zopen build metadata. They describe reported port checks—not complete
        upstream coverage, security certification, production readiness, or an IBM support commitment.
      </span>
    </aside>

    <details class="setup-panel">
      <summary>Configure pip or uv for the zopen wheel index</summary>
      <div class="setup-grid">
        <div>
          <div class="command-heading"><strong>pip</strong><button type="button" @click="copyText(pipSetup, 'pip-setup')">{{ copied === "pip-setup" ? "Copied" : "Copy setup" }}</button></div>
          <pre><code>{{ pipSetup }}</code></pre>
        </div>
        <div>
          <div class="command-heading"><strong>uv</strong><button type="button" @click="copyText(uvSetup, 'uv-setup')">{{ copied === "uv-setup" ? "Copied" : "Copy setup" }}</button></div>
          <pre><code>{{ uvSetup }}</code></pre>
        </div>
      </div>
      <p>See the <a :href="withBase('/Guides/PythonPackages')">installation guide</a> for virtual environments, constraints, caching, and verification.</p>
    </details>

    <section class="catalog-controls" aria-label="Package filters">
      <label class="search-control">
        <span>Search packages</span>
        <input v-model="search" type="search" placeholder="Name, description, category, dependency…" />
      </label>
      <label>
        <span>Python version</span>
        <select v-model="pythonVersion">
          <option value="all">All versions</option>
          <option v-for="version in catalog.supportedPythonVersions" :key="version" :value="version">Python {{ version }}</option>
        </select>
      </label>
      <label>
        <span>Verification</span>
        <select v-model="verification">
          <option value="all">All results</option>
          <option value="passed">All reported checks passed</option>
          <option value="partial">Some reported checks failed</option>
          <option value="unreported">Not reported</option>
        </select>
      </label>
      <label>
        <span>Sort by</span>
        <select v-model="sort" @change="resetSortDirection">
          <option value="recent">Recent additions</option>
          <option value="name">Package name</option>
          <option value="version">Version</option>
          <option value="python">Python coverage</option>
          <option value="verification">Verification result</option>
        </select>
      </label>
    </section>

    <div class="results-heading">
      <span><strong>{{ filteredPackages.length }}</strong> of {{ catalog.packageCount }} packages</span>
      <span>{{ sort === "recent" ? `${sortDirection === "desc" ? "Newest" : "Oldest"} zopen releases first` : `Catalogue refreshed ${displayDate(catalog.generatedAt)}` }}</span>
    </div>

    <div v-if="filteredPackages.length" class="package-table" role="table" aria-label="Available Python packages">
      <div class="package-header" role="row">
        <span role="columnheader" :aria-sort="ariaSort('name')"><button type="button" @click="changeSort('name')">Package <span aria-hidden="true">{{ sortIndicator('name') }}</span></button></span>
        <span role="columnheader" :aria-sort="ariaSort('version')"><button type="button" @click="changeSort('version')">Version <span aria-hidden="true">{{ sortIndicator('version') }}</span></button></span>
        <span role="columnheader" :aria-sort="ariaSort('python')"><button type="button" @click="changeSort('python')">Python <span aria-hidden="true">{{ sortIndicator('python') }}</span></button></span>
        <span role="columnheader" :aria-sort="ariaSort('verification')"><button type="button" @click="changeSort('verification')">Port verification <span aria-hidden="true">{{ sortIndicator('verification') }}</span></button></span>
        <span role="columnheader" :aria-sort="ariaSort('recent')"><button type="button" @click="changeSort('recent')">Latest release <span aria-hidden="true">{{ sortIndicator('recent') }}</span></button></span>
      </div>

      <details v-for="pkg in filteredPackages" :key="pkg.name" class="package-row">
        <summary>
          <span class="package-identity">
            <strong>{{ pkg.displayName || pkg.name }}</strong>
            <small>{{ pkg.description || "Python package published for z/OS" }}</small>
          </span>
          <span class="version-value" data-label="Version">{{ pkg.version || "Not reported" }}</span>
          <span class="python-badges" data-label="Python">
            <span v-for="version in pkg.pythonVersions" :key="version">{{ version }}</span>
            <small v-if="!pkg.pythonVersions.length">Not classified</small>
          </span>
          <span class="verification-value" :class="`verification-${verificationKind(pkg)}`" data-label="Port verification">
            <template v-if="pkg.passedTests !== null && pkg.totalTests">
              <strong>{{ pkg.passedTests }}/{{ pkg.totalTests }}</strong>
              <small>{{ pkg.verificationRate }}% reported checks</small>
            </template>
            <template v-else><strong>Not reported</strong><small>No check counts in latest metadata</small></template>
          </span>
          <span class="published-value" data-label="Latest release">{{ displayDate(pkg.publishedAt) }}</span>
        </summary>

        <div class="package-details">
          <div class="detail-metadata">
            <div><span>Categories</span><strong>{{ pkg.categories.length ? pkg.categories.join(", ") : "Not reported" }}</strong></div>
            <div><span>zopen dependencies</span><strong>{{ pkg.runtimeDependencies.length ? pkg.runtimeDependencies.join(", ") : "None reported" }}</strong></div>
            <div><span>Wheel artifacts</span><strong>{{ pkg.wheelCount }}</strong></div>
          </div>
          <div class="install-actions">
            <button type="button" @click="copyText(installCommand(pkg, 'pip'), `${pkg.name}-pip`)">{{ copied === `${pkg.name}-pip` ? "Copied" : `Copy pip install` }}</button>
            <button type="button" @click="copyText(installCommand(pkg, 'uv'), `${pkg.name}-uv`)">{{ copied === `${pkg.name}-uv` ? "Copied" : `Copy uv install` }}</button>
          </div>
          <div class="detail-links">
            <a :href="pkg.indexUrl" target="_blank" rel="noreferrer">Wheel index</a>
            <a :href="pkg.portRepositoryUrl" target="_blank" rel="noreferrer">Port repository</a>
            <a v-if="pkg.releaseUrl" :href="pkg.releaseUrl" target="_blank" rel="noreferrer">Latest release</a>
          </div>
        </div>
      </details>
    </div>

    <section v-else class="empty-state">
      <h2>No available package matches those filters</h2>
      <p>Try a broader search, or request the package if it is not yet available.</p>
      <a :href="`${withBase('/PackageRequests')}?package=${encodeURIComponent(search.trim())}`">Request this package</a>
    </section>

    <footer class="catalog-footer">
      <p>Can’t find what you need? <a :href="withBase('/PackageRequests')">Request a package or vote for an existing request</a>.</p>
      <p>Package consumers remain responsible for compatibility, licensing, provenance, security, and operational assessment under the <a :href="withBase('/Governance#consuming-packages')">zopen governance guidance</a>.</p>
    </footer>
  </div>
</template>

<style scoped>
.python-packages { color: var(--vp-c-text-1); }
.catalog-intro { display: grid; grid-template-columns: minmax(0, 1fr) auto; gap: 32px; align-items: end; padding: 10px 0 28px; }
.catalog-intro h1 { margin: 2px 0 12px; font-size: clamp(2rem, 4vw, 3.2rem); line-height: 1.05; letter-spacing: -0.035em; }
.eyebrow { margin: 0; color: var(--vp-c-brand-1); font-size: 0.78rem; font-weight: 750; letter-spacing: 0.12em; text-transform: uppercase; }
.intro-copy { max-width: 760px; margin: 0; color: var(--vp-c-text-2); font-size: 1.05rem; line-height: 1.65; }
.catalog-summary { display: grid; grid-template-columns: repeat(3, minmax(88px, 1fr)); overflow: hidden; border: 1px solid var(--vp-c-divider); border-radius: 14px; background: var(--vp-c-bg-soft); }
.catalog-summary div { display: flex; min-width: 104px; padding: 16px; flex-direction: column; text-align: center; }
.catalog-summary div + div { border-left: 1px solid var(--vp-c-divider); }
.catalog-summary strong { font-size: 1.3rem; }
.catalog-summary span { color: var(--vp-c-text-2); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.06em; }
.verification-note { display: grid; grid-template-columns: auto 1fr; gap: 16px; margin-bottom: 18px; padding: 14px 16px; border-left: 4px solid var(--vp-c-brand-1); border-radius: 8px; background: var(--vp-c-bg-soft); color: var(--vp-c-text-2); font-size: 0.9rem; }
.verification-note strong { color: var(--vp-c-text-1); white-space: nowrap; }
.setup-panel { margin-bottom: 22px; border: 1px solid var(--vp-c-divider); border-radius: 10px; background: var(--vp-c-bg); }
.setup-panel summary { padding: 14px 16px; cursor: pointer; font-weight: 700; }
.setup-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; padding: 0 16px; }
.setup-panel p { padding: 0 16px 14px; color: var(--vp-c-text-2); }
.command-heading { display: flex; align-items: center; justify-content: space-between; margin-bottom: 6px; }
.command-heading button, .install-actions button { border: 1px solid var(--vp-c-divider); border-radius: 7px; padding: 6px 10px; background: var(--vp-c-bg-soft); color: var(--vp-c-text-1); cursor: pointer; font-weight: 650; }
.setup-panel pre { margin: 0; padding: 12px; overflow-x: auto; border-radius: 8px; background: var(--vp-code-block-bg); font-size: 0.78rem; }
.catalog-controls { display: grid; grid-template-columns: minmax(240px, 1.6fr) repeat(3, minmax(150px, 0.7fr)); gap: 12px; padding: 16px; border: 1px solid var(--vp-c-divider); border-radius: 12px; background: var(--vp-c-bg-soft); }
.catalog-controls label { display: flex; flex-direction: column; gap: 6px; }
.catalog-controls label > span { color: var(--vp-c-text-2); font-size: 0.76rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em; }
.catalog-controls input, .catalog-controls select { width: 100%; min-height: 42px; padding: 8px 10px; border: 1px solid var(--vp-c-divider); border-radius: 8px; background: var(--vp-c-bg); color: var(--vp-c-text-1); font: inherit; }
.catalog-controls input:focus, .catalog-controls select:focus { outline: 2px solid var(--vp-c-brand-1); outline-offset: 1px; }
.results-heading { display: flex; justify-content: space-between; gap: 16px; padding: 18px 2px 10px; color: var(--vp-c-text-2); font-size: 0.82rem; }
.package-table { overflow: hidden; border: 1px solid var(--vp-c-divider); border-radius: 12px; }
.package-header, .package-row > summary { display: grid; grid-template-columns: minmax(230px, 2fr) minmax(95px, 0.65fr) minmax(150px, 0.9fr) minmax(175px, 1fr) minmax(110px, 0.75fr); gap: 16px; align-items: center; }
.package-header { padding: 11px 42px 11px 16px; background: var(--vp-c-bg-soft); color: var(--vp-c-text-2); font-size: 0.72rem; font-weight: 750; letter-spacing: 0.05em; text-transform: uppercase; }
.package-header button { display: inline-flex; gap: 5px; align-items: center; padding: 2px 0; border: 0; background: transparent; color: inherit; cursor: pointer; font: inherit; font-weight: inherit; letter-spacing: inherit; text-align: left; text-transform: inherit; }
.package-header button:hover { color: var(--vp-c-brand-1); }
.package-header button:focus-visible { border-radius: 3px; outline: 2px solid var(--vp-c-brand-1); outline-offset: 3px; }
.package-header button span { color: var(--vp-c-brand-1); font-size: 0.9rem; line-height: 1; }
.package-row { border-top: 1px solid var(--vp-c-divider); background: var(--vp-c-bg); }
.package-row:first-of-type { border-top: 0; }
.package-row > summary { padding: 15px 16px; cursor: pointer; list-style-position: outside; }
.package-row > summary:hover { background: var(--vp-c-bg-soft); }
.package-identity { display: flex; min-width: 0; flex-direction: column; gap: 3px; }
.package-identity strong { overflow-wrap: anywhere; font-size: 1rem; }
.package-identity small, .verification-value small, .python-badges small { color: var(--vp-c-text-3); font-size: 0.72rem; font-weight: 450; line-height: 1.35; }
.package-identity small { display: -webkit-box; overflow: hidden; -webkit-box-orient: vertical; -webkit-line-clamp: 2; }
.python-badges { display: flex; flex-wrap: wrap; gap: 5px; }
.python-badges > span { padding: 3px 7px; border-radius: 999px; background: var(--vp-c-brand-soft); color: var(--vp-c-brand-1); font-size: 0.72rem; font-weight: 750; }
.verification-value { display: flex; flex-direction: column; gap: 2px; }
.verification-passed > strong { color: var(--vp-c-brand-1); }
.verification-partial > strong { color: var(--vp-c-warning-1); }
.verification-unreported > strong { color: var(--vp-c-text-2); font-size: 0.85rem; }
.version-value, .published-value { font-size: 0.86rem; }
.package-details { padding: 0 16px 16px 38px; }
.detail-metadata { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; padding: 14px; border-radius: 9px; background: var(--vp-c-bg-soft); }
.detail-metadata div { display: flex; flex-direction: column; gap: 4px; }
.detail-metadata span { color: var(--vp-c-text-3); font-size: 0.7rem; font-weight: 700; text-transform: uppercase; }
.detail-metadata strong { overflow-wrap: anywhere; font-size: 0.85rem; }
.install-actions, .detail-links { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 12px; }
.install-actions button:hover { border-color: var(--vp-c-brand-1); color: var(--vp-c-brand-1); }
.detail-links a { font-size: 0.85rem; font-weight: 650; }
.empty-state { padding: 44px 20px; border: 1px dashed var(--vp-c-divider); border-radius: 12px; text-align: center; }
.empty-state h2 { margin: 0 0 8px; font-size: 1.2rem; }
.empty-state p { color: var(--vp-c-text-2); }
.empty-state a { display: inline-block; padding: 9px 13px; border-radius: 8px; background: var(--vp-c-brand-1); color: white; font-weight: 700; text-decoration: none; }
.catalog-footer { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 24px; padding-top: 18px; border-top: 1px solid var(--vp-c-divider); color: var(--vp-c-text-2); font-size: 0.86rem; }
.catalog-footer p { margin: 0; }

@media (max-width: 900px) {
  .catalog-intro, .catalog-footer { grid-template-columns: 1fr; }
  .catalog-summary { width: 100%; }
  .catalog-controls { grid-template-columns: 1fr 1fr; }
  .search-control { grid-column: 1 / -1; }
  .package-header { display: none; }
  .package-row:first-of-type { border-top: 0; }
  .package-row > summary { grid-template-columns: 1fr 1fr; gap: 12px 20px; padding-left: 32px; }
  .package-identity { grid-column: 1 / -1; }
  .package-row [data-label]::before { display: block; margin-bottom: 3px; color: var(--vp-c-text-3); content: attr(data-label); font-size: 0.66rem; font-weight: 700; letter-spacing: 0.04em; text-transform: uppercase; }
  .detail-metadata { grid-template-columns: 1fr; }
}

@media (max-width: 620px) {
  .catalog-intro { gap: 20px; }
  .catalog-summary div { min-width: 0; padding: 12px 7px; }
  .catalog-summary strong { font-size: 1.05rem; }
  .verification-note, .setup-grid, .catalog-controls { grid-template-columns: 1fr; }
  .verification-note strong { white-space: normal; }
  .search-control { grid-column: auto; }
  .results-heading { flex-direction: column; gap: 3px; }
  .package-row > summary { grid-template-columns: 1fr; }
  .package-identity { grid-column: auto; }
  .package-details { padding-left: 16px; }
}
</style>
