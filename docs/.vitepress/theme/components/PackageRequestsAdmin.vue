<script setup lang="ts">
import { computed, onMounted, reactive, ref } from "vue";

type RequestStatus = "proposed" | "under_review" | "accepted" | "in_progress" | "available" | "declined";

interface AdminRequest {
  id: number;
  packageName: string;
  ecosystem: string;
  upstreamUrl: string;
  description: string;
  useCase: string;
  canHelpTest: boolean;
  requesterName: string;
  organization: string;
  contactEmail: string;
  showRequesterPublicly: boolean;
  status: RequestStatus;
  portRepositoryUrl: string;
  artifactKind: string;
  artifactUrl: string;
  maintainerNote: string;
  voteCount: number;
  createdAt: string;
  acknowledgedAt: string | null;
}

interface PulpMatch {
  requestId: number;
  requestPackageName: string;
  requestStatus: string;
  source: "rpm" | "wheel";
  packageName: string;
  version: string;
  release: string;
  architecture: string;
  artifactUrl: string;
  publishedAt: string | null;
}

interface PulpRun {
  id: number;
  startedAt: string;
  finishedAt: string | null;
  status: "running" | "success" | "failed";
  artifactsSeen: number;
  matchesFound: number;
  error: string;
}

const productionApiUrl = "https://usage.zopen.community/package-requests/api";
const apiUrl = String(
  import.meta.env.VITE_PACKAGE_REQUESTS_API_URL || (import.meta.env.PROD ? productionApiUrl : "http://127.0.0.1:3100/api"),
).replace(/\/$/, "");
const storageKey = "zopen-package-admin-token";
const token = ref("");
const authenticated = ref(false);
const authenticating = ref(false);
const loginError = ref("");
const requests = ref<AdminRequest[]>([]);
const statusFilter = ref("all");
const saveStates = reactive<Record<number, { message: string; error: boolean; busy: boolean }>>({});
const pulpMatches = ref<PulpMatch[]>([]);
const pulpRuns = ref<PulpRun[]>([]);
const pulpArtifactCount = ref(0);
const pulpBusy = ref(false);
const pulpMessage = ref("");
const pulpError = ref(false);

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
const statuses: Record<RequestStatus, string> = {
  proposed: "Proposed",
  under_review: "Under review",
  accepted: "Accepted",
  in_progress: "In progress",
  available: "Available",
  declined: "Declined",
};
const artifacts: Record<string, string> = {
  "": "No published artifact",
  zopen_package: "zopen package (other location)",
  pulp_zopen: "zopen Pulp RPM package",
  pulp_python: "Pulp Python package / wheel",
  pypi: "PyPI project",
  python_wheel: "Python wheel",
  pulp_rpm: "Pulp RPM",
  other: "Other package location",
};

const visibleRequests = computed(() =>
  requests.value.filter((request) => statusFilter.value === "all" || request.status === statusFilter.value),
);

async function api(path: string, options: RequestInit = {}) {
  const headers = new Headers(options.headers);
  headers.set("Content-Type", "application/json");
  headers.set("Authorization", `Bearer ${token.value}`);
  const response = await fetch(`${apiUrl}${path}`, { ...options, headers });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error || "The request could not be completed.");
  return body;
}

async function loadRequests() {
  const result = await api("/admin/requests");
  requests.value = result.requests;
}

async function loadPulpOverview() {
  const result = await api("/admin/pulp");
  pulpMatches.value = result.matches;
  pulpRuns.value = result.runs;
  pulpArtifactCount.value = result.artifactCount;
}

async function signIn() {
  authenticating.value = true;
  loginError.value = "";
  try {
    await Promise.all([loadRequests(), loadPulpOverview()]);
    sessionStorage.setItem(storageKey, token.value);
    authenticated.value = true;
  } catch (error) {
    loginError.value = error instanceof Error ? error.message : "Authentication failed.";
  } finally {
    authenticating.value = false;
  }
}

function signOut() {
  sessionStorage.removeItem(storageKey);
  token.value = "";
  requests.value = [];
  pulpMatches.value = [];
  pulpRuns.value = [];
  authenticated.value = false;
}

async function syncPulp() {
  pulpBusy.value = true;
  pulpError.value = false;
  pulpMessage.value = "Reading the production Pulp repositories…";
  try {
    const result = await api("/admin/pulp/sync", { method: "POST" });
    pulpMessage.value = `Found ${result.run.artifactsSeen} artifacts and ${result.run.matchesFound} exact request matches.`;
    await loadPulpOverview();
  } catch (error) {
    pulpError.value = true;
    pulpMessage.value = error instanceof Error ? error.message : "Pulp synchronization failed.";
  } finally {
    pulpBusy.value = false;
  }
}

async function reviewPulpMatch(match: PulpMatch, action: "approve" | "dismiss") {
  if (
    action === "approve" &&
    !window.confirm(`Use ${match.packageName} ${match.version} and mark ${match.requestPackageName} available?`)
  ) return;
  pulpBusy.value = true;
  pulpError.value = false;
  pulpMessage.value = action === "approve" ? "Applying Pulp artifact…" : "Dismissing match…";
  try {
    await api(`/admin/pulp/matches/${match.requestId}/${match.source}/${action}`, { method: "POST" });
    await Promise.all([loadRequests(), loadPulpOverview()]);
    pulpMessage.value = action === "approve" ? "Pulp artifact applied and request marked available." : "Match dismissed.";
  } catch (error) {
    pulpError.value = true;
    pulpMessage.value = error instanceof Error ? error.message : "The match could not be reviewed.";
  } finally {
    pulpBusy.value = false;
  }
}

async function saveRequest(request: AdminRequest) {
  const state = saveStates[request.id] ||= { message: "", error: false, busy: false };
  state.busy = true;
  state.error = false;
  state.message = "Saving…";
  try {
    const result = await api(`/requests/${request.id}`, {
      method: "PATCH",
      body: JSON.stringify({
        packageName: request.packageName,
        ecosystem: request.ecosystem,
        upstreamUrl: request.upstreamUrl,
        description: request.description,
        useCase: request.useCase,
        canHelpTest: request.canHelpTest,
        requesterName: request.requesterName,
        organization: request.organization,
        contactEmail: request.contactEmail,
        showRequesterPublicly: request.showRequesterPublicly,
        status: request.status,
        portRepositoryUrl: request.portRepositoryUrl,
        artifactKind: request.artifactKind,
        artifactUrl: request.artifactUrl,
        maintainerNote: request.maintainerNote,
      }),
    });
    const index = requests.value.findIndex((item) => item.id === result.request.id);
    requests.value[index] = result.request;
    state.message = "Saved";
  } catch (error) {
    state.error = true;
    state.message = error instanceof Error ? error.message : "Save failed.";
  } finally {
    state.busy = false;
  }
}

async function deleteRequest(request: AdminRequest) {
  const confirmation = window.prompt(
    `Permanently delete this request and all of its votes and history?\n\nType "${request.packageName}" to confirm.`,
  );
  if (confirmation === null) return;
  const state = saveStates[request.id] ||= { message: "", error: false, busy: false };
  if (confirmation.trim() !== request.packageName) {
    state.error = true;
    state.message = "Package name did not match. Nothing was deleted.";
    return;
  }

  state.busy = true;
  state.error = false;
  state.message = "Deleting…";
  try {
    await api(`/requests/${request.id}`, { method: "DELETE" });
    requests.value = requests.value.filter((item) => item.id !== request.id);
  } catch (error) {
    state.error = true;
    state.message = error instanceof Error ? error.message : "Delete failed.";
    state.busy = false;
  }
}

onMounted(async () => {
  token.value = sessionStorage.getItem(storageKey) || "";
  if (token.value) await signIn();
});
</script>

<template>
  <div class="admin-console">
    <header class="admin-heading">
      <div><p class="eyebrow">Maintainer tools</p><h1>Package request administration</h1></div>
      <button v-if="authenticated" class="secondary" type="button" @click="signOut">Sign out</button>
    </header>

    <section v-if="!authenticated" class="login-panel">
      <h2>Maintainer access</h2>
      <p>Enter the package-request admin token. It is retained only for this browser tab.</p>
      <form class="token-row" @submit.prevent="signIn">
        <input v-model="token" type="password" autocomplete="current-password" required placeholder="Admin token" />
        <button class="primary" type="submit" :disabled="authenticating">
          {{ authenticating ? "Checking…" : "Open console" }}
        </button>
      </form>
      <p v-if="loginError" class="error" role="alert">{{ loginError }}</p>
    </section>

    <section v-else>
      <section class="pulp-panel">
        <div class="pulp-heading">
          <div>
            <p class="eyebrow">Repository discovery</p>
            <h2>Pulp synchronization</h2>
            <p>
              {{ pulpArtifactCount }} artifacts indexed.
              <template v-if="pulpRuns[0]">
                Last run {{ new Date(pulpRuns[0].startedAt).toLocaleString() }} · {{ pulpRuns[0].status }}.
              </template>
            </p>
          </div>
          <button class="secondary" type="button" :disabled="pulpBusy" @click="syncPulp">
            {{ pulpBusy ? "Working…" : "Sync now" }}
          </button>
        </div>
        <p v-if="pulpMessage" :class="['sync-message', { error: pulpError }]" role="status">{{ pulpMessage }}</p>
        <p v-if="pulpRuns[0]?.status === 'failed'" class="error">{{ pulpRuns[0].error }}</p>

        <div v-if="pulpMatches.length" class="match-list">
          <article v-for="match in pulpMatches" :key="`${match.requestId}:${match.source}`" class="match-card">
            <div>
              <span class="source-badge">{{ match.source === "rpm" ? "zopen RPM" : "Python wheel" }}</span>
              <h3>{{ match.requestPackageName }}</h3>
              <p>
                Exact match: <strong>{{ match.packageName }} {{ match.version }}</strong>
                <span v-if="match.release">-{{ match.release }}</span>
                · {{ match.architecture }}
              </p>
              <a :href="match.artifactUrl" target="_blank" rel="noopener noreferrer">Inspect artifact ↗</a>
            </div>
            <div class="match-actions">
              <button class="secondary" type="button" :disabled="pulpBusy" @click="reviewPulpMatch(match, 'dismiss')">Dismiss</button>
              <button class="primary" type="button" :disabled="pulpBusy" @click="reviewPulpMatch(match, 'approve')">Apply and mark available</button>
            </div>
          </article>
        </div>
        <p v-else class="no-matches">No Pulp matches need review.</p>
      </section>

      <div class="toolbar">
        <div><h2>Request queue</h2><p>Acknowledge, prioritize, and publish delivery locations.</p></div>
        <div class="filters">
          <select v-model="statusFilter" aria-label="Filter by status">
            <option value="all">All statuses</option>
            <option v-for="(label, key) in statuses" :key="key" :value="key">{{ label }}</option>
          </select>
          <button class="secondary" type="button" @click="loadRequests">Refresh</button>
        </div>
      </div>

      <div v-if="visibleRequests.length" class="request-list">
        <article v-for="request in visibleRequests" :key="request.id" class="request-card">
          <div class="summary">
            <div>
              <div class="title-row">
                <h3>{{ request.packageName }}</h3>
                <span class="pill">{{ ecosystems[request.ecosystem] || request.ecosystem }}</span>
                <span class="pill">{{ statuses[request.status] }}</span>
              </div>
              <p>{{ request.description }}</p>
              <div class="meta">
                <a v-if="request.upstreamUrl" :href="request.upstreamUrl" target="_blank" rel="noopener noreferrer">Upstream project ↗</a>
                <span>Requested {{ new Date(request.createdAt).toLocaleDateString() }}</span>
                <span v-if="request.acknowledgedAt">Acknowledged {{ new Date(request.acknowledgedAt).toLocaleDateString() }}</span>
              </div>
            </div>
            <div class="votes"><strong>{{ request.voteCount }}</strong><span>votes</span></div>
          </div>

          <details>
            <summary>Review and update</summary>
            <form class="editor" @submit.prevent="saveRequest(request)">
              <label><span>Package name</span><input v-model.trim="request.packageName" maxlength="80" required /></label>
              <label><span>Project ecosystem</span><select v-model="request.ecosystem"><option v-for="(label, key) in ecosystems" :key="key" :value="key">{{ label }}</option></select></label>
              <label class="wide"><span>Upstream project URL (optional)</span><input v-model.trim="request.upstreamUrl" type="url" /></label>
              <label class="wide"><span>Request description</span><textarea v-model.trim="request.description" minlength="20" maxlength="1200" required /></label>
              <label><span>Use case or version</span><textarea v-model.trim="request.useCase" maxlength="1200" /></label>
              <label><span>Can help test</span><select v-model="request.canHelpTest"><option :value="false">No</option><option :value="true">Yes</option></select></label>
              <label><span>Requester name or alias</span><input v-model.trim="request.requesterName" maxlength="100" /></label>
              <label><span>Organization or company</span><input v-model.trim="request.organization" maxlength="160" /></label>
              <label><span>Contact email (private)</span><input v-model.trim="request.contactEmail" type="email" maxlength="254" /></label>
              <label><span>Public requester attribution</span><select v-model="request.showRequesterPublicly"><option :value="false">Hidden</option><option :value="true">Show name and organization</option></select></label>
              <label><span>Status</span><select v-model="request.status"><option v-for="(label, key) in statuses" :key="key" :value="key">{{ label }}</option></select></label>
              <label><span>Published artifact type</span><select v-model="request.artifactKind"><option v-for="(label, key) in artifacts" :key="key" :value="key">{{ label }}</option></select></label>
              <label><span>zopen port repository URL</span><input v-model.trim="request.portRepositoryUrl" type="url" placeholder="https://github.com/zopencommunity/exampleport" /></label>
              <label><span>Published artifact / Pulp URL</span><input v-model.trim="request.artifactUrl" type="url" placeholder="https://repo.zopen.community/pulp/content/…" /></label>
              <label class="wide"><span>Public maintainer note</span><textarea v-model.trim="request.maintainerNote" maxlength="1200" placeholder="Triage decision, current progress, or installation guidance" /></label>
              <div class="editor-actions">
                <button class="danger" type="button" :disabled="saveStates[request.id]?.busy" @click="deleteRequest(request)">Delete permanently</button>
                <span :class="['save-state', { error: saveStates[request.id]?.error }]" role="status">{{ saveStates[request.id]?.message }}</span>
                <button class="primary" type="submit" :disabled="saveStates[request.id]?.busy">Save changes</button>
              </div>
            </form>
          </details>
        </article>
      </div>
      <div v-else class="empty">No requests match this status.</div>
    </section>
  </div>
</template>

<style scoped>
.admin-console { max-width: 1180px; margin: 0 auto; padding: 24px 0 70px; }
.admin-heading,.toolbar,.token-row,.filters,.title-row,.meta,.editor-actions,.pulp-heading,.match-card,.match-actions { display:flex; }
.admin-heading { justify-content:space-between; align-items:center; gap:20px; margin-bottom:28px; }
.admin-heading h1,.toolbar h2,.title-row h3 { margin:0; }
.eyebrow { margin:0 0 4px; color:var(--vp-c-brand-1); font-size:12px; font-weight:800; letter-spacing:.08em; text-transform:uppercase; }
.login-panel { max-width:560px; margin:8vh auto; padding:30px; border:1px solid var(--vp-c-divider); border-top:4px solid var(--vp-c-brand-1); border-radius:16px; background:var(--vp-c-bg-soft); }
.login-panel h2 { margin:0 0 8px; }
.login-panel p,.toolbar p { color:var(--vp-c-text-2); }
.token-row,.filters { gap:10px; }
.token-row input { flex:1; }
input,select,textarea { width:100%; border:1px solid var(--vp-c-divider); border-radius:8px; color:var(--vp-c-text-1); background:var(--vp-c-bg); font:inherit; }
input,select { height:42px; padding:0 11px; }
textarea { min-height:78px; padding:10px 11px; resize:vertical; }
input:focus,select:focus,textarea:focus { border-color:var(--vp-c-brand-1); outline:3px solid color-mix(in srgb,var(--vp-c-brand-1) 18%,transparent); }
button { cursor:pointer; font:inherit; }
button:disabled { cursor:wait; opacity:.65; }
.primary,.secondary,.danger { min-height:42px; padding:0 16px; border-radius:8px; font-weight:700; }
.primary { border:1px solid var(--vp-c-brand-1); color:white; background:var(--vp-c-brand-1); }
.secondary { border:1px solid var(--vp-c-divider); color:var(--vp-c-text-1); background:var(--vp-c-bg); }
.danger { margin-right:auto; border:1px solid var(--vp-c-danger-1); color:var(--vp-c-danger-1); background:transparent; }
.pulp-panel { margin-bottom:34px; padding:22px; border:1px solid var(--vp-c-divider); border-radius:14px; background:var(--vp-c-bg-soft); }
.pulp-heading { justify-content:space-between; align-items:start; gap:20px; }
.pulp-heading h2 { margin:0; }
.pulp-heading p { margin:6px 0 0; color:var(--vp-c-text-2); }
.sync-message { margin:14px 0 0; color:var(--vp-c-brand-1); }
.match-list { display:grid; gap:10px; margin-top:18px; }
.match-card { justify-content:space-between; align-items:center; gap:20px; padding:16px; border:1px solid var(--vp-c-divider); border-radius:10px; background:var(--vp-c-bg); }
.match-card h3 { margin:4px 0; }
.match-card p { margin:0 0 5px; color:var(--vp-c-text-2); }
.source-badge { color:var(--vp-c-brand-1); font-size:11px; font-weight:800; letter-spacing:.05em; text-transform:uppercase; }
.match-actions { flex-shrink:0; gap:8px; }
.no-matches { margin:16px 0 0; color:var(--vp-c-text-2); }
.toolbar { justify-content:space-between; align-items:end; gap:18px; margin-bottom:24px; }
.toolbar p { margin:5px 0 0; }
.filters select { width:190px; }
.request-list { display:grid; gap:14px; }
.request-card { border:1px solid var(--vp-c-divider); border-radius:14px; background:var(--vp-c-bg-soft); overflow:hidden; }
.summary { display:grid; grid-template-columns:minmax(0,1fr) auto; gap:20px; padding:20px; }
.title-row { flex-wrap:wrap; align-items:center; gap:9px; }
.title-row h3 { font-size:20px; }
.pill { padding:4px 8px; border-radius:999px; color:var(--vp-c-brand-1); background:color-mix(in srgb,var(--vp-c-brand-1) 12%,transparent); font-size:11px; font-weight:800; text-transform:uppercase; }
.summary p { margin:10px 0 0; color:var(--vp-c-text-2); line-height:1.5; }
.meta { flex-wrap:wrap; gap:12px; margin-top:12px; color:var(--vp-c-text-2); font-size:12px; }
.votes { align-self:start; min-width:70px; padding:10px; border:1px solid var(--vp-c-divider); border-radius:10px; text-align:center; }
.votes strong,.votes span { display:block; }
.votes strong { font-size:22px; }
.votes span { color:var(--vp-c-text-2); font-size:10px; text-transform:uppercase; }
details { border-top:1px solid var(--vp-c-divider); }
details > summary { padding:13px 20px; color:var(--vp-c-brand-1); font-size:13px; font-weight:700; cursor:pointer; }
.editor { display:grid; grid-template-columns:1fr 1fr; gap:16px; padding:6px 20px 22px; }
.editor label > span { display:block; margin-bottom:6px; color:var(--vp-c-text-2); font-size:12px; font-weight:700; }
.wide,.editor-actions { grid-column:1/-1; }
.editor-actions { justify-content:flex-end; align-items:center; gap:12px; }
.save-state { color:var(--vp-c-text-2); font-size:13px; }
.error { color:var(--vp-c-danger-1); }
.empty { padding:60px; border:1px dashed var(--vp-c-divider); border-radius:14px; color:var(--vp-c-text-2); text-align:center; }
@media (max-width:720px) { .toolbar,.token-row,.pulp-heading,.match-card { align-items:stretch; flex-direction:column; } .filters,.match-actions { flex-direction:column; } .filters select { width:100%; } .editor { grid-template-columns:1fr; } .wide,.editor-actions { grid-column:1; } }
</style>
