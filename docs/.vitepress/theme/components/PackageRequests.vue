<script setup lang="ts">
import { computed, onMounted, reactive, ref } from "vue";
import { withBase } from "vitepress";

type RequestStatus =
  | "proposed"
  | "under_review"
  | "accepted"
  | "in_progress"
  | "available"
  | "declined";

interface PackageRequest {
  id: number;
  packageName: string;
  ecosystem: string;
  portRepositoryUrl: string;
  artifactKind: string;
  artifactUrl: string;
  maintainerNote: string;
  acknowledgedAt: string | null;
  availableAt: string | null;
  requesterName: string;
  organization: string;
  showRequesterPublicly: boolean;
  upstreamUrl: string;
  description: string;
  useCase: string;
  canHelpTest: boolean;
  status: RequestStatus;
  voteCount: number;
  voted: boolean;
  createdAt: string;
}

const productionApiUrl = "https://usage.zopen.community/package-requests/api";
const configuredApiUrl = String(
  import.meta.env.VITE_PACKAGE_REQUESTS_API_URL || (import.meta.env.PROD ? productionApiUrl : ""),
).replace(/\/$/, "");
const apiUrl = ref(configuredApiUrl);
const requests = ref<PackageRequest[]>([]);
const availablePackages = ref(new Set<string>());
const search = ref("");
const sort = ref<"top" | "newest">("top");
const status = ref("all");
const ecosystem = ref("all");
const loading = ref(true);
const loadError = ref("");
const formOpen = ref(false);
const submitting = ref(false);
const submitError = ref("");
const successMessage = ref("");
const busyVotes = ref(new Set<number>());

const form = reactive({
  packageName: "",
  ecosystem: "",
  upstreamUrl: "",
  description: "",
  useCase: "",
  canHelpTest: false,
  requesterName: "",
  organization: "",
  contactEmail: "",
  showRequesterPublicly: false,
});

const statuses: Record<RequestStatus, { label: string; detail: string }> = {
  proposed: { label: "Proposed", detail: "Gathering community interest" },
  under_review: { label: "Under review", detail: "Being evaluated by maintainers" },
  accepted: { label: "Accepted", detail: "Approved for future work" },
  in_progress: { label: "In progress", detail: "Someone is working on the port" },
  available: { label: "Available", detail: "The package has been released" },
  declined: { label: "Declined", detail: "Not currently planned" },
};

const ecosystems: Record<string, string> = {
  general: "General / CLI",
  python: "Python / PyPI",
  c_cpp: "C / C++",
  rust: "Rust / Cargo",
  go: "Go module",
  java: "Java / JVM",
  javascript: "JavaScript / npm",
  shell: "Shell",
  other: "Other",
};

const artifactLabels: Record<string, string> = {
  zopen_package: "Installable zopen package",
  pulp_zopen: "zopen Pulp RPM package",
  pulp_python: "Pulp Python package / wheel",
  pypi: "PyPI project",
  python_wheel: "Python wheel",
  pulp_rpm: "Pulp RPM",
  other: "Published package",
};

const filteredRequests = computed(() => {
  const query = search.value.trim().toLowerCase();
  return requests.value.filter((request) => {
    const matchesStatus = status.value === "all" || request.status === status.value;
    const matchesEcosystem = ecosystem.value === "all" || request.ecosystem === ecosystem.value;
    const matchesSearch =
      !query ||
      request.packageName.toLowerCase().includes(query) ||
      request.description.toLowerCase().includes(query) ||
      request.useCase.toLowerCase().includes(query);
    return matchesStatus && matchesEcosystem && matchesSearch;
  });
});

const totalVotes = computed(() => requests.value.reduce((total, request) => total + request.voteCount, 0));
const availableMatch = computed(() => {
  const normalized = normalizeName(form.packageName);
  return normalized && availablePackages.value.has(normalized);
});

function normalizeName(value: string) {
  return value.trim().toLowerCase().replace(/\s+/g, "-").replace(/-?port$/, "");
}

function getVoterId() {
  const storageKey = "zopen-package-request-voter-id";
  let voterId = localStorage.getItem(storageKey);
  if (!voterId) {
    voterId = crypto.randomUUID();
    localStorage.setItem(storageKey, voterId);
  }
  return voterId;
}

async function apiRequest(path: string, options: RequestInit = {}) {
  if (!apiUrl.value) throw new Error("The package request service has not been configured yet.");
  const headers = new Headers(options.headers);
  headers.set("Content-Type", "application/json");
  headers.set("X-Voter-ID", getVoterId());
  const response = await fetch(`${apiUrl.value}${path}`, { ...options, headers });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    const error = new Error(body.error || "The request could not be completed.");
    Object.assign(error, body);
    throw error;
  }
  return body;
}

async function loadRequests() {
  loading.value = true;
  loadError.value = "";
  try {
    const result = await apiRequest(`/requests?sort=${sort.value}`);
    requests.value = result.requests;
  } catch (error) {
    loadError.value = error instanceof Error ? error.message : "The package requests could not be loaded.";
  } finally {
    loading.value = false;
  }
}

async function loadAvailablePackages() {
  try {
    const response = await fetch(withBase("/api/zopen_releases_descriptions.json"));
    if (!response.ok) return;
    const data = await response.json();
    availablePackages.value = new Set(
      Object.keys(data.descriptions || {}).map((packageName) => normalizeName(packageName)),
    );
  } catch {
    // This hint is optional; a failure should not prevent package submissions.
  }
}

async function changeSort() {
  await loadRequests();
}

async function toggleVote(request: PackageRequest) {
  if (busyVotes.value.has(request.id)) return;
  busyVotes.value = new Set(busyVotes.value).add(request.id);
  const previous = { voted: request.voted, voteCount: request.voteCount };
  request.voted = !request.voted;
  request.voteCount += request.voted ? 1 : -1;

  try {
    const result = await apiRequest(`/requests/${request.id}/vote`, {
      method: request.voted ? "PUT" : "DELETE",
      body: JSON.stringify({ voterId: getVoterId() }),
    });
    request.voted = result.voted;
    request.voteCount = result.voteCount;
  } catch (error) {
    request.voted = previous.voted;
    request.voteCount = previous.voteCount;
    loadError.value = error instanceof Error ? error.message : "Your vote could not be saved.";
  } finally {
    const nextBusyVotes = new Set(busyVotes.value);
    nextBusyVotes.delete(request.id);
    busyVotes.value = nextBusyVotes;
  }
}

function openForm() {
  formOpen.value = true;
  submitError.value = "";
  successMessage.value = "";
  requestAnimationFrame(() => document.querySelector<HTMLElement>("#package-request-form input")?.focus());
}

function closeForm() {
  formOpen.value = false;
  submitError.value = "";
}

async function submitRequest() {
  submitError.value = "";
  successMessage.value = "";
  if (availableMatch.value) {
    submitError.value = "This package already appears in the available-tools catalog.";
    return;
  }

  submitting.value = true;
  try {
    const result = await apiRequest("/requests", {
      method: "POST",
      body: JSON.stringify(form),
    });
    requests.value.unshift(result.request);
    form.packageName = "";
    form.ecosystem = "";
    form.upstreamUrl = "";
    form.description = "";
    form.useCase = "";
    form.canHelpTest = false;
    form.requesterName = "";
    form.organization = "";
    form.contactEmail = "";
    form.showRequesterPublicly = false;
    formOpen.value = false;
    successMessage.value = `${result.request.packageName} was added. You can now vote for it and share this page.`;
    document.querySelector(".package-requests")?.scrollIntoView({ behavior: "smooth", block: "start" });
  } catch (error) {
    const apiError = error as Error & { existingRequestId?: number };
    submitError.value = apiError.message;
    if (apiError.existingRequestId) {
      formOpen.value = false;
      search.value = form.packageName;
      requestAnimationFrame(() => document.getElementById(`package-request-${apiError.existingRequestId}`)?.scrollIntoView({
        behavior: "smooth",
        block: "center",
      }));
    }
  } finally {
    submitting.value = false;
  }
}

onMounted(() => {
  if (!apiUrl.value && ["localhost", "127.0.0.1"].includes(window.location.hostname)) {
    apiUrl.value = "http://localhost:3100/api";
  }
  const packageFromQuery = new URLSearchParams(window.location.search).get("package");
  if (packageFromQuery) {
    form.packageName = packageFromQuery;
    formOpen.value = true;
  }
  void Promise.all([loadRequests(), loadAvailablePackages()]);
});
</script>

<template>
  <div class="package-requests">
    <section class="request-hero">
      <div class="request-hero-copy">
        <span class="eyebrow">Community package backlog</span>
        <h1>What should we bring to z/OS next?</h1>
        <p>
          Request an open-source package, support the tools you need, and follow its progress.
        </p>
        <div class="hero-actions">
          <button class="primary-button" type="button" @click="openForm">Request a package</button>
          <a class="secondary-button" :href="withBase('/Latest')">Browse available tools</a>
          <a
            class="secondary-button"
            href="https://repo.zopen.community/pulp/content/"
            target="_blank"
            rel="noopener noreferrer"
          >Browse package repository ↗</a>
        </div>
      </div>
      <div class="request-stats" aria-label="Package request statistics">
        <div><strong>{{ requests.length }}</strong><span>requests</span></div>
        <div><strong>{{ totalVotes }}</strong><span>community votes</span></div>
      </div>
    </section>

    <p v-if="successMessage" class="notice success" role="status">{{ successMessage }}</p>
    <p v-if="loadError" class="notice error" role="alert">
      {{ loadError }}
      <button v-if="apiUrl" type="button" class="text-button" @click="loadRequests">Try again</button>
    </p>

    <section v-if="formOpen" id="package-request-form" class="request-form-panel">
      <div class="panel-heading">
        <div>
          <span class="eyebrow">New request</span>
          <h2>Tell us what you need</h2>
        </div>
        <button class="close-button" type="button" aria-label="Close request form" @click="closeForm">×</button>
      </div>

      <form @submit.prevent="submitRequest">
        <div class="form-grid">
          <label>
            <span>Package name <b aria-hidden="true">*</b></span>
            <input v-model.trim="form.packageName" maxlength="80" required placeholder="e.g. ripgrep" />
          </label>
          <label>
            <span>Project ecosystem <b aria-hidden="true">*</b></span>
            <select v-model="form.ecosystem" required>
              <option value="" disabled>Select an ecosystem</option>
              <option v-for="(label, key) in ecosystems" :key="key" :value="key">{{ label }}</option>
            </select>
          </label>
        </div>
        <div class="form-grid">
          <label>
            <span>Upstream project URL <small>Optional</small></span>
            <input v-model.trim="form.upstreamUrl" type="url" maxlength="500" placeholder="GitHub, PyPI, crates.io, project homepage…" />
          </label>
          <div class="field-hint">
            Add a GitHub, project homepage, or package-registry link if you know it. Maintainers can add this later.
          </div>
        </div>

        <p v-if="availableMatch" class="inline-warning">
          This package appears to be available already. <a :href="withBase('/Latest')">Find it in the catalog</a>.
        </p>

        <label>
          <span>Why would this package be useful on z/OS? <b aria-hidden="true">*</b></span>
          <textarea
            v-model.trim="form.description"
            minlength="20"
            maxlength="1200"
            required
            rows="4"
            placeholder="Describe the problem it solves and who would benefit."
          />
        </label>
        <label>
          <span>Specific use case or version <small>Optional</small></span>
          <textarea
            v-model.trim="form.useCase"
            maxlength="1200"
            rows="3"
            placeholder="Tell us about required features, versions, or compatibility needs."
          />
        </label>
        <label class="checkbox-label">
          <input v-model="form.canHelpTest" type="checkbox" />
          <span>I may be able to help test this package on z/OS.</span>
        </label>
        <fieldset class="requester-section">
          <legend>About you <small>Optional</small></legend>
          <p>These details help maintainers follow up and understand who would benefit from the package.</p>
          <div class="form-grid requester-grid">
            <label>
              <span>Name or alias</span>
              <input v-model.trim="form.requesterName" maxlength="100" autocomplete="name" placeholder="Your name" />
            </label>
            <label>
              <span>Organization or company</span>
              <input v-model.trim="form.organization" maxlength="160" autocomplete="organization" placeholder="Organization name" />
            </label>
          </div>
          <label>
            <span>Contact email <small>Private—maintainers only</small></span>
            <input v-model.trim="form.contactEmail" type="email" maxlength="254" autocomplete="email" placeholder="you@example.com" />
          </label>
          <label class="checkbox-label">
            <input v-model="form.showRequesterPublicly" type="checkbox" />
            <span>Show my name and organization on the public request.</span>
          </label>
        </fieldset>
        <p v-if="submitError" class="notice error" role="alert">{{ submitError }}</p>
        <div class="form-actions">
          <button class="secondary-button" type="button" @click="closeForm">Cancel</button>
          <button class="primary-button" type="submit" :disabled="submitting || Boolean(availableMatch)">
            {{ submitting ? "Submitting…" : "Submit request" }}
          </button>
        </div>
      </form>
    </section>

    <section class="request-board">
      <div class="board-heading">
        <div>
          <span class="eyebrow">Package requests</span>
          <h2>Vote for what matters to you</h2>
        </div>
        <button v-if="!formOpen" class="primary-button compact" type="button" @click="openForm">+ New request</button>
      </div>

      <div class="board-controls">
        <label class="search-control">
          <span class="visually-hidden">Search package requests</span>
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m21 21-4.35-4.35m2.35-5.65a8 8 0 1 1-16 0 8 8 0 0 1 16 0Z" /></svg>
          <input v-model="search" type="search" placeholder="Search requests…" />
        </label>
        <label>
          <span class="visually-hidden">Filter by ecosystem</span>
          <select v-model="ecosystem">
            <option value="all">All ecosystems</option>
            <option v-for="(label, key) in ecosystems" :key="key" :value="key">{{ label }}</option>
          </select>
        </label>
        <label>
          <span class="visually-hidden">Filter by status</span>
          <select v-model="status">
            <option value="all">All statuses</option>
            <option v-for="(value, key) in statuses" :key="key" :value="key">{{ value.label }}</option>
          </select>
        </label>
        <div class="sort-control" aria-label="Sort requests">
          <button type="button" :class="{ active: sort === 'top' }" @click="sort = 'top'; changeSort()">Top</button>
          <button type="button" :class="{ active: sort === 'newest' }" @click="sort = 'newest'; changeSort()">Newest</button>
        </div>
      </div>

      <div v-if="loading" class="request-skeletons" aria-label="Loading package requests">
        <div v-for="item in 3" :key="item" class="request-skeleton" />
      </div>

      <div v-else-if="filteredRequests.length" class="request-list">
        <article
          v-for="request in filteredRequests"
          :id="`package-request-${request.id}`"
          :key="request.id"
          class="request-card"
        >
          <button
            type="button"
            class="vote-button"
            :class="{ voted: request.voted }"
            :disabled="busyVotes.has(request.id)"
            :aria-label="`${request.voted ? 'Remove vote from' : 'Vote for'} ${request.packageName}`"
            :aria-pressed="request.voted"
            @click="toggleVote(request)"
          >
            <svg viewBox="0 0 20 20" aria-hidden="true"><path d="m10 4 5 6h-3v6H8v-6H5l5-6Z" /></svg>
            <strong>{{ request.voteCount }}</strong>
            <span>{{ request.voted ? "Voted" : "Vote" }}</span>
          </button>
          <div class="request-card-content">
            <div class="request-card-title">
              <h3>{{ request.packageName }}</h3>
              <span class="ecosystem-pill">{{ ecosystems[request.ecosystem] || request.ecosystem }}</span>
              <span class="status-pill" :class="`status-${request.status}`" :title="statuses[request.status].detail">
                {{ statuses[request.status].label }}
              </span>
            </div>
            <p>{{ request.description }}</p>
            <p v-if="request.useCase" class="use-case"><strong>Use case:</strong> {{ request.useCase }}</p>
            <p v-if="request.maintainerNote" class="maintainer-note">
              <strong>Maintainer update:</strong> {{ request.maintainerNote }}
            </p>
            <div v-if="request.portRepositoryUrl || request.artifactUrl" class="delivery-links">
              <a
                v-if="request.portRepositoryUrl"
                :href="request.portRepositoryUrl"
                target="_blank"
                rel="noopener noreferrer"
              >zopen port repository ↗</a>
              <a
                v-if="request.artifactUrl"
                :href="request.artifactUrl"
                target="_blank"
                rel="noopener noreferrer"
              >{{ artifactLabels[request.artifactKind] || "Published package" }} ↗</a>
            </div>
            <div class="request-meta">
              <a v-if="request.upstreamUrl" :href="request.upstreamUrl" target="_blank" rel="noopener noreferrer">View upstream project ↗</a>
              <span v-if="request.canHelpTest">Tester available</span>
              <span v-if="request.acknowledgedAt">Acknowledged by maintainers</span>
              <span v-if="request.requesterName || request.organization">
                Requested by {{ [request.requesterName, request.organization].filter(Boolean).join(" · ") }}
              </span>
              <span>Requested {{ new Date(request.createdAt).toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" }) }}</span>
            </div>
          </div>
        </article>
      </div>

      <div v-else class="empty-state">
        <div aria-hidden="true">📦</div>
        <h3>{{ requests.length ? "No requests match those filters" : "Be the first to request a package" }}</h3>
        <p>{{ requests.length ? "Try a different search or status." : "Tell the community which open-source tool would help you on z/OS." }}</p>
        <button v-if="!requests.length" class="primary-button" type="button" @click="openForm">Request a package</button>
      </div>
    </section>
  </div>
</template>

<style scoped>
.package-requests { --request-accent: #167d68; --request-accent-dark: #0d5c4c; color: var(--vp-c-text-1); }
.request-hero { position: relative; display: grid; grid-template-columns: minmax(0, 1.6fr) minmax(260px, .7fr); gap: 48px; align-items: end; padding: 56px; margin: 0 0 28px; overflow: hidden; border: 1px solid var(--vp-c-divider); border-radius: 24px; background: linear-gradient(135deg, color-mix(in srgb, var(--request-accent) 14%, var(--vp-c-bg)) 0%, var(--vp-c-bg-soft) 65%); }
.request-hero::after { content: ""; position: absolute; width: 260px; height: 260px; right: -70px; top: -100px; border: 54px solid color-mix(in srgb, var(--request-accent) 12%, transparent); border-radius: 50%; }
.request-hero-copy, .request-stats { position: relative; z-index: 1; }
.eyebrow { display: block; margin-bottom: 8px; color: var(--request-accent); font-size: 12px; font-weight: 750; letter-spacing: .12em; text-transform: uppercase; }
.request-hero h1 { max-width: 720px; margin: 0; border: 0; font-size: clamp(36px, 5vw, 60px); line-height: 1.02; letter-spacing: -.04em; }
.request-hero p { max-width: 680px; margin: 20px 0 0; color: var(--vp-c-text-2); font-size: 18px; line-height: 1.65; }
.hero-actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 28px; }
.primary-button, .secondary-button { display: inline-flex; align-items: center; justify-content: center; min-height: 44px; padding: 0 20px; border: 1px solid transparent; border-radius: 10px; font: inherit; font-weight: 650; line-height: 1; text-decoration: none !important; cursor: pointer; transition: transform .15s, background-color .15s, border-color .15s; }
.primary-button { color: white; background: var(--request-accent); }
.primary-button:hover { color: white; background: var(--request-accent-dark); transform: translateY(-1px); }
.primary-button:disabled { cursor: not-allowed; opacity: .55; transform: none; }
.secondary-button { color: var(--vp-c-text-1); border-color: var(--vp-c-divider); background: var(--vp-c-bg); }
.secondary-button:hover { border-color: var(--request-accent); color: var(--request-accent); }
.primary-button.compact { min-height: 38px; padding: 0 14px; font-size: 14px; }
.request-stats { display: grid; grid-template-columns: 1fr 1fr; gap: 1px; overflow: hidden; border: 1px solid var(--vp-c-divider); border-radius: 16px; background: var(--vp-c-divider); box-shadow: var(--vp-shadow-2); }
.request-stats div { display: flex; min-height: 126px; flex-direction: column; align-items: center; justify-content: center; background: color-mix(in srgb, var(--vp-c-bg) 92%, transparent); }
.request-stats strong { font-size: 34px; letter-spacing: -.03em; }
.request-stats span { color: var(--vp-c-text-2); font-size: 12px; text-align: center; text-transform: uppercase; letter-spacing: .08em; }
.notice { padding: 13px 16px; border-radius: 10px; font-size: 14px; }
.notice.success { color: #09634f; border: 1px solid #85cdbd; background: #e7f8f3; }
.dark .notice.success { color: #a8e6d6; border-color: #275e52; background: #142d28; }
.notice.error { color: var(--vp-c-danger-1); border: 1px solid var(--vp-c-danger-2); background: var(--vp-c-danger-soft); }
.text-button { margin-left: 8px; padding: 0; color: inherit; border: 0; background: transparent; font: inherit; font-weight: 650; text-decoration: underline; cursor: pointer; }
.request-form-panel, .request-board { margin-top: 28px; border: 1px solid var(--vp-c-divider); border-radius: 18px; background: var(--vp-c-bg); box-shadow: var(--vp-shadow-1); }
.request-form-panel { padding: 28px; border-top: 4px solid var(--request-accent); }
.panel-heading, .board-heading { display: flex; align-items: flex-start; justify-content: space-between; gap: 24px; }
.panel-heading h2, .board-heading h2 { margin: 0; border: 0; padding: 0; font-size: 26px; letter-spacing: -.02em; }
.close-button { width: 38px; height: 38px; border: 1px solid var(--vp-c-divider); border-radius: 50%; color: var(--vp-c-text-2); background: var(--vp-c-bg-soft); font-size: 26px; line-height: 1; cursor: pointer; }
.request-form-panel form { margin-top: 24px; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.request-form-panel label { display: block; margin: 0 0 18px; }
.request-form-panel label > span { display: block; margin-bottom: 7px; font-size: 14px; font-weight: 650; }
.request-form-panel label b { color: var(--vp-c-danger-1); }
.request-form-panel label small { margin-left: 6px; color: var(--vp-c-text-3); font-weight: 400; }
.request-form-panel input:not([type="checkbox"]), .request-form-panel textarea, .request-form-panel select, .board-controls input, .board-controls select { box-sizing: border-box; width: 100%; border: 1px solid var(--vp-c-divider); border-radius: 9px; color: var(--vp-c-text-1); background: var(--vp-c-bg-soft); font: inherit; outline: none; }
.request-form-panel input:not([type="checkbox"]), .request-form-panel select, .board-controls input, .board-controls select { height: 44px; padding: 0 13px; }
.request-form-panel textarea { min-height: 90px; padding: 11px 13px; resize: vertical; }
.request-form-panel input:focus, .request-form-panel textarea:focus, .request-form-panel select:focus, .board-controls input:focus, .board-controls select:focus { border-color: var(--request-accent); box-shadow: 0 0 0 3px color-mix(in srgb, var(--request-accent) 15%, transparent); }
.field-hint { align-self: center; padding: 0 8px; color: var(--vp-c-text-3); font-size: 13px; line-height: 1.5; }
.checkbox-label { display: flex !important; gap: 10px; align-items: flex-start; }
.checkbox-label input { width: 17px; height: 17px; margin-top: 2px; accent-color: var(--request-accent); }
.checkbox-label span { margin: 0 !important; font-weight: 500 !important; }
.requester-section { padding: 18px; margin: 22px 0; border: 1px solid var(--vp-c-divider); border-radius: 12px; background: var(--vp-c-bg-soft); }
.requester-section legend { padding: 0 7px; font-weight: 750; }
.requester-section legend small { margin-left: 5px; color: var(--vp-c-text-3); font-weight: 400; }
.requester-section > p { margin: 0 0 16px; color: var(--vp-c-text-2); font-size: 13px; }
.requester-section label:last-child { margin-bottom: 0; }
.inline-warning { padding: 10px 12px; margin: -6px 0 18px; border-radius: 8px; color: #825d00; background: #fff4ce; font-size: 14px; }
.dark .inline-warning { color: #ffe08a; background: #3b3011; }
.form-actions { display: flex; justify-content: flex-end; gap: 10px; }
.request-board { padding: 28px; }
.board-controls { display: grid; grid-template-columns: minmax(220px, 1fr) 170px 160px auto; gap: 12px; margin: 24px 0; }
.search-control { position: relative; }
.search-control svg { position: absolute; z-index: 1; width: 18px; left: 13px; top: 13px; fill: none; stroke: var(--vp-c-text-3); stroke-width: 2; stroke-linecap: round; }
.search-control input { padding-left: 40px; }
.sort-control { display: flex; padding: 3px; border: 1px solid var(--vp-c-divider); border-radius: 9px; background: var(--vp-c-bg-soft); }
.sort-control button { min-width: 70px; border: 0; border-radius: 6px; color: var(--vp-c-text-2); background: transparent; font: inherit; font-size: 14px; cursor: pointer; }
.sort-control button.active { color: var(--vp-c-text-1); background: var(--vp-c-bg); box-shadow: var(--vp-shadow-1); font-weight: 650; }
.request-list { display: grid; gap: 12px; }
.request-card { display: grid; grid-template-columns: 82px minmax(0, 1fr); gap: 20px; padding: 22px; border: 1px solid var(--vp-c-divider); border-radius: 14px; transition: border-color .15s, box-shadow .15s, transform .15s; }
.request-card:hover { border-color: color-mix(in srgb, var(--request-accent) 55%, var(--vp-c-divider)); box-shadow: var(--vp-shadow-2); transform: translateY(-1px); }
.vote-button { display: flex; width: 72px; min-height: 92px; align-self: start; flex-direction: column; align-items: center; justify-content: center; border: 1px solid var(--vp-c-divider); border-radius: 12px; color: var(--vp-c-text-2); background: var(--vp-c-bg-soft); cursor: pointer; }
.vote-button:hover { border-color: var(--request-accent); color: var(--request-accent); }
.vote-button.voted { border-color: var(--request-accent); color: var(--request-accent-dark); background: color-mix(in srgb, var(--request-accent) 12%, var(--vp-c-bg)); }
.dark .vote-button.voted { color: #72d2bc; }
.vote-button:disabled { opacity: .6; cursor: wait; }
.vote-button svg { width: 22px; fill: currentColor; }
.vote-button strong { margin-top: 2px; font-size: 20px; line-height: 1.1; }
.vote-button span { margin-top: 3px; font-size: 11px; font-weight: 650; text-transform: uppercase; letter-spacing: .05em; }
.request-card-title { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; }
.request-card-title h3 { margin: 0; font-size: 20px; line-height: 1.3; }
.status-pill { padding: 4px 9px; border-radius: 999px; color: var(--vp-c-text-2); background: var(--vp-c-default-soft); font-size: 11px; font-weight: 700; letter-spacing: .03em; text-transform: uppercase; }
.ecosystem-pill { padding: 4px 9px; border: 1px solid var(--vp-c-divider); border-radius: 999px; color: var(--request-accent); background: var(--vp-c-bg-soft); font-size: 11px; font-weight: 700; }
.status-under_review { color: #795b00; background: #fff1bd; }
.status-accepted { color: #225ca8; background: #e5efff; }
.status-in_progress { color: #7445a0; background: #f0e5fb; }
.status-available { color: #09634f; background: #daf4ec; }
.dark .status-under_review, .dark .status-accepted, .dark .status-in_progress, .dark .status-available { color: var(--vp-c-text-1); background: var(--vp-c-bg-soft); }
.request-card-content > p { margin: 10px 0 0; color: var(--vp-c-text-2); line-height: 1.6; }
.request-card-content .use-case { padding-left: 12px; border-left: 2px solid var(--vp-c-divider); font-size: 14px; }
.request-card-content .maintainer-note { padding: 12px 14px; border-radius: 9px; color: var(--vp-c-text-1); background: color-mix(in srgb, var(--request-accent) 9%, var(--vp-c-bg-soft)); font-size: 14px; }
.delivery-links { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 14px; }
.delivery-links a { padding: 7px 10px; border: 1px solid color-mix(in srgb, var(--request-accent) 45%, var(--vp-c-divider)); border-radius: 8px; color: var(--request-accent); background: var(--vp-c-bg-soft); font-size: 13px; font-weight: 700; text-decoration: none; }
.request-meta { display: flex; flex-wrap: wrap; gap: 8px 18px; margin-top: 16px; color: var(--vp-c-text-3); font-size: 12px; }
.request-meta a { color: var(--request-accent); font-weight: 650; text-decoration: none; }
.request-skeletons { display: grid; gap: 12px; }
.request-skeleton { height: 142px; border-radius: 14px; background: linear-gradient(90deg, var(--vp-c-bg-soft), var(--vp-c-bg-alt), var(--vp-c-bg-soft)); background-size: 200% 100%; animation: shimmer 1.4s infinite linear; }
@keyframes shimmer { to { background-position: -200% 0; } }
.empty-state { padding: 70px 20px; border: 1px dashed var(--vp-c-divider); border-radius: 14px; text-align: center; }
.empty-state > div { font-size: 38px; }
.empty-state h3 { margin: 10px 0 4px; }
.empty-state p { margin: 0 0 20px; color: var(--vp-c-text-2); }
.visually-hidden { position: absolute !important; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border: 0; }
@media (max-width: 760px) {
  .request-hero { grid-template-columns: 1fr; gap: 30px; padding: 34px 24px; }
  .request-hero h1 { font-size: 38px; }
  .request-stats div { min-height: 96px; }
  .form-grid, .board-controls { grid-template-columns: 1fr; }
  .request-form-panel, .request-board { padding: 20px; }
  .request-card { grid-template-columns: 58px minmax(0, 1fr); gap: 14px; padding: 17px; }
  .vote-button { width: 56px; min-height: 82px; }
  .board-heading { align-items: center; }
}
</style>
