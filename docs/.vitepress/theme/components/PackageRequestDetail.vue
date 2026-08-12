<script setup lang="ts">
import { computed, onMounted, reactive, ref } from "vue";
import { withBase } from "vitepress";

type RequestStatus = "proposed" | "under_review" | "accepted" | "in_progress" | "available" | "declined";

interface RequestSummary {
  id: number;
  packageName: string;
  ecosystem: string;
  status: RequestStatus;
}

interface PackageRequest extends RequestSummary {
  upstreamUrl: string;
  description: string;
  useCase: string;
  canHelpTest: boolean;
  requesterName: string;
  organization: string;
  githubRequester: { login: string; profileUrl: string } | null;
  portRepositoryUrl: string;
  artifactKind: string;
  artifactUrl: string;
  installCommand: string;
  packageVersion: string;
  packageArchitecture: string;
  runtimeCompatibility: string;
  zosCompatibility: string;
  installationNotes: string;
  verificationCommand: string;
  artifactLastSyncedAt: string | null;
  maintainerNote: string;
  acknowledgedAt: string | null;
  availableAt: string | null;
  voteCount: number;
  voted: boolean;
  discussionCount: number;
  ownedByCurrentUser: boolean;
  createdAt: string;
  updatedAt: string;
}

interface ActivityItem {
  id: string | number;
  type: "created" | "status" | "edit" | "post";
  kind?: string;
  body?: string;
  authorRole?: "community" | "maintainer";
  authorName?: string;
  organization?: string;
  githubAuthor?: { login: string; profileUrl: string } | null;
  fromStatus?: RequestStatus;
  toStatus?: RequestStatus;
  note?: string;
  createdAt: string;
}

interface GithubUser { login: string; avatarUrl: string; profileUrl: string; }

const productionApiUrl = "https://usage.zopen.community/package-requests/api";
const apiUrl = String(
  import.meta.env.VITE_PACKAGE_REQUESTS_API_URL || (import.meta.env.PROD ? productionApiUrl : "http://127.0.0.1:3100/api"),
).replace(/\/$/, "");
const request = ref<PackageRequest | null>(null);
const relationships = ref<Record<string, RequestSummary[]>>({
  dependsOn: [], blocks: [], related: [], duplicateOf: [], duplicates: [],
});
const activity = ref<ActivityItem[]>([]);
const authUser = ref<GithubUser | null>(null);
const githubEnabled = ref(false);
const loading = ref(true);
const error = ref("");
const activityError = ref("");
const voteBusy = ref(false);
const shareMessage = ref("");
const copiedCommand = ref<"install" | "verify" | "">("");
const postOpen = ref(false);
const postBusy = ref(false);
const postMessage = ref("");
const postError = ref("");
const postForm = reactive({
  kind: "use_case",
  body: "",
  authorName: "",
  organization: "",
  contactEmail: "",
  showAuthorPublicly: false,
  showGithubPublicly: false,
  website: "",
});

const ecosystems: Record<string, string> = {
  general: "General / CLI", python: "Python / PyPI", c_cpp: "C / C++", rust: "Rust / Cargo",
  go: "Go module", java: "Java / JVM", javascript: "JavaScript / npm", shell: "Shell", other: "Other",
};
const statuses: Record<RequestStatus, { label: string; detail: string }> = {
  proposed: { label: "Proposed", detail: "Awaiting initial maintainer review" },
  under_review: { label: "Under review", detail: "Maintainers are evaluating scope and feasibility" },
  accepted: { label: "Accepted", detail: "Accepted into the community backlog" },
  in_progress: { label: "In progress", detail: "Porting or packaging work is underway" },
  available: { label: "Available", detail: "A package or port is available" },
  declined: { label: "Declined", detail: "Not currently planned" },
};
const postKinds: Record<string, string> = {
  use_case: "Use case", testing_offer: "Testing offer", contribution_offer: "Contribution offer",
  technical_note: "Technical information", question: "Question", maintainer_update: "Maintainer update",
};
const progressStatuses: RequestStatus[] = ["proposed", "under_review", "accepted", "in_progress", "available"];

const requestId = computed(() => {
  if (typeof window === "undefined") return 0;
  const value = new URLSearchParams(window.location.search).get("request") || "";
  return Number.parseInt(value.match(/^\d+/)?.[0] || "0", 10);
});
const relationSections = computed(() => [
  { key: "dependsOn", title: "Depends on", description: "These requests need to be available or resolved first." },
  { key: "blocks", title: "Blocks", description: "These requests depend on this package." },
  { key: "related", title: "Related requests", description: "Packages with connected use cases or implementation work." },
  { key: "duplicateOf", title: "Duplicate of", description: "This request is represented by another request." },
  { key: "duplicates", title: "Duplicate requests", description: "These requests have been linked back to this one." },
].filter((section) => (relationships.value[section.key] || []).length));

async function copyCommand(value: string, kind: "install" | "verify") {
  await navigator.clipboard.writeText(value);
  copiedCommand.value = kind;
  window.setTimeout(() => { if (copiedCommand.value === kind) copiedCommand.value = ""; }, 1800);
}

function getVoterId() {
  const key = "zopen-package-request-voter-id";
  let value = localStorage.getItem(key);
  if (!value) {
    value = crypto.randomUUID();
    localStorage.setItem(key, value);
  }
  return value;
}

async function api(path: string, options: RequestInit = {}) {
  const headers = new Headers(options.headers);
  headers.set("Content-Type", "application/json");
  headers.set("X-Voter-ID", getVoterId());
  const response = await fetch(`${apiUrl}${path}`, { ...options, headers, credentials: "include" });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error || "The request could not be completed.");
  return body;
}

function slug(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

function detailUrl(item: RequestSummary) {
  return withBase(`/PackageRequest?request=${item.id}-${slug(item.packageName)}`);
}

function displayDate(value: string) {
  return new Date(value).toLocaleString(undefined, { dateStyle: "medium", timeStyle: "short" });
}

function statusLabel(value?: RequestStatus) {
  return value ? statuses[value]?.label || value : "Unknown";
}

function textSegments(value = "") {
  const segments: Array<{ text: string; url?: string }> = [];
  const pattern = /https?:\/\/[^\s<>]+/gi;
  let position = 0;
  for (const match of value.matchAll(pattern)) {
    if (match.index! > position) segments.push({ text: value.slice(position, match.index) });
    let url = match[0];
    const punctuation = url.match(/[),.;!?]+$/)?.[0] || "";
    if (punctuation) url = url.slice(0, -punctuation.length);
    segments.push({ text: url, url });
    if (punctuation) segments.push({ text: punctuation });
    position = match.index! + match[0].length;
  }
  if (position < value.length) segments.push({ text: value.slice(position) });
  return segments;
}

async function loadRequest() {
  if (!requestId.value) {
    error.value = "This request link is invalid.";
    loading.value = false;
    return;
  }
  loading.value = true;
  error.value = "";
  try {
    let result;
    try {
      result = await api(`/requests/${requestId.value}`);
    } catch (detailError) {
      const fallback = await api("/requests?sort=newest");
      const fallbackRequest = fallback.requests?.find((item: PackageRequest) => item.id === requestId.value);
      if (!fallbackRequest) throw detailError;
      result = { request: fallbackRequest, relationships: relationships.value };
    }
    request.value = result.request;
    relationships.value = result.relationships;
    document.title = `${result.request.packageName} package request · zopen community`;
  } catch (caught) {
    error.value = caught instanceof Error ? caught.message : "The package request could not be loaded.";
  } finally {
    loading.value = false;
  }
}

async function loadActivity() {
  if (!requestId.value) return;
  activityError.value = "";
  try {
    activity.value = (await api(`/requests/${requestId.value}/activity`)).activity;
  } catch (caught) {
    activityError.value = caught instanceof Error ? caught.message : "Activity could not be loaded.";
  }
}

async function loadAuthentication() {
  try {
    githubEnabled.value = Boolean((await api("/auth/config")).githubEnabled);
    if (githubEnabled.value) {
      authUser.value = (await api("/auth/me")).user || null;
      postForm.showGithubPublicly = Boolean(authUser.value);
    }
  } catch {
    githubEnabled.value = false;
  }
}

async function toggleVote() {
  if (!request.value || voteBusy.value) return;
  voteBusy.value = true;
  try {
    const result = await api(`/requests/${request.value.id}/vote`, {
      method: request.value.voted ? "DELETE" : "PUT",
      body: JSON.stringify({ voterId: getVoterId() }),
    });
    request.value.voted = result.voted;
    request.value.voteCount = result.voteCount;
  } catch (caught) {
    error.value = caught instanceof Error ? caught.message : "Your vote could not be saved.";
  } finally {
    voteBusy.value = false;
  }
}

async function shareRequest() {
  try {
    await navigator.clipboard.writeText(window.location.href);
    shareMessage.value = "Link copied.";
  } catch {
    shareMessage.value = "Copy the URL from your browser to share this request.";
  }
}

function signIn() {
  window.location.assign(`${apiUrl}/auth/github?returnTo=${encodeURIComponent(window.location.href)}`);
}

function savePostToken(postId: number, token: string) {
  let tokens: Record<string, string> = {};
  try { tokens = JSON.parse(localStorage.getItem("zopen-package-post-edit-tokens") || "{}"); } catch { /* empty */ }
  tokens[String(postId)] = token;
  localStorage.setItem("zopen-package-post-edit-tokens", JSON.stringify(tokens));
}

async function submitPost() {
  if (!request.value) return;
  postBusy.value = true;
  postError.value = "";
  postMessage.value = "";
  try {
    const result = await api(`/requests/${request.value.id}/posts`, { method: "POST", body: JSON.stringify(postForm) });
    if (result.post?.id && result.editToken) savePostToken(result.post.id, result.editToken);
    postMessage.value = "Your contribution is awaiting maintainer review.";
    postForm.body = "";
    postOpen.value = false;
  } catch (caught) {
    postError.value = caught instanceof Error ? caught.message : "Your contribution could not be submitted.";
  } finally {
    postBusy.value = false;
  }
}

onMounted(async () => {
  const query = new URLSearchParams(window.location.search);
  if (query.has("auth")) {
    query.delete("auth");
    window.history.replaceState({}, "", `${window.location.pathname}?${query}${window.location.hash}`);
  }
  await Promise.all([loadRequest(), loadActivity(), loadAuthentication()]);
});
</script>

<template>
  <main class="request-detail">
    <a class="back-link" :href="withBase('/PackageRequests')">← All package requests</a>

    <div v-if="loading" class="loading-card">Loading package request…</div>
    <section v-else-if="error && !request" class="error-card">
      <h1>Request unavailable</h1><p>{{ error }}</p>
      <a class="primary-action" :href="withBase('/PackageRequests')">Browse package requests</a>
    </section>

    <template v-else-if="request">
      <header class="detail-hero">
        <div class="hero-main">
          <div class="labels">
            <span class="ecosystem-label">{{ ecosystems[request.ecosystem] || request.ecosystem }}</span>
            <span :class="['status-label', `status-${request.status}`]">{{ statuses[request.status].label }}</span>
          </div>
          <h1>{{ request.packageName }}</h1>
          <p class="description">{{ request.description }}</p>
          <div class="byline">
            <span v-if="request.githubRequester">Submitted by <a :href="request.githubRequester.profileUrl" target="_blank" rel="noopener noreferrer">@{{ request.githubRequester.login }} ↗</a></span>
            <span v-else-if="request.requesterName || request.organization">Requested by {{ [request.requesterName, request.organization].filter(Boolean).join(" · ") }}</span>
            <span>Requested {{ new Date(request.createdAt).toLocaleDateString(undefined, { dateStyle: "medium" }) }}</span>
          </div>
        </div>
        <aside class="hero-actions">
          <button class="vote-action" type="button" :class="{ voted: request.voted }" :disabled="voteBusy" @click="toggleVote">
            <span aria-hidden="true">▲</span><strong>{{ request.voteCount }}</strong>{{ request.voted ? "Voted" : "Vote" }}
          </button>
          <button class="secondary-action" type="button" @click="shareRequest">Share request</button>
          <small v-if="shareMessage">{{ shareMessage }}</small>
        </aside>
      </header>

      <p v-if="error" class="inline-error">{{ error }}</p>

      <section class="progress-card">
        <div class="section-heading"><div><span>Current status</span><h2>{{ statuses[request.status].label }}</h2></div><p>{{ statuses[request.status].detail }}</p></div>
        <ol v-if="request.status !== 'declined'" class="status-progress">
          <li v-for="(step, index) in progressStatuses" :key="step" :class="{ reached: index <= progressStatuses.indexOf(request.status) }">
            <span>{{ index + 1 }}</span><strong>{{ statuses[step].label }}</strong>
          </li>
        </ol>
        <p v-if="request.maintainerNote" class="maintainer-note"><strong>Latest maintainer update</strong>{{ request.maintainerNote }}</p>
      </section>

      <div class="detail-grid">
        <section class="content-card">
          <span class="section-kicker">Request details</span>
          <h2>Why this package matters</h2>
          <p>{{ request.description }}</p>
          <div v-if="request.useCase" class="detail-block"><h3>Use case or version requirements</h3><p>{{ request.useCase }}</p></div>
          <div class="detail-flags">
            <span v-if="request.canHelpTest">Testing help offered</span>
            <a v-if="request.upstreamUrl" :href="request.upstreamUrl" target="_blank" rel="noopener noreferrer">Upstream project ↗</a>
          </div>
        </section>

        <section class="content-card delivery-card">
          <span class="section-kicker">Delivery</span><h2>{{ request.status === 'available' ? 'Package available' : 'Porting outcome' }}</h2>
          <div v-if="request.status === 'available' && (request.packageVersion || request.packageArchitecture || request.runtimeCompatibility || request.zosCompatibility)" class="install-metadata">
            <span v-if="request.packageVersion"><small>Version</small><strong>{{ request.packageVersion }}</strong></span>
            <span v-if="request.packageArchitecture"><small>Architecture</small><strong>{{ request.packageArchitecture }}</strong></span>
            <span v-if="request.runtimeCompatibility"><small>Runtime</small><strong>{{ request.runtimeCompatibility }}</strong></span>
            <span v-if="request.zosCompatibility"><small>z/OS</small><strong>{{ request.zosCompatibility }}</strong></span>
          </div>
          <div v-if="request.status === 'available' && request.installCommand" class="command-block">
            <div><strong>Install</strong><button type="button" @click="copyCommand(request.installCommand, 'install')">{{ copiedCommand === 'install' ? 'Copied' : 'Copy' }}</button></div>
            <pre><code>{{ request.installCommand }}</code></pre>
          </div>
          <div v-if="request.status === 'available' && request.verificationCommand" class="command-block">
            <div><strong>Verify</strong><button type="button" @click="copyCommand(request.verificationCommand, 'verify')">{{ copiedCommand === 'verify' ? 'Copied' : 'Copy' }}</button></div>
            <pre><code>{{ request.verificationCommand }}</code></pre>
          </div>
          <p v-if="request.installationNotes" class="installation-notes">{{ request.installationNotes }}</p>
          <a v-if="request.portRepositoryUrl" :href="request.portRepositoryUrl" target="_blank" rel="noopener noreferrer">View zopen port repository ↗</a>
          <a v-if="request.artifactUrl" :href="request.artifactUrl" target="_blank" rel="noopener noreferrer">Open published package ↗</a>
          <p v-if="!request.portRepositoryUrl && !request.artifactUrl">No port repository or package artifact has been published yet.</p>
        </section>
      </div>

      <section v-if="relationSections.length" class="relationships-card">
        <span class="section-kicker">Package relationships</span><h2>Dependencies and related work</h2>
        <div class="relationship-sections">
          <div v-for="section in relationSections" :key="section.key" class="relationship-section">
            <div><h3>{{ section.title }}</h3><p>{{ section.description }}</p></div>
            <div class="relationship-list">
              <a v-for="item in relationships[section.key]" :key="item.id" :href="detailUrl(item)" class="relationship-item">
                <span><strong>{{ item.packageName }}</strong><small>{{ ecosystems[item.ecosystem] || item.ecosystem }}</small></span>
                <span :class="['mini-status', `status-${item.status}`]">{{ statuses[item.status].label }}</span>
              </a>
            </div>
          </div>
        </div>
      </section>

      <section class="activity-card">
        <div class="activity-heading">
          <div><span class="section-kicker">Open collaboration</span><h2>Discussion and activity</h2></div>
          <button class="secondary-action" type="button" @click="loadActivity">Refresh</button>
        </div>
        <p v-if="activityError" class="inline-error">{{ activityError }}</p>
        <ol v-else class="timeline">
          <li v-for="item in activity" :key="`${item.type}-${item.id}`">
            <span class="timeline-marker" aria-hidden="true" />
            <div>
              <template v-if="item.type === 'created'"><strong>Request submitted</strong></template>
              <template v-else-if="item.type === 'status'"><strong>Status changed to {{ statusLabel(item.toStatus) }}</strong><p v-if="item.note">{{ item.note }}</p></template>
              <template v-else-if="item.type === 'edit'"><strong>Request details updated</strong></template>
              <template v-else>
                <div class="post-labels"><span>{{ postKinds[item.kind || ''] || item.kind }}</span><b v-if="item.authorRole === 'maintainer'">Verified maintainer</b></div>
                <p class="post-body"><template v-for="(segment, index) in textSegments(item.body)" :key="index"><a v-if="segment.url" :href="segment.url" target="_blank" rel="noopener noreferrer">{{ segment.text }}</a><template v-else>{{ segment.text }}</template></template></p>
                <small v-if="item.githubAuthor">Posted by <a :href="item.githubAuthor.profileUrl" target="_blank" rel="noopener noreferrer">@{{ item.githubAuthor.login }} ↗</a></small>
                <small v-else-if="item.authorName || item.organization">{{ [item.authorName, item.organization].filter(Boolean).join(" · ") }}</small>
              </template>
              <time :datetime="item.createdAt">{{ displayDate(item.createdAt) }}</time>
            </div>
          </li>
        </ol>

        <p v-if="postMessage" class="success-message">{{ postMessage }}</p>
        <button v-if="!postOpen" class="secondary-action" type="button" @click="postOpen = true">Add information or offer help</button>
        <form v-else class="post-form" @submit.prevent="submitPost">
          <div class="post-form-heading"><h3>Add to the discussion</h3><button type="button" aria-label="Close" @click="postOpen = false">×</button></div>
          <label><span>Contribution type</span><select v-model="postForm.kind"><option value="use_case">Additional use case</option><option value="testing_offer">Offer to test</option><option value="contribution_offer">Offer to contribute</option><option value="technical_note">Technical information</option><option value="question">Question</option></select></label>
          <label><span>Your contribution</span><textarea v-model.trim="postForm.body" required minlength="2" maxlength="2000" rows="4" /></label>
          <div class="post-grid"><label><span>Name or alias <small>Optional</small></span><input v-model.trim="postForm.authorName" maxlength="100" /></label><label><span>Organization <small>Optional</small></span><input v-model.trim="postForm.organization" maxlength="160" /></label></div>
          <label><span>Contact email <small>Private—maintainers only</small></span><input v-model.trim="postForm.contactEmail" type="email" maxlength="254" /></label>
          <label class="check"><input v-model="postForm.showAuthorPublicly" type="checkbox" /><span>Show my name and organization publicly.</span></label>
          <label v-if="authUser" class="check"><input v-model="postForm.showGithubPublicly" type="checkbox" /><span>Show “Posted by @{{ authUser.login }}” with my GitHub profile.</span></label>
          <label class="honeypot" aria-hidden="true"><span>Website</span><input v-model="postForm.website" tabindex="-1" /></label>
          <p v-if="postError" class="inline-error">{{ postError }}</p>
          <div class="form-actions"><button class="secondary-action" type="button" @click="postOpen = false">Cancel</button><button class="primary-action" type="submit" :disabled="postBusy">{{ postBusy ? "Submitting…" : "Submit for review" }}</button></div>
        </form>
      </section>

      <section v-if="githubEnabled" class="identity-footer">
        <template v-if="authUser"><span>Signed in as <strong>@{{ authUser.login }}</strong></span><a :href="`${withBase('/PackageRequests')}#package-request-${request.id}`">Manage your request and contributions</a></template>
        <template v-else><span>Sign in to keep ownership of new contributions across devices.</span><button class="secondary-action" type="button" @click="signIn">Sign in with GitHub</button></template>
      </section>
    </template>
  </main>
</template>

<style scoped>
.request-detail{--accent:#0f7f6f;--accent-soft:#eaf6f3;max-width:1120px;margin:0 auto;padding:36px 28px 80px;color:var(--vp-c-text-1)}
.back-link{display:inline-flex;margin-bottom:24px;color:var(--accent);font-weight:700;text-decoration:none}.back-link:hover{text-decoration:underline}
.loading-card,.error-card,.content-card,.progress-card,.relationships-card,.activity-card{border:1px solid var(--vp-c-divider);border-radius:16px;background:var(--vp-c-bg);padding:28px}
.error-card{text-align:center}.error-card h1{margin-top:0}.detail-hero{display:flex;justify-content:space-between;gap:36px;padding:36px;border:1px solid color-mix(in srgb,var(--accent) 55%,var(--vp-c-divider));border-radius:18px;background:linear-gradient(135deg,var(--accent-soft),var(--vp-c-bg) 62%)}
:global(.dark) .detail-hero{--accent-soft:#123c36}.hero-main{min-width:0}.labels,.byline,.detail-flags,.post-labels{display:flex;flex-wrap:wrap;gap:9px 14px;align-items:center}.ecosystem-label,.status-label,.mini-status{display:inline-flex;border-radius:999px;padding:5px 10px;font-size:12px;font-weight:800}.ecosystem-label{background:var(--accent-soft);color:var(--accent)}.status-label,.mini-status{background:var(--vp-c-bg-soft);color:var(--vp-c-text-2)}.status-available{background:#e5f5e8;color:#276738}.status-in_progress{background:#fff1cc;color:#765700}.status-declined{background:#f4e8e8;color:#8a3434}
.detail-hero h1{margin:12px 0 8px;font-size:clamp(34px,6vw,58px);line-height:1.02;overflow-wrap:anywhere}.description{max-width:720px;margin:0 0 20px;color:var(--vp-c-text-2);font-size:18px;line-height:1.6}.byline{color:var(--vp-c-text-3);font-size:13px}.byline a,.detail-flags a,.delivery-card a,.timeline a,.identity-footer a{color:var(--accent);font-weight:700}
.hero-actions{display:flex;min-width:150px;flex-direction:column;gap:10px}.vote-action,.primary-action,.secondary-action{display:inline-flex;align-items:center;justify-content:center;gap:7px;border-radius:9px;padding:10px 14px;font:inherit;font-weight:750;cursor:pointer;text-decoration:none}.vote-action{min-height:94px;flex-direction:column;border:1px solid var(--accent);background:var(--vp-c-bg);color:var(--accent)}.vote-action strong{font-size:25px}.vote-action.voted,.primary-action{border:1px solid var(--accent);background:var(--accent);color:#fff}.secondary-action{border:1px solid var(--vp-c-divider);background:var(--vp-c-bg);color:var(--vp-c-text-1)}button:disabled{cursor:wait;opacity:.6}.hero-actions small{text-align:center;color:var(--vp-c-text-3)}
.progress-card,.relationships-card,.activity-card{margin-top:20px}.section-heading,.activity-heading{display:flex;align-items:flex-end;justify-content:space-between;gap:25px}.section-heading span,.section-kicker{color:var(--accent);font-size:12px;font-weight:800;letter-spacing:.08em;text-transform:uppercase}.section-heading h2,.relationships-card h2,.activity-card h2,.content-card h2{margin:4px 0 0}.section-heading>p{max-width:480px;margin:0;color:var(--vp-c-text-2)}.status-progress{display:grid;grid-template-columns:repeat(5,1fr);padding:0;margin:28px 0 0;list-style:none}.status-progress li{position:relative;display:flex;align-items:center;gap:8px;color:var(--vp-c-text-3);font-size:12px}.status-progress li:not(:last-child)::after{position:absolute;z-index:0;top:14px;left:30px;width:calc(100% - 30px);height:2px;background:var(--vp-c-divider);content:""}.status-progress span{z-index:1;display:grid;width:28px;height:28px;place-items:center;border-radius:50%;background:var(--vp-c-bg-soft);font-weight:800}.status-progress .reached{color:var(--accent)}.status-progress .reached span,.status-progress .reached:not(:last-child)::after{background:var(--accent);color:#fff}.maintainer-note{display:flex;flex-direction:column;gap:4px;margin:24px 0 0;padding:16px;border-left:4px solid var(--accent);background:var(--accent-soft)}
.detail-grid{display:grid;grid-template-columns:1.6fr 1fr;gap:20px;margin-top:20px}.content-card p{color:var(--vp-c-text-2);line-height:1.65}.detail-block{margin-top:22px}.detail-block h3{margin-bottom:5px;font-size:15px}.detail-flags{margin-top:22px}.detail-flags span{color:var(--accent);font-weight:700}.delivery-card{display:flex;align-items:flex-start;flex-direction:column;gap:12px}.delivery-card h2{margin-bottom:8px}.delivery-card a{display:block;padding:11px 13px;border:1px solid var(--vp-c-divider);border-radius:9px;width:100%;text-decoration:none}
.install-metadata{display:grid;width:100%;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px}.install-metadata span{display:flex;min-width:0;flex-direction:column;padding:9px 11px;border-radius:8px;background:var(--vp-c-bg-soft)}.install-metadata small{color:var(--vp-c-text-3)}.install-metadata strong{overflow-wrap:anywhere;font-size:13px}.command-block{width:100%;overflow:hidden;border:1px solid var(--vp-c-divider);border-radius:9px}.command-block>div{display:flex;align-items:center;justify-content:space-between;padding:8px 10px;background:var(--vp-c-bg-soft)}.command-block button{border:0;background:transparent;color:var(--accent);font-weight:800;cursor:pointer}.command-block pre{overflow:auto;margin:0;padding:12px;font-size:12px;white-space:pre}.installation-notes{margin:0;white-space:pre-wrap}
.relationship-sections{display:grid;gap:20px;margin-top:22px}.relationship-section{display:grid;grid-template-columns:minmax(190px,.7fr) 1.5fr;gap:24px;padding-top:20px;border-top:1px solid var(--vp-c-divider)}.relationship-section h3,.relationship-section p{margin:0}.relationship-section p{margin-top:4px;color:var(--vp-c-text-3);font-size:13px}.relationship-list{display:grid;gap:8px}.relationship-item{display:flex;align-items:center;justify-content:space-between;gap:15px;padding:12px 14px;border:1px solid var(--vp-c-divider);border-radius:10px;color:inherit;text-decoration:none}.relationship-item:hover{border-color:var(--accent)}.relationship-item span:first-child{display:flex;flex-direction:column}.relationship-item small{color:var(--vp-c-text-3)}
.activity-heading{align-items:center}.timeline{padding:0;margin:25px 0;list-style:none}.timeline li{position:relative;display:grid;grid-template-columns:18px 1fr;gap:12px;padding-bottom:23px}.timeline li:not(:last-child)::before{position:absolute;top:13px;bottom:0;left:5px;width:2px;background:var(--vp-c-divider);content:""}.timeline-marker{z-index:1;width:12px;height:12px;margin-top:5px;border:3px solid var(--vp-c-bg);border-radius:50%;background:var(--accent);box-shadow:0 0 0 1px var(--accent)}.timeline p{margin:7px 0;white-space:pre-wrap}.timeline time,.timeline small{display:block;margin-top:6px;color:var(--vp-c-text-3);font-size:12px}.post-labels span,.post-labels b{border-radius:999px;padding:3px 7px;background:var(--vp-c-bg-soft);font-size:11px}.post-labels b{background:var(--accent-soft);color:var(--accent)}.success-message{padding:12px;border-radius:8px;background:#e5f5e8;color:#276738}.inline-error{padding:11px;border-radius:8px;background:#f8e9e9;color:#8a3434}
.post-form{display:grid;gap:15px;margin-top:18px;padding:22px;border:1px solid var(--vp-c-divider);border-radius:12px;background:var(--vp-c-bg-soft)}.post-form-heading{display:flex;align-items:center;justify-content:space-between}.post-form-heading h3{margin:0}.post-form-heading button{border:0;background:transparent;font-size:24px;cursor:pointer}.post-form label:not(.check):not(.honeypot){display:grid;gap:6px;font-size:13px;font-weight:700}.post-form input,.post-form select,.post-form textarea{width:100%;border:1px solid var(--vp-c-divider);border-radius:8px;padding:9px 11px;background:var(--vp-c-bg);color:var(--vp-c-text-1);font:inherit}.post-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}.check{display:flex;align-items:flex-start;gap:8px;font-size:13px}.check input{width:auto;margin-top:3px}.honeypot{position:absolute;left:-10000px}.form-actions{display:flex;justify-content:flex-end;gap:10px}
.identity-footer{display:flex;align-items:center;justify-content:space-between;gap:20px;margin-top:20px;padding:18px 22px;border:1px solid var(--vp-c-divider);border-radius:12px;background:var(--vp-c-bg-soft)}
@media (max-width:760px){.request-detail{padding:24px 16px 60px}.detail-hero,.section-heading,.activity-heading,.identity-footer{align-items:stretch;flex-direction:column}.hero-actions{display:grid;grid-template-columns:1fr 1fr}.vote-action{min-height:72px}.detail-grid{grid-template-columns:1fr}.status-progress{grid-template-columns:1fr;gap:9px}.status-progress li:not(:last-child)::after{top:28px;bottom:-9px;left:13px;width:2px;height:auto}.relationship-section{grid-template-columns:1fr}.post-grid{grid-template-columns:1fr}}
</style>
