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
  discussionCount: number;
  pendingPostCount: number;
  ownerGithubId: number | null;
  ownerGithubLogin: string;
  createdAt: string;
  acknowledgedAt: string | null;
}

interface PulpMatch {
  requestId: number;
  requestPackageName: string;
  requestStatus: string;
  requestEcosystem?: string;
  source: "rpm" | "wheel";
  isPrimary?: boolean;
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

interface CommunityPost {
  id: number;
  requestId: number;
  requestPackageName: string;
  kind: string;
  body: string;
  authorRole: "community" | "maintainer";
  authorName: string;
  organization: string;
  contactEmail: string;
  showAuthorPublicly: boolean;
  moderationStatus: "pending" | "published" | "hidden";
  createdAt: string;
  updatedAt: string;
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
const moderationPosts = ref<CommunityPost[]>([]);
const moderationFilter = ref("pending");
const moderationBusy = ref(false);
const moderationMessage = ref("");
const moderationError = ref(false);
const maintainerDrafts = reactive<Record<number, {
  kind: string;
  body: string;
  busy: boolean;
  message: string;
  error: boolean;
}>>({});

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
const postKinds: Record<string, string> = {
  use_case: "Use case",
  testing_offer: "Testing offer",
  contribution_offer: "Contribution offer",
  technical_note: "Technical information",
  question: "Question",
  maintainer_update: "Maintainer update",
};

const visibleRequests = computed(() =>
  requests.value.filter((request) => statusFilter.value === "all" || request.status === statusFilter.value),
);
const orderedPulpMatches = computed(() => [...pulpMatches.value].sort((left, right) => {
  if (left.requestId !== right.requestId) return right.requestId - left.requestId;
  return Number(isPrimaryMatch(right)) - Number(isPrimaryMatch(left));
}));
const pendingPostTotal = computed(() => requests.value.reduce(
  (total, request) => total + Number(request.pendingPostCount || 0),
  0,
));

function matchEcosystem(match: PulpMatch) {
  return match.requestEcosystem || requests.value.find((request) => request.id === match.requestId)?.ecosystem || "general";
}

function isPrimaryMatch(match: PulpMatch) {
  if (typeof match.isPrimary === "boolean") return match.isPrimary;
  return matchEcosystem(match) === "python" ? match.source === "wheel" : match.source === "rpm";
}

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

async function loadModerationPosts() {
  const result = await api(`/admin/posts?status=${moderationFilter.value}`);
  moderationPosts.value = result.posts;
}

async function signIn() {
  authenticating.value = true;
  loginError.value = "";
  try {
    await Promise.all([loadRequests(), loadPulpOverview()]);
    sessionStorage.setItem(storageKey, token.value);
    authenticated.value = true;
    try {
      await loadModerationPosts();
    } catch (error) {
      moderationError.value = true;
      moderationMessage.value = error instanceof Error ? error.message : "Discussion moderation is temporarily unavailable.";
    }
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
  moderationPosts.value = [];
  authenticated.value = false;
}

async function moderatePost(post: CommunityPost, moderationStatus = post.moderationStatus) {
  moderationBusy.value = true;
  moderationError.value = false;
  moderationMessage.value = "Saving community post…";
  try {
    await api(`/admin/posts/${post.id}`, {
      method: "PATCH",
      body: JSON.stringify({
        kind: post.kind,
        body: post.body,
        authorName: post.authorName,
        organization: post.organization,
        contactEmail: post.contactEmail,
        showAuthorPublicly: post.showAuthorPublicly,
        moderationStatus,
      }),
    });
    moderationMessage.value = moderationStatus === "published" ? "Post published." : moderationStatus === "hidden" ? "Post hidden." : "Post saved for review.";
    await Promise.all([loadModerationPosts(), loadRequests()]);
  } catch (error) {
    moderationError.value = true;
    moderationMessage.value = error instanceof Error ? error.message : "The post could not be saved.";
  } finally {
    moderationBusy.value = false;
  }
}

async function deleteModerationPost(post: CommunityPost) {
  if (!window.confirm(`Permanently delete this ${postKinds[post.kind] || "community post"} from ${post.requestPackageName}?`)) return;
  moderationBusy.value = true;
  moderationError.value = false;
  try {
    await api(`/admin/posts/${post.id}`, { method: "DELETE" });
    moderationMessage.value = "Post deleted.";
    await Promise.all([loadModerationPosts(), loadRequests()]);
  } catch (error) {
    moderationError.value = true;
    moderationMessage.value = error instanceof Error ? error.message : "The post could not be deleted.";
  } finally {
    moderationBusy.value = false;
  }
}

function maintainerDraft(requestId: number) {
  return maintainerDrafts[requestId] ||= {
    kind: "maintainer_update",
    body: "",
    busy: false,
    message: "",
    error: false,
  };
}

async function publishMaintainerPost(request: AdminRequest) {
  const draft = maintainerDraft(request.id);
  draft.busy = true;
  draft.error = false;
  draft.message = "Publishing…";
  try {
    await api(`/admin/requests/${request.id}/posts`, {
      method: "POST",
      body: JSON.stringify({ kind: draft.kind, body: draft.body }),
    });
    draft.body = "";
    draft.message = "Published to the public activity timeline.";
    await loadRequests();
  } catch (error) {
    draft.error = true;
    draft.message = error instanceof Error ? error.message : "The maintainer post could not be published.";
  } finally {
    draft.busy = false;
  }
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
    !window.confirm(
      `Use the ${isPrimaryMatch(match) ? "primary" : "alternative"} ${match.source === "wheel" ? "Python wheel" : "zopen RPM"} ` +
      `${match.packageName} ${match.version} and mark ${match.requestPackageName} available?`,
    )
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
        ownerGithubLogin: request.ownerGithubLogin,
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

        <div v-if="orderedPulpMatches.length" class="match-list">
          <article v-for="match in orderedPulpMatches" :key="`${match.requestId}:${match.source}`" class="match-card">
            <div>
              <div class="match-labels">
                <span class="source-badge">{{ match.source === "rpm" ? "zopen RPM" : "Python wheel" }}</span>
                <span :class="['preference-badge', { primary: isPrimaryMatch(match) }]">
                  {{ isPrimaryMatch(match) ? `Primary for ${ecosystems[matchEcosystem(match)] || matchEcosystem(match)}` : "Alternative format" }}
                </span>
              </div>
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
              <button class="primary" type="button" :disabled="pulpBusy" @click="reviewPulpMatch(match, 'approve')">
                {{ isPrimaryMatch(match) ? "Apply primary and mark available" : "Use alternative and mark available" }}
              </button>
            </div>
          </article>
        </div>
        <p v-else class="no-matches">No Pulp matches need review.</p>
      </section>

      <section class="moderation-panel">
        <div class="moderation-heading">
          <div>
            <p class="eyebrow">Community discussion</p>
            <h2>Moderation queue <span v-if="pendingPostTotal" class="pending-total">{{ pendingPostTotal }}</span></h2>
            <p>Review community contributions before they appear in public request timelines.</p>
          </div>
          <div class="filters">
            <select v-model="moderationFilter" aria-label="Filter community posts" @change="loadModerationPosts">
              <option value="pending">Pending review</option>
              <option value="published">Published</option>
              <option value="hidden">Hidden</option>
              <option value="all">All posts</option>
            </select>
            <button class="secondary" type="button" :disabled="moderationBusy" @click="loadModerationPosts">Refresh</button>
          </div>
        </div>
        <p v-if="moderationMessage" :class="['sync-message', { error: moderationError }]" role="status">{{ moderationMessage }}</p>

        <div v-if="moderationPosts.length" class="moderation-list">
          <article v-for="post in moderationPosts" :key="post.id" class="moderation-card">
            <div class="moderation-card-heading">
              <div>
                <span class="source-badge">{{ postKinds[post.kind] || post.kind }}</span>
                <h3>{{ post.requestPackageName }}</h3>
              </div>
              <span :class="['moderation-status', `moderation-${post.moderationStatus}`]">{{ post.moderationStatus }}</span>
            </div>
            <div class="moderation-editor">
              <label>
                <span>Contribution type</span>
                <select v-model="post.kind">
                  <option value="use_case">Use case</option>
                  <option value="testing_offer">Testing offer</option>
                  <option value="contribution_offer">Contribution offer</option>
                  <option value="technical_note">Technical information</option>
                  <option value="question">Question</option>
                  <option v-if="post.authorRole === 'maintainer'" value="maintainer_update">Maintainer update</option>
                </select>
              </label>
              <label class="wide"><span>Post body</span><textarea v-model.trim="post.body" minlength="2" maxlength="2000" /></label>
              <label><span>Author name or alias</span><input v-model.trim="post.authorName" maxlength="100" /></label>
              <label><span>Organization</span><input v-model.trim="post.organization" maxlength="160" /></label>
              <label><span>Contact email (private)</span><input v-model.trim="post.contactEmail" type="email" maxlength="254" /></label>
              <label><span>Public attribution</span><select v-model="post.showAuthorPublicly"><option :value="false">Hidden</option><option :value="true">Show name and organization</option></select></label>
            </div>
            <div class="moderation-meta">
              Submitted {{ new Date(post.createdAt).toLocaleString() }}
              <span v-if="post.authorRole === 'maintainer'"> · Verified maintainer post</span>
            </div>
            <div class="moderation-actions">
              <button class="danger" type="button" :disabled="moderationBusy" @click="deleteModerationPost(post)">Delete</button>
              <button class="secondary" type="button" :disabled="moderationBusy" @click="moderatePost(post, 'hidden')">Hide</button>
              <button class="secondary" type="button" :disabled="moderationBusy" @click="moderatePost(post, 'pending')">Keep pending</button>
              <button class="primary" type="button" :disabled="moderationBusy" @click="moderatePost(post, 'published')">Publish</button>
            </div>
          </article>
        </div>
        <p v-else class="no-matches">No {{ moderationFilter === "all" ? "" : moderationFilter }} community posts.</p>
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
                <span>{{ request.discussionCount || 0 }} public posts</span>
                <span v-if="request.pendingPostCount" class="pending-request-posts">{{ request.pendingPostCount }} awaiting review</span>
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
              <label class="wide"><span>Request description</span><textarea v-model.trim="request.description" minlength="2" maxlength="1200" required /></label>
              <label><span>Use case or version</span><textarea v-model.trim="request.useCase" maxlength="1200" /></label>
              <label><span>Can help test</span><select v-model="request.canHelpTest"><option :value="false">No</option><option :value="true">Yes</option></select></label>
              <label><span>Requester name or alias</span><input v-model.trim="request.requesterName" maxlength="100" /></label>
              <label><span>Organization or company</span><input v-model.trim="request.organization" maxlength="160" /></label>
              <label><span>Contact email (private)</span><input v-model.trim="request.contactEmail" type="email" maxlength="254" /></label>
              <label><span>Public requester attribution</span><select v-model="request.showRequesterPublicly"><option :value="false">Hidden</option><option :value="true">Show name and organization</option></select></label>
              <label><span>GitHub owner login</span><input v-model.trim="request.ownerGithubLogin" maxlength="80" placeholder="Must sign in once before assignment" /></label>
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
            <form class="maintainer-composer" @submit.prevent="publishMaintainerPost(request)">
              <div>
                <strong>Post to the public activity timeline</strong>
                <span>Published immediately with a verified maintainer badge.</span>
              </div>
              <div class="maintainer-compose-grid">
                <select v-model="maintainerDraft(request.id).kind" aria-label="Maintainer post type">
                  <option value="maintainer_update">Maintainer update</option>
                  <option value="question">Question for the community</option>
                  <option value="technical_note">Technical information</option>
                </select>
                <textarea
                  v-model.trim="maintainerDraft(request.id).body"
                  required
                  minlength="2"
                  maxlength="2000"
                  placeholder="Share progress, ask a question, or add technical guidance."
                />
              </div>
              <div class="maintainer-compose-actions">
                <span :class="['save-state', { error: maintainerDraft(request.id).error }]" role="status">{{ maintainerDraft(request.id).message }}</span>
                <button class="primary" type="submit" :disabled="maintainerDraft(request.id).busy">Publish update</button>
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
.admin-heading,.toolbar,.token-row,.filters,.title-row,.meta,.editor-actions,.pulp-heading,.match-card,.match-actions,.moderation-heading,.moderation-card-heading,.moderation-actions,.maintainer-compose-actions { display:flex; }
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
.match-labels { display:flex; flex-wrap:wrap; align-items:center; gap:8px; }
.source-badge { color:var(--vp-c-brand-1); font-size:11px; font-weight:800; letter-spacing:.05em; text-transform:uppercase; }
.preference-badge { padding:3px 7px; border:1px solid var(--vp-c-divider); border-radius:999px; color:var(--vp-c-text-3); font-size:10px; font-weight:750; text-transform:uppercase; }
.preference-badge.primary { color:#09634f; border-color:#85cdbd; background:#e7f8f3; }
.dark .preference-badge.primary { color:#a8e6d6; border-color:#275e52; background:#142d28; }
.match-actions { flex-shrink:0; gap:8px; }
.no-matches { margin:16px 0 0; color:var(--vp-c-text-2); }
.moderation-panel { margin-bottom:34px; padding:22px; border:1px solid var(--vp-c-divider); border-radius:14px; background:var(--vp-c-bg-soft); }
.moderation-heading { justify-content:space-between; align-items:end; gap:20px; }
.moderation-heading h2 { margin:0; }
.moderation-heading p { margin:6px 0 0; color:var(--vp-c-text-2); }
.pending-total { display:inline-flex; min-width:24px; height:24px; align-items:center; justify-content:center; margin-left:5px; border-radius:999px; color:white; background:var(--vp-c-danger-1); font-size:12px; vertical-align:middle; }
.moderation-list { display:grid; gap:12px; margin-top:18px; }
.moderation-card { padding:17px; border:1px solid var(--vp-c-divider); border-radius:10px; background:var(--vp-c-bg); }
.moderation-card-heading { align-items:flex-start; justify-content:space-between; gap:15px; }
.moderation-card-heading h3 { margin:4px 0 0; }
.moderation-status { padding:4px 8px; border-radius:999px; color:var(--vp-c-text-2); background:var(--vp-c-default-soft); font-size:10px; font-weight:800; text-transform:uppercase; }
.moderation-pending { color:#795b00; background:#fff1bd; }
.moderation-published { color:#09634f; background:#daf4ec; }
.moderation-hidden { color:var(--vp-c-danger-1); background:var(--vp-c-danger-soft); }
.dark .moderation-pending,.dark .moderation-published { color:var(--vp-c-text-1); background:var(--vp-c-bg-alt); }
.moderation-editor { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-top:15px; }
.moderation-editor label > span { display:block; margin-bottom:5px; color:var(--vp-c-text-2); font-size:11px; font-weight:700; }
.moderation-editor .wide { grid-column:1/-1; }
.moderation-meta { margin-top:10px; color:var(--vp-c-text-3); font-size:11px; }
.moderation-actions { justify-content:flex-end; align-items:center; gap:9px; margin-top:14px; }
.pending-request-posts { color:var(--vp-c-danger-1); font-weight:800; }
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
.maintainer-composer { padding:18px 20px 22px; border-top:1px solid var(--vp-c-divider); background:var(--vp-c-bg); }
.maintainer-composer > div:first-child strong,.maintainer-composer > div:first-child span { display:block; }
.maintainer-composer > div:first-child span { margin-top:3px; color:var(--vp-c-text-2); font-size:12px; }
.maintainer-compose-grid { display:grid; grid-template-columns:220px minmax(0,1fr); gap:12px; margin-top:13px; }
.maintainer-compose-grid textarea { min-height:84px; }
.maintainer-compose-actions { align-items:center; justify-content:flex-end; gap:12px; margin-top:10px; }
.save-state { color:var(--vp-c-text-2); font-size:13px; }
.error { color:var(--vp-c-danger-1); }
.empty { padding:60px; border:1px dashed var(--vp-c-divider); border-radius:14px; color:var(--vp-c-text-2); text-align:center; }
@media (max-width:720px) { .toolbar,.token-row,.pulp-heading,.match-card,.moderation-heading { align-items:stretch; flex-direction:column; } .filters,.match-actions,.moderation-actions { flex-direction:column; } .filters select { width:100%; } .editor,.moderation-editor,.maintainer-compose-grid { grid-template-columns:1fr; } .wide,.editor-actions,.moderation-editor .wide { grid-column:1; } .moderation-actions button { width:100%; } }
</style>
